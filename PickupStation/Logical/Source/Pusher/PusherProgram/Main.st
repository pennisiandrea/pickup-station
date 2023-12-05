PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
    MachineState.NextState := WAITING_INIT;
    
END_PROGRAM

PROGRAM _CYCLIC

    // Enable module
    IF NOT gPusher.Commands.Enable THEN
        ResetOutputsAction;
		ResetFeedbacksAction;	
		ResetAlarmsAction;		
        RETURN;
	END_IF
	
	IF EDGENEG(gPusher.Commands.Automatic.Start) THEN
		IF MachineState.NextState <> ERROR THEN
			MachineState.NextState := WAITING_START;
		END_IF
	END_IF
	
	IF EDGEPOS(gPusher.Commands.Automatic.Init) THEN
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
				gPusher.Feedbacks.TakeACapDone := FALSE;
			END_IF
			IF gPusher.Commands.Automatic.Init THEN
				MachineState.NextState := MOVE_BACKWARD;
			
			ELSIF gPusher.Commands.Manual.Enable THEN
				MachineState.NextState := MANUALS;
				
			END_IF
        
		MANUALS:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			// Manual commands
			gPusher.Interface.Outputs.MoveForward := gPusher.Commands.Manual.Push;
			IF NOT gPusher.Commands.Manual.Enable THEN
				MachineState.NextState := WAITING_INIT;
			END_IF			
			
		MOVE_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPusher.Interface.Inputs.PusherInBackwardPosition THEN
				MachineState.NextState := WAITING_START;			
			END_IF 			
		
		WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF gPusher.Commands.Automatic.Start THEN
				MachineState.NextState := WAITING_MAGAZINE;
				
			ELSIF gPusher.Commands.Manual.Enable THEN
				MachineState.NextState := MANUALS;	
			END_IF 
			
		WAITING_MAGAZINE:
			MachineState.TimeoutTimer.PT := T#3S;
			IF NOT gPusher.Interface.Inputs.MagazineEmpty THEN
				MachineState.NextState := WAITING_TAKE_A_CAP_COMMAND;
			END_IF 
			
		WAITING_TAKE_A_CAP_COMMAND:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF NOT gPusher.Interface.Inputs.CapAtPickPosition AND gPusher.Commands.Automatic.TakeACap THEN
				gPusher.Feedbacks.TakeACapDone := FALSE;
				MachineState.NextState := MOVE_FORWARD;
			END_IF 
			
		MOVE_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			gPusher.Interface.Outputs.MoveForward := TRUE;
			IF gPusher.Interface.Inputs.CapAtPickPosition THEN
				gPusher.Interface.Outputs.MoveForward := FALSE;
				gPusher.Feedbacks.TakeACapDone := TRUE;
				MachineState.NextState := MOVE_BACKWARD;
			END_IF 			
			
        ERROR:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			IF NOT Internal.Error THEN
				MachineState.NextState := WAITING_INIT;
			END_IF
        
        ELSE
            MachineState.NextState := WAITING_INIT;			
        
    END_CASE
		
    FeedbacksUpdateAction;
	
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM