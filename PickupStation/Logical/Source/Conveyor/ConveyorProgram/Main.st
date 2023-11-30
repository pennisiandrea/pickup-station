PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
	Internal.Parameters.Acceleration := 20;
	Internal.Parameters.Deceleration := 20;
	Internal.Parameters.Homing.Mode := mcHOMING_ABSOLUTE;
	Internal.Parameters.Homing.Position := 0;	
	 
    MachineState.NextState := WAITING_START;
    
	// JUST FOR DEBUG
	gConveyor.Commands.Enable := TRUE;
	gConveyor.Commands.Start := TRUE;
	gConveyor.Parameters.TargetSpeed := 0.05;
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
			IF EDGENEG(gConveyor.Interface.Inputs.CapInExitPosition) THEN
				MachineState.TimeoutTimer.PT := T#0S; // Reset state timeout when a cap is delivered
			ELSE
				MachineState.TimeoutTimer.PT := T#30S;
			END_IF
			
			IF MachineState.NewTriggerState THEN
				Internal.CapsCount := 1;
			END_IF
			
			IF Internal.CapsCount = 0 THEN
				MachineState.NextState := WAITING_CAP;
			END_IF 	
			
		INIT:
			MachineState.TimeoutTimer.PT := T#30S;			
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
    
	Internal.Axis.Home := (MachineState.ActualState = HOMING) AND NOT Internal.Axis.IsHomed AND Internal.Axis.Active;
	Internal.Axis.MoveVelocity := (MachineState.ActualState = MOTION);
	Internal.Axis.MoveAbsolute := (MachineState.ActualState = INIT);
	Internal.Axis.Stop := (MachineState.ActualState = ERROR);
			
	gConveyor.Feedbacks.CapOnMotion := (MachineState.ActualState = MOTION);
	
	IF EDGEPOS(gConveyor.Interface.Inputs.CapInStartPosition) THEN
		Internal.CapsCount := Internal.CapsCount + 1;				
	END_IF 						
	IF EDGENEG(gConveyor.Interface.Inputs.CapInExitPosition) THEN
		Internal.CapsCount := MAX(0,Internal.CapsCount - 1);
	END_IF 	
	
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    Internal.Axis(Enable := FALSE);
    
END_PROGRAM