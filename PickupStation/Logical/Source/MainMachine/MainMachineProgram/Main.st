PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
    MachineState.NextState := WAITING;
    
END_PROGRAM

PROGRAM _CYCLIC
	
	// Master communication management
	MasterCommunication;
	
	// Alarms
	SetAlarmsAction;
	
	// Check reactions
	CheckReactions;
	
	// Enable modules
	EnableModules;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
            
        WAITING:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			StopModules;
			IF gMainMachine.Commands.AutomaticMode THEN
				IF gMainMachine.Commands.Start THEN
					MachineState.NextState := AUTOMATIC;
				END_IF
			ELSE
				MachineState.NextState := MANUAL;
            END_IF 
        
		AUTOMATIC:
			// Pusher
			IF Internal.OnPhaseStopRequest AND (gPusher.Feedbacks.WaitingPick OR gPusher.Feedbacks.Error) THEN
				gPusher.Commands.Start := FALSE;
			ELSE
				gPusher.Commands.Start := TRUE;
			END_IF
			
			// Picker
			IF Internal.OnPhaseStopRequest AND (gPicker.Feedbacks.WaitingPickCommand OR gPicker.Feedbacks.Error) THEN
				gPicker.Commands.Activate := FALSE;
				gPicker.Commands.PickACap := FALSE;
			ELSE
				gPicker.Commands.Activate := TRUE;
				gPicker.Commands.PickACap := gPusher.Feedbacks.CapReady AND gConveyor.Feedbacks.WaitingCap AND gStamper.Feedbacks.WaitingCap;
			END_IF
				
			// Conveyor
			IF Internal.OnPhaseStopRequest AND (gConveyor.Feedbacks.WaitingCap OR gConveyor.Feedbacks.Error) THEN
				gConveyor.Commands.Start := FALSE;
			ELSE
				gConveyor.Commands.Start := TRUE;
			END_IF
			
			// Stamper
			IF Internal.OnPhaseStopRequest AND (gStamper.Feedbacks.WaitingCap OR gStamper.Feedbacks.Error) THEN
				gStamper.Commands.Start := FALSE;
				gStamper.Commands.NewCapTrigger := FALSE;
			ELSE
				gStamper.Commands.Start := TRUE;
				gStamper.Commands.NewCapTrigger := gConveyor.Feedbacks.NewCapTrigger;
			END_IF
			
			// Exit condition
			IF Internal.OnPhaseStopRequest THEN
				
				IF NOT gPusher.Commands.Start 
					AND NOT gPicker.Commands.Activate
					AND NOT gConveyor.Commands.Start
					AND NOT gStamper.Commands.Start THEN
					
					IF gPusher.Feedbacks.Error
						OR gPicker.Feedbacks.Error
						OR gConveyor.Feedbacks.Error
						OR gStamper.Feedbacks.Error THEN
						
						MachineState.NextState := ERROR;
					ELSE	
						MachineState.NextState := WAITING;
					END_IF
					
				END_IF
				
			END_IF
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			StopModules;
			
			gPusher.Commands.Init := gMainMachine.Commands.Init;
			gPicker.Commands.Init := gMainMachine.Commands.Init;
			gConveyor.Commands.Init := gMainMachine.Commands.Init;
			gStamper.Commands.Init := gMainMachine.Commands.Init;
			
			IF NOT gPusher.Feedbacks.Error
				AND NOT gPicker.Feedbacks.Error
				AND NOT gConveyor.Feedbacks.Error
				AND NOT gStamper.Feedbacks.Error THEN
				
				MachineState.NextState := WAITING_START;
				
			END_IF
						 
        
        ELSE
            MachineState.NextState := WAITING_START;			
        
    END_CASE
    
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM