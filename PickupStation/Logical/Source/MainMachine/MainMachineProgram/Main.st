PROGRAM _INIT
           
	EnableModules;
	
    MachineState.NextState := WAITING_MODE_SELECTION;
    
END_PROGRAM

PROGRAM _CYCLIC
	
	// Master communication management
	MasterCommunication;
	
	// Alarms
	SetAlarmsAction;
	
	// Check stop reaction
	IF MpAlarmXCheckReaction(gAlarmXCoreMpLink,'STOP') THEN
		MachineState.NextState := ERROR;
	END_IF
		
	// Machine state
	MachineStateManagementAction;
	CASE MachineState.ActualState OF
        
		WAITING_MODE_SELECTION:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				StopModules;
			END_IF
			
			IF gMainMachine.Commands.AutomaticMode THEN				
				MachineState.NextState := AUTO_WAITING_INIT;			
			
			ELSIF gMainMachine.Commands.ManualMode THEN
				MachineState.NextState := MANUAL;
			END_IF 
		
		MANUAL:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gMainMachine.Feedbacks.AutomaticMode := FALSE;
				gMainMachine.Feedbacks.ManualMode := TRUE;
			END_IF
			
			gPusher.Commands.ManualMode := TRUE;
			gPicker.Commands.ManualMode := TRUE;
			gConveyor.Commands.ManualMode := TRUE;
			
			IF NOT gMainMachine.Commands.ManualMode THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
			END_IF
			
		AUTO_WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state			
			IF MachineState.NewTriggerState THEN
				gMainMachine.Feedbacks.AutomaticMode := TRUE;
				gMainMachine.Feedbacks.ManualMode := FALSE;
				gMainMachine.Feedbacks.InitDone := FALSE;
			END_IF
						
			IF NOT gMainMachine.Commands.AutomaticMode THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
				
			ELSIF gMainMachine.Commands.Init THEN					
				MachineState.NextState := AUTO_INITIALIZING;	
				
			END_IF
		
		AUTO_INITIALIZING:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				InitModules;
			END_IF
			
			IF gPusher.Feedbacks.InitDone 
				AND gPicker.Feedbacks.InitDone 
				AND gConveyor.Feedbacks.InitDone 
				AND gStamper.Feedbacks.InitDone THEN
					
				gMainMachine.Feedbacks.InitDone := TRUE;
				MachineState.NextState := AUTO_WAITING_START;
				
			END_IF
			
		AUTO_WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				StopModules;
			END_IF
			
			IF NOT gMainMachine.Commands.AutomaticMode THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
				
			ELSIF gMainMachine.Commands.Start THEN				
				MachineState.NextState := AUTO_WAITING_MODULES_READY;
				
			END_IF 
        
		AUTO_WAITING_MODULES_READY:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN	
				StartModules;
				gMainMachine.Feedbacks.NewCapOnWork := FALSE;
			END_IF
			
			IF NOT gMainMachine.Commands.Start THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
			
			ELSIF gPusher.Feedbacks.WaitingTakeACapCommand 
				AND gPicker.Feedbacks.WaitingPickCommand 
				AND gConveyor.Feedbacks.WaitingCap
				AND (gStamper.Feedbacks.WaitingCap OR NOT gMainMachine.Parameters.StamperEnable) THEN
				
				gMainMachine.Feedbacks.NewCapOnWork := TRUE;
				MachineState.NextState := AUTO_PUSH_CAP;				
			END_IF
				
		AUTO_PUSH_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gPusher.Commands.TakeACap := TRUE;
			END_IF
			
			IF NOT gPusher.Feedbacks.WaitingTakeACapCommand THEN
				gPusher.Commands.TakeACap := FALSE;
			END_IF
			
			IF NOT gPusher.Commands.TakeACap AND gPusher.Feedbacks.TakeACapDone THEN
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
				
				IF gMainMachine.Parameters.StamperEnable THEN
					
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
			
			IF gMainMachine.Commands.Reset THEN
				ResetModules;
			END_IF
			
			IF NOT MpAlarmXCheckReaction(gAlarmXCoreMpLink,'ERROR') THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
			END_IF						 
        
		ELSE
			MachineState.NextState := WAITING_MODE_SELECTION;			
        
	END_CASE
    		
	FeedbacksUpdateAction;
	
	StatisticsAction;
	
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM