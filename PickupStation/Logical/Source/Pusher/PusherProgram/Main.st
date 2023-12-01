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
	
	IF EDGENEG(gPusher.Commands.Start) OR EDGEPOS(gPusher.Commands.Init) THEN
		MachineState.NextState := WAITING_INIT;
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
		WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			gPusher.Feedbacks.InitDone := FALSE;
			IF gPusher.Commands.Init THEN
				MachineState.NextState := MOVE_BACKWARD;
			
			ELSIF gPusher.Commands.ManualMode THEN
				MachineState.NextState := MANUALS;
				
			END_IF
        
		MANUALS:
			// Manual commands
			gPusher.Interface.Outputs.MoveForward := gPusher.Commands.PushManualCommand;
			IF NOT gPusher.Commands.ManualMode THEN
				MachineState.NextState := WAITING_INIT;
			END_IF			
			
		MOVE_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPusher.Interface.Inputs.PusherInBackwardPosition THEN
				IF gPusher.Commands.Start THEN
					MachineState.NextState := WAITING_START;
				ELSE
					MachineState.NextState := WAITING_MAGAZINE;
				END_IF					
				gPusher.Feedbacks.InitDone := TRUE;
			END_IF 			
		
		WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF gPusher.Commands.Start THEN
				MachineState.NextState := WAITING_MAGAZINE;
			END_IF 
			
		WAITING_MAGAZINE:
			MachineState.TimeoutTimer.PT := T#3S;
			IF NOT gPusher.Interface.Inputs.MagazineEmpty THEN
				MachineState.NextState := WAITING_TAKE_A_CAP_COMMAND;
			END_IF 
			
		WAITING_TAKE_A_CAP_COMMAND:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF NOT gPusher.Commands.Start THEN
				MachineState.NextState := WAITING_START;
			ELSIF NOT gPusher.Interface.Inputs.CapAtPickPosition AND gPusher.Commands.TakeACap THEN
				gPusher.Feedbacks.TakeACapDone := FALSE;
				MachineState.NextState := MOVE_FORWARD;
			END_IF 
			
		MOVE_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			gPusher.Interface.Outputs.MoveForward := TRUE;
			IF gPusher.Interface.Inputs.CapAtPickPosition THEN
				gPusher.Feedbacks.TakeACapDone := TRUE;
				MachineState.NextState := MOVE_BACKWARD;
			END_IF 			
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			gPusher.Feedbacks.TakeACapDone := FALSE;
        
        ELSE
            MachineState.NextState := WAITING_INIT;			
        
    END_CASE
    
	IF (MachineState.ActualState <> MOVE_FORWARD) AND (MachineState.ActualState <> MANUALS) THEN
		gPusher.Interface.Outputs.MoveForward := FALSE;
	END_IF
		
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM