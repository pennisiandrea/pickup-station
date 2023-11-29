PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
	Internal.Parameters.Acceleration := 200;
	Internal.Parameters.Deceleration := 200;
	Internal.Parameters.Homing.Mode := mcHOMING_ABSOLUTE;
	Internal.Parameters.Homing.Position := 0;	
	 
    MachineState.NextState := WAITING_START;
    
END_PROGRAM

PROGRAM _CYCLIC

	MotionAction;
	
    // Enable module
    IF NOT gConveyor.Commands.Enable THEN
        ResetOutputsAction;
		ResetFeedbacksAction;
		ResetAlarmsAction;		
        RETURN;
    END_IF
    
	IF EDGEPOS(gConveyor.Commands.Init) THEN
		MachineState.NextState := HOMING;	
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
            IF gConveyor.Commands.Start AND Internal.Axis.Active THEN
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
				IF gConveyor.Commands.Init THEN
					MachineState.NextState := INIT;
				ELSE
					MachineState.NextState := WAITING_CAP;
				END_IF
			END_IF		
		
		WAITING_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF gConveyor.Interface.Inputs.CapInStartPosition THEN
				MachineState.NextState := MOTION;
			END_IF 	
		
		MOTION:
			MachineState.TimeoutTimer.PT := T#15S;	
			
			IF EDGENEG(gConveyor.Interface.Inputs.CapInStartPosition) THEN
				gConveyor.Feedbacks.CapOnMotion := TRUE;
			END_IF 
			
			IF EDGENEG(gConveyor.Interface.Inputs.CapInExitPosition) THEN
				MachineState.NextState := WAITING_CAP;
			END_IF 	
			
		INIT:
			MachineState.TimeoutTimer.PT := T#15S;			
			IF Internal.Axis.MoveDone THEN
				MachineState.NextState := WAITING_START;
			END_IF			
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			Internal.Axis.Power := FALSE;
        
        ELSE
            MachineState.NextState := WAITING_START;			
        
    END_CASE
    
	Internal.Axis.Home := (MachineState.ActualState = HOMING);
	Internal.Axis.MoveVelocity := (MachineState.ActualState = MOTION);
	Internal.Axis.MoveAbsolute := (MachineState.ActualState = INIT);
	Internal.Axis.Stop := (MachineState.ActualState = ERROR);
		
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    Internal.Axis(Enable := FALSE);
    
END_PROGRAM