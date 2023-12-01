PROGRAM _INIT
            
    MachineState.NextState := WAITING_MODE_SELECTION;
    
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
        
		WAITING_MODE_SELECTION:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			StopModules;
			IF gMainMachine.Commands.AutomaticMode THEN
				gMainMachine.Feedbacks.AutomaticMode := TRUE;
				gMainMachine.Feedbacks.ManualMode := FALSE;
				
				MachineState.NextState := AUTO_WAITING_INIT;			
			
			ELSIF gMainMachine.Commands.ManualMode THEN
				gMainMachine.Feedbacks.AutomaticMode := FALSE;
				gMainMachine.Feedbacks.ManualMode := TRUE;
				MachineState.NextState := MANUAL;
			END_IF 
		
		AUTO_WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			StopModules;
			gMainMachine.Feedbacks.InitDone := FALSE;
			
			IF NOT gMainMachine.Commands.AutomaticMode THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
				
			ELSIF gMainMachine.Commands.Init THEN
					
				MachineState.NextState := AUTO_INITIALIZING;
				
			END_IF
		
		AUTO_INITIALIZING:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			gPusher.Commands.Init := TRUE;
			gPicker.Commands.Init := TRUE;
			gConveyor.Commands.Init := TRUE;
			gStamper.Commands.Init := TRUE;
			
			IF gPusher.Feedbacks.Error
				OR gPicker.Feedbacks.Error
				OR gConveyor.Feedbacks.Error
				OR (gStamper.Feedbacks.Error AND gStamper.Feedbacks.Enabled)  THEN
				
				MachineState.NextState := ERROR;				
				
			ELSIF gPusher.Feedbacks.InitDone 
				AND gPicker.Feedbacks.InitDone 
				AND gConveyor.Feedbacks.InitDone 
				AND (gStamper.Feedbacks.InitDone OR NOT gStamper.Feedbacks.Enabled) THEN
					
				gMainMachine.Feedbacks.InitDone := TRUE;
				MachineState.NextState := AUTO_WAITING_START;
				
			END_IF
			
		AUTO_WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			StopModules;
			
			IF NOT gMainMachine.Commands.AutomaticMode THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
				
			ELSIF gMainMachine.Commands.Start THEN
				gPusher.Commands.Start := TRUE;
				gPicker.Commands.Start := TRUE;
				gConveyor.Commands.Start := TRUE;
				gStamper.Commands.Start := TRUE;
				
				MachineState.NextState := AUTO_WAITING_MODULES_READY;
				
			END_IF 
        
		AUTO_WAITING_MODULES_READY:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF Internal.OnPhaseStopRequest THEN
				MachineState.NextState := ERROR;
				
			ELSIF NOT gMainMachine.Commands.Start THEN
				MachineState.NextState := AUTO_WAITING_INIT;
			
			ELSIF gPusher.Feedbacks.WaitingTakeACapCommand 
				AND gPicker.Feedbacks.WaitingPickCommand 
				AND gConveyor.Feedbacks.WaitingCap
				AND (gStamper.Feedbacks.WaitingCap OR NOT gStamper.Feedbacks.Enabled) THEN
				
				MachineState.NextState := AUTO_PUSH_CAP;
				
			END_IF
				
		AUTO_PUSH_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gPusher.Commands.TakeACap := TRUE;
				gMainMachine.Feedbacks.NewCapOnWork := TRUE;
			END_IF
			
			IF NOT gPusher.Feedbacks.WaitingTakeACapCommand THEN
				gPusher.Commands.TakeACap := FALSE;
			END_IF
			
			IF gPusher.Feedbacks.Error THEN
				MachineState.NextState := ERROR;
				
			ELSIF NOT gPusher.Commands.TakeACap AND gPusher.Feedbacks.TakeACapDone THEN
				MachineState.NextState := AUTO_PICK_CAP;
			END_IF
		
		AUTO_PICK_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gPicker.Commands.PickACap := TRUE;
			END_IF 
			
			IF NOT gPicker.Feedbacks.WaitingPickCommand THEN
				gPicker.Commands.PickACap := FALSE;
			END_IF
			
			IF gPicker.Feedbacks.Error THEN
				MachineState.NextState := ERROR;
				
			ELSIF NOT gPicker.Commands.PickACap AND gPicker.Feedbacks.PickACapDone THEN
				MachineState.NextState := AUTO_WAITING_CAP_DELIVERY;
			END_IF
			
		AUTO_WAITING_CAP_DELIVERY:	
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gConveyor.Commands.DeliverCap := TRUE;
				gStamper.Commands.StampCap := TRUE;
			END_IF
			
			IF NOT gConveyor.Feedbacks.WaitingCap THEN
				gConveyor.Commands.DeliverCap := FALSE;
			END_IF
			
			IF NOT gStamper.Feedbacks.WaitingCap THEN
				gStamper.Commands.StampCap := FALSE;
			END_IF
			
			IF gConveyor.Feedbacks.Error OR (gStamper.Feedbacks.Error AND gStamper.Feedbacks.Enabled) THEN
				MachineState.NextState := ERROR;
				
			ELSIF NOT gConveyor.Commands.DeliverCap AND gConveyor.Feedbacks.DeliverCapDone THEN
				
				IF gStamper.Feedbacks.Enabled THEN
					
					IF NOT gStamper.Commands.StampCap AND gStamper.Feedbacks.StampCapDone THEN
						MachineState.NextState := AUTO_WAITING_MODULES_READY;
					END_IF
				
				ELSE					
					MachineState.NextState := AUTO_WAITING_MODULES_READY;
				END_IF
				
			END_IF					
			
		ERROR:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				StopModules;
			END_IF
			gMainMachine.Feedbacks.InitDone := FALSE;
			IF NOT Internal.ErrorReaction THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
			END_IF						 
        
		ELSE
			MachineState.NextState := WAITING_MODE_SELECTION;			
        
	END_CASE
    
	IF MachineState.ActualState <> AUTO_PUSH_CAP THEN
		gPusher.Commands.TakeACap := FALSE;
	END_IF
	IF MachineState.ActualState <> AUTO_PICK_CAP THEN
		gPicker.Commands.PickACap := FALSE;
	END_IF
	IF MachineState.ActualState <> AUTO_WAITING_CAP_DELIVERY THEN
		gConveyor.Commands.DeliverCap := FALSE;
		gStamper.Commands.StampCap := FALSE;
	END_IF
		
	IF MachineState.ActualState <> AUTO_PUSH_CAP 
		AND MachineState.ActualState <> AUTO_PICK_CAP 
		AND MachineState.ActualState <> AUTO_WAITING_CAP_DELIVERY THEN
		
		gMainMachine.Feedbacks.NewCapOnWork := FALSE;
		
	END_IF
	
	FeedbacksUpdateAction;
    StatisticsAction;
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM