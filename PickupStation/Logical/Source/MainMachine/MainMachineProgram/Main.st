//******************************************************************************************************
// Program: 	MainMachineProgram
// Author: 		Andrea Pennisi
// Rev.: 		1.0.0
// Date:		5.12.2023
//
// Description:
// This module is the main machine. It manage the comunications between the modules and the working flow.
//******************************************************************************************************
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
			
			IF gMainMachine.Commands.Automatic.Enable THEN				
				MachineState.NextState := AUTO_WAITING_INIT;			
			
			ELSIF gMainMachine.Commands.Manual.Enable THEN
				MachineState.NextState := MANUAL;
			END_IF 
		
		MANUAL:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				ResetModulesManualCommands;
			END_IF
			
			gPusher.Commands.Manual.Enable := TRUE;
			gPicker.Commands.Manual.Enable := TRUE;
			gConveyor.Commands.Manual.Enable := TRUE;
			gStamper.Commands.Manual.Enable := TRUE;
					
			IF NOT gMainMachine.Commands.Manual.Enable THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
			END_IF
			
		AUTO_WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state			
			IF MachineState.NewTriggerState THEN
				gMainMachine.Feedbacks.InitDone := FALSE;
			END_IF
						
			IF NOT gMainMachine.Commands.Automatic.Enable THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
				
			ELSIF gMainMachine.Commands.Automatic.Init THEN					
				MachineState.NextState := AUTO_INITIALIZING;	
				
			END_IF
		
		AUTO_INITIALIZING:
			MachineState.TimeoutTimer.PT := T#30S; // Timeout disabled in this state
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
			
			IF NOT gMainMachine.Commands.Automatic.Enable THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
				
			ELSIF gMainMachine.Commands.Automatic.Start THEN				
				MachineState.NextState := AUTO_WAITING_MODULES_READY;
				
			ELSIF gMainMachine.Commands.Automatic.Init THEN	
				gMainMachine.Feedbacks.InitDone := TRUE;
				
			END_IF 
        
		AUTO_WAITING_MODULES_READY:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN	
				StartModules;
				gMainMachine.Feedbacks.NewCapOnWork := FALSE;
			END_IF
			
			IF NOT gMainMachine.Commands.Automatic.Start THEN
				MachineState.NextState := WAITING_MODE_SELECTION;
			
			ELSIF gPusher.Feedbacks.WaitingTakeACapCommand 
				AND gPicker.Feedbacks.WaitingPickCommand 
				AND gConveyor.Feedbacks.WaitingCap
				AND (gStamper.Feedbacks.WaitingCap OR NOT gStamper.Commands.Automatic.Start) THEN
				
				MachineState.NextState := AUTO_PUSH_CAP;				
			END_IF
				
		AUTO_PUSH_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gMainMachine.Feedbacks.NewCapOnWork := TRUE;
				gPusher.Commands.Automatic.TakeACap := TRUE;
			END_IF
			
			IF NOT gPusher.Feedbacks.WaitingTakeACapCommand THEN
				gPusher.Commands.Automatic.TakeACap := FALSE;
			END_IF
			
			IF NOT gPusher.Commands.Automatic.TakeACap AND gPusher.Feedbacks.TakeACapDone THEN
				MachineState.NextState := AUTO_PICK_CAP;
			END_IF
		
		AUTO_PICK_CAP:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gPicker.Commands.Automatic.PickACap := TRUE;
			END_IF 
			
			IF NOT gPicker.Feedbacks.WaitingPickCommand THEN
				gPicker.Commands.Automatic.PickACap := FALSE;
			END_IF
			
			IF NOT gPicker.Commands.Automatic.PickACap AND gPicker.Feedbacks.PickACapDone THEN
				MachineState.NextState := AUTO_WAITING_CAP_DELIVERY;
			END_IF
			
		AUTO_WAITING_CAP_DELIVERY:	
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				gConveyor.Commands.Automatic.DeliverCap := TRUE;
				Internal.StamperOneTimeInterlock := FALSE;
			END_IF
			
			IF gConveyor.Feedbacks.CapsOnConveyor = 1 AND NOT Internal.StamperOneTimeInterlock THEN
				gStamper.Commands.Automatic.StampCap := TRUE;
				Internal.StamperOneTimeInterlock := TRUE;
			END_IF
						
			IF NOT gConveyor.Feedbacks.WaitingCap THEN
				gConveyor.Commands.Automatic.DeliverCap := FALSE;
			END_IF
			
			IF NOT gStamper.Feedbacks.WaitingCap THEN
				gStamper.Commands.Automatic.StampCap := FALSE;
			END_IF
			
			IF NOT gConveyor.Commands.Automatic.DeliverCap AND gConveyor.Feedbacks.DeliverCapDone THEN
				
				IF gStamper.Commands.Automatic.Start THEN
					
					IF NOT gStamper.Commands.Automatic.StampCap AND gStamper.Feedbacks.StampCapDone THEN
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
				ResetModulesManualCommands;
				gMainMachine.Commands.Reset := FALSE;
			END_IF
			
			IF EDGE(gMainMachine.Commands.Automatic.Init) THEN
				gMainMachine.Commands.Reset := gMainMachine.Commands.Automatic.Init; // User can reset alarms with init command	
			END_IF
			
			gPusher.Commands.Reset := gMainMachine.Commands.Reset;	
			gPicker.Commands.Reset := gMainMachine.Commands.Reset;	
			gConveyor.Commands.Reset := gMainMachine.Commands.Reset;	
			gStamper.Commands.Reset := gMainMachine.Commands.Reset;
						
			IF gMainMachine.Commands.Reset THEN
				gAlarms.MpAlarmXListUIConnect.AcknowledgeAll := TRUE;
			END_IF
			
			IF NOT MpAlarmXCheckReaction(gAlarmXCoreMpLink,'STOP') THEN
				
				gMainMachine.Commands.Reset := FALSE;
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