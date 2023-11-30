PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
	Internal.Parameters.Acceleration := 100;
	Internal.Parameters.Deceleration := 100;
	Internal.Parameters.Velocity := 50;
	Internal.Parameters.Homing.Mode := mcHOMING_ABSOLUTE;
	Internal.Parameters.Homing.Position := 0;
	gStamper.Parameters.Offset := 0.065;
	Internal.Offset.AdvancedParameters.ShiftMode := mcSHIFT_ABSOLUTE_NO_RESET;
	Internal.Offset.Enable := TRUE;
	
    MachineState.NextState := WAITING;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	MotionAction;
	
    // Enable module
    IF NOT gStamper.Commands.Enable THEN
        ResetOutputsAction;
		ResetFeedbacksAction;
		ResetAlarmsAction;	
        RETURN;
    END_IF
    
	IF EDGENEG(gStamper.Commands.Start) OR EDGEPOS(gStamper.Commands.Init) THEN
		IF Internal.Axis.Info.PLCopenState = mcAXIS_SYNCHRONIZED_MOTION THEN
			MachineState.NextState := RESET_SHIFT;
		ELSE
			MachineState.NextState := WAITING_START;
		END_IF
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
        WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF MachineState.NewTriggerState THEN
				Internal.Axis.Power := FALSE;
			END_IF
            IF gStamper.Commands.Start AND Internal.Axis.Active THEN
                MachineState.NextState := HOMING;
            END_IF
			
		HOMING:
			MachineState.TimeoutTimer.PT := T#3S;
			
			IF Internal.Axis.IsHomed THEN
				MachineState.NextState := POWER_ON;
			END_IF
		
		POWER_ON:
			MachineState.TimeoutTimer.PT := T#3S;
			
			Internal.Axis.Power := TRUE;
			IF Internal.Axis.PowerOn THEN
				MachineState.NextState := ACTIVATE_CAM;
			END_IF	
			
		ACTIVATE_CAM:
			MachineState.TimeoutTimer.PT := T#3S;
			Internal.Cam.Enable := TRUE;
			Internal.Cam.Start := TRUE;
			Internal.Cam.EndAutomat := FALSE;
			IF Internal.Axis.Info.PLCopenState = mcAXIS_SYNCHRONIZED_MOTION THEN
				MachineState.NextState := SET_SHIFT;
			END_IF			
			
		SET_SHIFT:
			MachineState.TimeoutTimer.PT := T#20S;
			Internal.Offset.Enable := TRUE;
			IF MachineState.NewTriggerState THEN
				Internal.Offset.OffsetShift := gStamper.Parameters.Offset;
				Internal.Offset.StartShift := TRUE;
			ELSE				
				IF Internal.Offset.ShiftAttained THEN
					Internal.LastOffset := gStamper.Parameters.Offset;
					MachineState.NextState := WAITING_CAP;
				END_IF 
			END_IF
			
		WAITING_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF Internal.Cam.InCam AND Internal.Cam.ActualStateIndex = 1 THEN
				MachineState.NextState := STAMP_FORWARD;
			ELSIF Internal.LastOffset <> gStamper.Parameters.Offset THEN
				MachineState.NextState := SET_SHIFT;
			END_IF
			
		STAMP_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			
			IF gStamper.Interface.Inputs.StampIsForward THEN
				MachineState.NextState := STAMPING;
			END_IF
			
		STAMPING:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF Internal.Cam.ActualStateIndex <> 1 THEN
				MachineState.NextState := STAMP_BACKWARD;
			END_IF
			
		STAMP_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			
			IF gStamper.Interface.Inputs.StampIsBackward THEN
				MachineState.NextState := WAITING_CAP;
			END_IF
			
		RESET_SHIFT:
			MachineState.TimeoutTimer.PT := T#20S;
			Internal.Offset.Enable := TRUE;
			IF MachineState.NewTriggerState THEN
				Internal.Offset.OffsetShift := 0;
				Internal.Offset.StartShift := TRUE;
			ELSE				
				IF Internal.Offset.ShiftAttained THEN
					MachineState.NextState := WAITING;
				END_IF 
			END_IF
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			Internal.Axis.Power := FALSE;
        
        ELSE
            MachineState.NextState := WAITING;			
        
    END_CASE
    
	Internal.Axis.Home := (MachineState.ActualState = HOMING) AND NOT Internal.Axis.IsHomed AND Internal.Axis.Active;
	
	Internal.CamStartTrigger := gStamper.Commands.NewCapTrigger AND (MachineState.ActualState = WAITING_CAP) AND (Internal.Cam.ActualStateIndex = 0);
	
	IF (MachineState.ActualState = WAITING_START) OR (MachineState.ActualState = ERROR) THEN
		Internal.Cam.EndAutomat := Internal.Cam.Running;
		Internal.Cam.Start := FALSE;
		Internal.Cam.Enable := FALSE;
		Internal.Offset.Enable := FALSE;
	END_IF
	
	IF (MachineState.ActualState <> SET_SHIFT) AND (MachineState.ActualState <> RESET_SHIFT) THEN
		Internal.Offset.StartShift := FALSE;
	END_IF
	
	gStamper.Interface.Outputs.StampForward := (MachineState.ActualState = STAMP_FORWARD) OR (MachineState.ActualState = STAMPING);
	
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM