PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
	Internal.Parameters.Acceleration := 200;
	Internal.Parameters.Deceleration := 200;
	Internal.Parameters.Velocity := 100;
	Internal.Parameters.Homing.Mode := mcHOMING_ABSOLUTE;
	
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
    
	IF EDGEPOS(gStamper.Commands.Init) THEN
		MachineState.NextState := HOMING;
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
        WAITING:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				Internal.Axis.Power := FALSE;
			END_IF
            IF gStamper.Commands.Start THEN
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
				MachineState.NextState := ACTIVATE_SYNC_MOTION;
			END_IF
		
		ACTIVATE_SYNC_MOTION:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF Internal.Cam.InCam AND Internal.Cam.ActualStateIndex = 1 THEN
				MachineState.NextState := STAMP_FORWARD;
			END_IF
			
		STAMP_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			
			IF gStamper.Interface.Inputs.StampIsForward THEN
				MachineState.NextState := STAMP_FORWARD;
			END_IF
			
		STAMPING:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF Internal.Cam.ActualStateIndex <> 1 THEN
				MachineState.NextState := STAMP_BACKWARD;
			END_IF
			
		STAMP_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			
			IF gStamper.Interface.Inputs.StampIsBackward THEN
				MachineState.NextState := ACTIVATE_SYNC_MOTION;
			END_IF
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			Internal.Axis.Power := FALSE;
        
        ELSE
            MachineState.NextState := WAITING;			
        
    END_CASE
    
	Internal.Axis.Home := (MachineState.ActualState = HOMING) AND NOT Internal.Axis.IsHomed;
	Internal.Cam.Start := (MachineState.ActualState = ACTIVATE_SYNC_MOTION);
	Internal.Cam.Stop := (MachineState.ActualState = WAITING) OR (MachineState.ActualState = ERROR);
	
	gStamper.Interface.Outputs.StampForward := (MachineState.ActualState = STAMP_FORWARD) OR (MachineState.ActualState = STAMPING);
	
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM