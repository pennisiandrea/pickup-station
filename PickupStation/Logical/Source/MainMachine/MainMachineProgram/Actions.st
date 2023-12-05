ACTION FeedbacksUpdateAction: 
	
	gMainMachine.Feedbacks.WaitingInit := MachineState.ActualState = AUTO_WAITING_INIT; 
	
	gMainMachine.Feedbacks.Initializing := MachineState.ActualState = AUTO_INITIALIZING; 
	
	gMainMachine.Feedbacks.WaitingStart := MachineState.ActualState = AUTO_WAITING_START; 
	
	gMainMachine.Feedbacks.WaitingModulesReady := MachineState.ActualState = AUTO_WAITING_MODULES_READY; 
	
	gMainMachine.Feedbacks.PushingCap := MachineState.ActualState = AUTO_PUSH_CAP; 
	
	gMainMachine.Feedbacks.PickingCap := MachineState.ActualState = AUTO_PICK_CAP; 
	
	gMainMachine.Feedbacks.DeliveringCap := MachineState.ActualState = AUTO_WAITING_CAP_DELIVERY; 
	
	gMainMachine.Feedbacks.Error := MachineState.ActualState = ERROR;
	
	gMainMachine.Feedbacks.WaitModeSelection := MachineState.ActualState = WAITING_MODE_SELECTION;
	
	gMainMachine.Feedbacks.Stopping := gMainMachine.Feedbacks.Started AND Internal.OnPhaseStopRequest;
	
	gMainMachine.Feedbacks.ManualMode := (MachineState.ActualState = MANUAL);
	
	gMainMachine.Feedbacks.AutomaticMode := NOT gMainMachine.Feedbacks.ManualMode AND NOT gMainMachine.Feedbacks.WaitModeSelection AND NOT gMainMachine.Feedbacks.Error;
		
	gMainMachine.Feedbacks.CapsOnConveyor := gConveyor.Feedbacks.CapsOnConveyor;
	
	IF gMainMachine.Commands.Automatic.Init AND gMainMachine.Feedbacks.CapsOnConveyor > 0 THEN
		gMainMachine.Feedbacks.AskRemoveCaps := TRUE;
	ELSIF gMainMachine.Commands.Automatic.CapsRemoved THEN
		gMainMachine.Feedbacks.AskRemoveCaps := FALSE;
	END_IF
	
	// Started
	IF (MachineState.ActualState = AUTO_WAITING_MODULES_READY)
		OR (MachineState.ActualState = AUTO_PUSH_CAP)
		OR (MachineState.ActualState = AUTO_PICK_CAP)
		OR (MachineState.ActualState = AUTO_WAITING_CAP_DELIVERY) THEN
	
		gMainMachine.Feedbacks.Started := TRUE;
	ELSE
		gMainMachine.Feedbacks.Started := FALSE;
	END_IF
	
	IF NOT gMainMachine.Feedbacks.Started THEN
		gMainMachine.Feedbacks.NewCapOnWork := FALSE;
	END_IF
	
	IF NOT gMainMachine.Commands.Automatic.Init THEN
		gMainMachine.Feedbacks.InitDone := FALSE;
	END_IF
END_ACTION

ACTION MachineStateManagementAction: 

    // Machine state timeout check
    MachineState.TimeoutTimer(IN := MachineState.TimeoutTimer.PT <> T#0S AND NOT MachineState.NewTriggerState);
      
	// Machine state change state logic
	MachineState.NewTriggerState := (MachineState.ActualState <> MachineState.NextState);
	IF MachineState.NewTriggerState THEN
		MachineState.OldState := MachineState.ActualState;
	END_IF
	MachineState.ActualState := MachineState.NextState;

END_ACTION

ACTION SetAlarmsAction:     
	
	// Timeouts
	IF MachineState.TimeoutTimer.Q THEN
        
		// Throw here timeout alarms
		CASE MachineState.ActualState OF
		    AUTO_INITIALIZING: MpAlarmXSet(gAlarmXCoreMpLink,'MainMachineInitializationTimeout'); // Edge alarm!
		END_CASE
		
		MachineState.NextState := ERROR;		
	END_IF 
	
	// MainMachineEmergencyCircuitInterrupted
	IF FALSE THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'MainMachineEmergencyCircuitInterrupted'); // Persistent alarm
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'MainMachineEmergencyCircuitInterrupted'); // Persistent alarm
	END_IF
	
	// MainMachineCommunicationLost
	IF NOT Internal.MasterCommunicationOk AND gMainMachine.Commands.LinkMode THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'MainMachineCommunicationLost'); // Persistent alarm
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'MainMachineCommunicationLost'); // Persistent alarm
	END_IF
	
END_ACTION

ACTION MasterCommunication: 
	
	// Send communication heart beat to the master
	Internal.HeartBeatTimer(IN:=NOT Internal.HeartBeatTimer.Q);
	IF Internal.HeartBeatTimer.Q THEN
		gMainMachine.Feedbacks.HeartBeat := NOT gMainMachine.Feedbacks.HeartBeat;
	END_IF
      
	// Check communication heart beat from the master
	IF EDGE(gMainMachine.Commands.HeartBeat) AND gMainMachine.Commands.OpcuaClientOk THEN
		Internal.CommunicationTimeoutTimer.IN := FALSE;
		CommunicationInitialized := TRUE;
	ELSE
		Internal.CommunicationTimeoutTimer.IN := TRUE;			
		IF Internal.CommunicationTimeoutTimer.Q THEN
			CommunicationInitialized := TRUE;
		END_IF
		
	END_IF
	
	Internal.CommunicationTimeoutTimer();
	
	Internal.MasterCommunicationOk := NOT Internal.CommunicationTimeoutTimer.Q AND CommunicationInitialized;
	gMainMachine.Feedbacks.LinkOk := Internal.MasterCommunicationOk;
	
END_ACTION

ACTION EnableModules:
	
	gPusher.Commands.Enable := TRUE;
	
	gPicker.Commands.Enable := TRUE;
	
	gConveyor.Commands.Enable := TRUE;
	
	gStamper.Commands.Enable := TRUE;	
	
END_ACTION

ACTION StopModules:
	
	gPusher.Commands.Manual.Enable := FALSE;
	gPusher.Commands.Automatic.Start := FALSE;
	gPusher.Commands.Automatic.Init := FALSE;
	gPusher.Commands.Reset := FALSE;
	gPusher.Commands.Automatic.TakeACap := FALSE;
	
	gPicker.Commands.Manual.Enable := FALSE;
	gPicker.Commands.Automatic.Start := FALSE;
	gPicker.Commands.Automatic.Init := FALSE;
	gPicker.Commands.Reset := FALSE;
	gPicker.Commands.Automatic.PickACap := FALSE;
	
	gConveyor.Commands.Manual.Enable := FALSE;
	gConveyor.Commands.Automatic.Start := FALSE;
	gConveyor.Commands.Automatic.Init := FALSE;
	gConveyor.Commands.Reset := FALSE;
	gConveyor.Commands.Automatic.DeliverCap := FALSE;
	
	gStamper.Commands.Manual.Enable := FALSE;
	gStamper.Commands.Automatic.Start := FALSE;
	gStamper.Commands.Automatic.Init := FALSE;
	gStamper.Commands.Reset := FALSE;
	gStamper.Commands.Automatic.StampCap := FALSE;		
	
END_ACTION

ACTION ResetModulesManualCommands:
	
	memset(ADR(gPusher.Commands.Manual),0,SIZEOF(gPusher.Commands.Manual));
	memset(ADR(gPicker.Commands.Manual),0,SIZEOF(gPicker.Commands.Manual));
	memset(ADR(gConveyor.Commands.Manual),0,SIZEOF(gConveyor.Commands.Manual));
	memset(ADR(gStamper.Commands.Manual),0,SIZEOF(gStamper.Commands.Manual));
		
END_ACTION

ACTION InitModules:
	
	gPusher.Commands.Automatic.Init := TRUE;	
	gPicker.Commands.Automatic.Init := TRUE;	
	gConveyor.Commands.Automatic.Init := TRUE;	
	gStamper.Commands.Automatic.Init := TRUE;		
	
END_ACTION

ACTION StartModules:
	
	gPusher.Commands.Automatic.Start := TRUE;	
	gPicker.Commands.Automatic.Start := TRUE;	
	gConveyor.Commands.Automatic.Start := TRUE;	
	gStamper.Commands.Automatic.Start := gMainMachine.Parameters.StamperEnable;		
	
END_ACTION

ACTION StatisticsAction: 
	
	// Stats clear
	IF gMainMachine.Commands.ClearStats THEN
		memset(ADR(CapsWorkingTimeHistory),0,SIZEOF(CapsWorkingTimeHistory));
		gMainMachine.Statistics.CapsCounter := 0;
		gMainMachine.Feedbacks.ClearStatsDone := TRUE;
		CapWorkStopwatch.IN := FALSE;
	ELSE
		gMainMachine.Feedbacks.ClearStatsDone := FALSE;
	END_IF
	
	// Manage the stopwatch to measure the current cap working time
	IF EDGE(gMainMachine.Feedbacks.NewCapOnWork) THEN
		IF gMainMachine.Feedbacks.NewCapOnWork THEN
			gMainMachine.Statistics.CapsCounter := gMainMachine.Statistics.CapsCounter + 1;
			CapWorkStopwatch.IN := TRUE;	
		ELSE
			CapWorkStopwatch.IN := FALSE;
			memmove(ADR(CapsWorkingTimeHistory[1]),ADR(CapsWorkingTimeHistory[0]),SIZEOF(CapsWorkingTimeHistory)-SIZEOF(CapsWorkingTimeHistory[0]));
			CapsWorkingTimeHistory[0] := CapWorkStopwatch.ET;
		END_IF
	END_IF	
	
	CapWorkStopwatch();	
		
	// Calc the total amount of time stored in the history array
	TotHistoryWorkedTime := T#0S;
	FOR Index:=0 TO STATS_HISTORY_MAX_INDEX DO
		IF CapsWorkingTimeHistory[Index]>T#0s THEN
			TotHistoryWorkedTime := TotHistoryWorkedTime + CapsWorkingTimeHistory[Index];
		ELSE
			EXIT;
		END_IF
	END_FOR
	
	gMainMachine.Statistics.CurrentCapWorkingTime := CapWorkStopwatch.ET; 
	gMainMachine.Statistics.LastCapWorkingTime := CapsWorkingTimeHistory[0];
	gMainMachine.Statistics.AverageCapWorkingTime := UDINT_TO_TIME(TIME_TO_UDINT(TotHistoryWorkedTime)/MAX(1,Index));
END_ACTION