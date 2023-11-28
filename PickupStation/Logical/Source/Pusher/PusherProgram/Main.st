PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
    MachineState.NextState := WAITING_START;
    
END_PROGRAM

PROGRAM _CYCLIC

    // Enable module
    IF NOT gPusher.Commands.Enable THEN
        ResetOutputsAction;
		ResetFeedbacksAction;	
		ResetAlarmsAction;		
        RETURN;
    END_IF
    	
	// Init command management
	IF EDGEPOS(gPusher.Commands.Init) THEN
		MachineState.NextState := MOVE_BACKWARD;
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
        WAITING_START:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
            IF gPusher.Commands.Start THEN
                MachineState.NextState := MOVE_BACKWARD;
            END_IF 
        
		MOVE_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPusher.Interface.Inputs.PusherInBackwardPosition THEN
				MachineState.NextState := WAITING_MAGAZINE;
			END_IF 
			
		WAITING_MAGAZINE:
			MachineState.TimeoutTimer.PT := T#3S;
			IF NOT gPusher.Interface.Inputs.MagazineEmpty THEN
				MachineState.NextState := WAITING_PICK;
			END_IF 
			
		WAITING_PICK:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF NOT gPusher.Commands.Start THEN
				MachineState.NextState := WAITING_START;
			ELSIF NOT gPusher.Interface.Inputs.CapAtPickPosition THEN
				MachineState.NextState := MOVE_FORWARD;
			END_IF 
			
		MOVE_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPusher.Interface.Inputs.CapAtPickPosition THEN
				MachineState.NextState := MOVE_BACKWARD;
			END_IF 			
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
            ResetOutputsAction;
        
        ELSE
            MachineState.NextState := WAITING_START;			
        
    END_CASE
    
	gPusher.Interface.Outputs.MoveForward := (MachineState.ActualState = MOVE_FORWARD);
	
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM