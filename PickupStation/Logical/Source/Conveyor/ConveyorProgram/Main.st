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
		ResetMotionCommands;
        RETURN;
    END_IF    
	
	IF EDGENEG(gConveyor.Commands.Start) THEN
		IF MachineState.NextState <> ERROR THEN
			MachineState.NextState := WAITING_START;
		END_IF
	END_IF
	
	IF EDGEPOS(gConveyor.Commands.Init) THEN
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
			END_IF
			
			IF gConveyor.Commands.Init THEN
				MachineState.NextState := HOMING;
				
			ELSIF gConveyor.Commands.ManualMode THEN
				MachineState.NextState := MANUALS;
				
			END_IF
		     
		MANUALS:			
			// Manual commands
			Internal.Axis.Home := gConveyor.Commands.HomeManualCommand AND Internal.Axis.Active;
			IF Internal.Axis.IsHomed THEN			
				Internal.Axis.Power := gConveyor.Commands.PowerOnManualCommand AND Internal.Axis.Active;
				IF Internal.Axis.PowerOn THEN		
					Internal.Axis.MoveVelocity := gConveyor.Commands.JogManualCommand AND Internal.Axis.Active;
				ELSE
					Internal.Axis.MoveVelocity := FALSE;
				END_IF
			ELSE
				Internal.Axis.Power := FALSE;
				Internal.Axis.MoveVelocity := FALSE;
			END_IF
			
			IF NOT gConveyor.Commands.ManualMode THEN
				MachineState.NextState := WAITING_INIT;		
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
				IF NOT gConveyor.Feedbacks.InitDone THEN
					MachineState.NextState := INIT;
				ELSE
					MachineState.NextState := WAITING_CAP;
				END_IF
			END_IF
			
		INIT:
			MachineState.TimeoutTimer.PT := T#30S;	
			Internal.Axis.MoveAbsolute := Internal.Axis.Active;
			IF Internal.Axis.MoveDone THEN
				Internal.Axis.MoveAbsolute := FALSE;
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
			Internal.Axis.MoveVelocity := TRUE;			
			IF EDGENEG(gConveyor.Interface.Inputs.CapInExitPosition) THEN
				gConveyor.Feedbacks.DeliverCapDone := TRUE;
				Internal.Axis.MoveVelocity := FALSE;
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
    
END_PROGRAM