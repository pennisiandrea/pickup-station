PROGRAM _INIT
            
    MachineState.NextState := WAITING_START;
    
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
            
		WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			StopModules;
			IF gMainMachine.Commands.AutomaticMode THEN
				IF gMainMachine.Commands.Start THEN
					MachineState.NextState := AUTO_WAITING_MODULES_READY;
				END_IF
			ELSE
				//MachineState.NextState := MANUAL;
			END_IF 
        
		AUTO_WAITING_MODULES_READY:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gPusher.Commands.Start := TRUE;
				gPicker.Commands.Activate := TRUE;
				gConveyor.Commands.Start := TRUE;
				gStamper.Commands.Start := TRUE;
			END_IF
			
			IF Internal.OnPhaseStopRequest THEN
				MachineState.NextState := ERROR;
				
			ELSIF NOT gMainMachine.Commands.Start THEN
				MachineState.NextState := WAITING_START;
			
			ELSIF gPusher.Feedbacks.WaitingPick 
				AND gPicker.Feedbacks.WaitingPickCommand 
				AND gConveyor.Feedbacks.WaitingCap
				AND (gStamper.Feedbacks.WaitingCap OR NOT gStamper.Feedbacks.Enabled) THEN
				
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
			
			IF NOT gPicker.Commands.PickACap AND gPicker.Feedbacks.PickACapDone THEN
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
			
			IF NOT gConveyor.Commands.DeliverCap AND gConveyor.Feedbacks.DeliverCapDone THEN
				
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
			
			gPusher.Commands.Init := gMainMachine.Commands.Init;
			gPicker.Commands.Init := gMainMachine.Commands.Init;
			gConveyor.Commands.Init := gMainMachine.Commands.Init;
			gStamper.Commands.Init := gMainMachine.Commands.Init;
			
			IF NOT gPusher.Feedbacks.Error AND gPusher.Feedbacks.WaitingStart
				AND NOT gPicker.Feedbacks.Error AND gPicker.Feedbacks.WaitingActivate
				AND NOT gConveyor.Feedbacks.Error AND gConveyor.Feedbacks.WaitingStart
				AND NOT gStamper.Feedbacks.Error  AND gStamper.Feedbacks.WaitingStart THEN
				
				MachineState.NextState := WAITING_START;
				
			END_IF
						 
        
		ELSE
			MachineState.NextState := WAITING_START;			
        
	END_CASE
    
	IF MachineState.ActualState <> AUTO_PICK_CAP THEN
		gPicker.Commands.PickACap := FALSE;
	END_IF
	IF MachineState.ActualState <> AUTO_WAITING_CAP_DELIVERY THEN
		gConveyor.Commands.DeliverCap := FALSE;
		gStamper.Commands.StampCap := FALSE;
	END_IF
	
	FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM