PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
	Internal.Parameters.Position := 0;
	Internal.Parameters.Acceleration := 20000;
	Internal.Parameters.Deceleration := 20000;
	Internal.Parameters.Velocity := 10000;
	Internal.Parameters.Homing.Mode := mcHOMING_ABSOLUTE;
	Internal.Parameters.Homing.Position := 0;
	gStamper.Parameters.Offset := 65;
	Internal.Offset.AdvancedParameters.ShiftMode := mcSHIFT_RELATIVE;
	Internal.Offset.Enable := TRUE;
	
    MachineState.NextState := WAITING_INIT;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	MotionAction;
	
    // Enable module
    IF NOT gStamper.Commands.Enable THEN
        ResetOutputsAction;
		ResetFeedbacksAction;
		ResetAlarmsAction;	
		ResetMotionCommands;
        RETURN;
    END_IF
    
	IF EDGENEG(gStamper.Commands.Start) THEN
		IF MachineState.NextState <> ERROR THEN
			MachineState.NextState := WAITING_START;
		END_IF
	END_IF
	
	IF EDGEPOS(gStamper.Commands.Init) THEN
		IF MachineState.NextState <> ERROR THEN
			MachineState.NextState := WAITING_INIT;
		END_IF
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
		WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				ResetOutputsAction;
				ResetMotionCommands;
				Internal.CamStartTrigger := FALSE;
			END_IF
			IF gStamper.Commands.Init THEN
				MachineState.NextState := HOMING;			
			END_IF			
			
		HOMING:
			MachineState.TimeoutTimer.PT := T#3S;
			IF Internal.Axis.IsHomed THEN
				Internal.Axis.Home := FALSE;
				MachineState.NextState := POWER_ON;
			ELSE
				Internal.Axis.Home := Internal.Axis.Active;
			END_IF
					
		POWER_ON:
			MachineState.TimeoutTimer.PT := T#3S;
			
			Internal.Axis.Power := Internal.Axis.Active;
			IF Internal.Axis.PowerOn THEN
				IF NOT gStamper.Feedbacks.InitDone THEN
					MachineState.NextState := INIT;
				ELSE
					MachineState.NextState := ACTIVATE_CAM;
				END_IF
			END_IF
			
		INIT:
			MachineState.TimeoutTimer.PT := T#15S;
			Internal.Axis.MoveAbsolute := TRUE;
			IF Internal.Axis.MoveDone THEN
				Internal.Axis.MoveAbsolute := FALSE;
				MachineState.NextState := WAITING_START;
			END_IF		
			
        WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state			
			IF MachineState.NewTriggerState THEN
				Internal.Axis.Power := FALSE;
			END_IF
			
			IF gStamper.Commands.Start THEN
				gStamper.Feedbacks.StampCapDone := FALSE;
			    MachineState.NextState := POWER_ON;
            END_IF
			
		ACTIVATE_CAM:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state		
			Internal.Cam.Enable := TRUE;
			Internal.Cam.Start := TRUE;
			IF Internal.Axis.Info.PLCopenState = mcAXIS_SYNCHRONIZED_MOTION THEN
				Internal.Offset.Enable := TRUE;
				IF Internal.Offset.Valid THEN
					IF Internal.Offset.ActualOffsetShift <> gStamper.Parameters.Offset THEN
						MachineState.NextState := SET_SHIFT;
					ELSE
						MachineState.NextState := WAITING_CAP;
					END_IF
				END_IF
			END_IF			
			
		SET_SHIFT:
			MachineState.TimeoutTimer.PT := T#20S;
			IF MachineState.NewTriggerState THEN
				Internal.Offset.OffsetShift := gStamper.Parameters.Offset;
				Internal.Offset.StartShift := TRUE;
			END_IF
							
			IF Internal.Offset.ShiftStarted THEN
				Internal.Offset.StartShift := FALSE;
			END_IF
			
			IF NOT Internal.Offset.StartShift AND Internal.Offset.ShiftAttained THEN
				Internal.LastOffset := gStamper.Parameters.Offset;
				MachineState.NextState := WAITING_CAP;
			END_IF 
			
		WAITING_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state			
			IF gStamper.Commands.StampCap THEN
				gStamper.Feedbacks.StampCapDone := FALSE;
				Internal.CamStartTrigger := TRUE;
			END_IF
			
			IF Internal.Cam.InCam AND Internal.Cam.ActualStateIndex = 1 THEN // Syncronized motion
				Internal.CamStartTrigger := FALSE;
				MachineState.NextState := STAMP_FORWARD;
			ELSIF Internal.LastOffset <> gStamper.Parameters.Offset THEN
				MachineState.NextState := SET_SHIFT;
			END_IF
			
		STAMP_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			
			gStamper.Interface.Outputs.StampForward := TRUE;
			IF gStamper.Interface.Inputs.StampIsForward THEN
				MachineState.NextState := STAMPING;
			END_IF
			
		STAMPING:
			MachineState.TimeoutTimer.PT := T#15S;
			
			IF Internal.Cam.ActualStateIndex <> 1 THEN
				gStamper.Interface.Outputs.StampForward := FALSE;
				MachineState.NextState := STAMP_BACKWARD;
			END_IF
			
		STAMP_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			
			IF gStamper.Interface.Inputs.StampIsBackward THEN
				gStamper.Feedbacks.StampCapDone := TRUE;
				MachineState.NextState := WAITING_CAP;
			END_IF
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			ResetMotionCommands;
			IF NOT Internal.Error THEN
				MachineState.NextState := WAITING_INIT;
			END_IF
        
        ELSE
            MachineState.NextState := WAITING_START;			
        
    END_CASE
			
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
	Internal.Axis(Enable := FALSE);
	Internal.Cam(Enable := FALSE);
	Internal.Offset(Enable := FALSE);
    
END_PROGRAM