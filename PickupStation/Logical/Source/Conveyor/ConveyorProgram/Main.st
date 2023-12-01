PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
	Internal.Parameters.Acceleration := 5000;
	Internal.Parameters.Deceleration := 5000;
	Internal.Parameters.Homing.Mode := mcHOMING_ABSOLUTE;
	Internal.Parameters.Homing.Position := 0;	
	 
    MachineState.NextState := WAITING_INIT;
    
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
    
	IF EDGENEG(gConveyor.Commands.Start) OR EDGEPOS(gConveyor.Commands.Init) THEN
		Internal.Axis.ErrorReset := TRUE;
		MachineState.NextState := WAITING_INIT;	
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
		WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			gConveyor.Feedbacks.InitDone := FALSE;
			IF gConveyor.Commands.Init AND Internal.Axis.Active THEN
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
				IF NOT gConveyor.Feedbacks.InitDone THEN
					MachineState.NextState := INIT;
				ELSE
					MachineState.NextState := WAITING_CAP;
				END_IF
			END_IF
			
		INIT:
			MachineState.TimeoutTimer.PT := T#30S;			
			IF Internal.Axis.MoveDone THEN
				gConveyor.Feedbacks.InitDone := TRUE;
				MachineState.NextState := WAITING_START;
			END_IF	
			
        WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				Internal.Axis.Power := FALSE;
			END_IF
			gConveyor.Feedbacks.DeliverCapDone := FALSE;
            IF gConveyor.Commands.Start AND Internal.Axis.Active THEN
                MachineState.NextState := POWER_ON;
            END_IF   		
		
		WAITING_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF gConveyor.Interface.Inputs.CapInStartPosition AND gConveyor.Commands.DeliverCap THEN
				gConveyor.Feedbacks.DeliverCapDone := FALSE;
				MachineState.NextState := MOTION;
			END_IF 	
		
		MOTION:
			MachineState.TimeoutTimer.PT := T#30S;
						
			IF EDGENEG(gConveyor.Interface.Inputs.CapInExitPosition) THEN
				gConveyor.Feedbacks.DeliverCapDone := TRUE;
				MachineState.NextState := WAITING_CAP;
			END_IF 			
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			Internal.Axis.Power := FALSE;
			gConveyor.Feedbacks.DeliverCapDone := FALSE;
			gConveyor.Feedbacks.InitDone := FALSE;
        
        ELSE
            MachineState.NextState := WAITING_START;			
        
    END_CASE
    
	Internal.Axis.Home := (MachineState.ActualState = HOMING) AND NOT Internal.Axis.IsHomed AND Internal.Axis.Active;
	Internal.Axis.MoveVelocity := (MachineState.ActualState = MOTION);
	Internal.Axis.MoveAbsolute := (MachineState.ActualState = INIT);
	Internal.Axis.Stop := (MachineState.ActualState = ERROR);
				
	IF NOT Internal.Axis.Error THEN		
		Internal.Axis.ErrorReset := FALSE;	
	END_IF
	
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    Internal.Axis(Enable := FALSE);
    
END_PROGRAM