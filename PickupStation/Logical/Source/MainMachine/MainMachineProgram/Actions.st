ACTION FeedbacksUpdateAction: 

	gMainMachine.Feedbacks.WaitingStart := MachineState.ActualState = AUTO_WAITING_START; 
	
	gMainMachine.Feedbacks.Error := MachineState.ActualState = ERROR;
	
	gMainMachine.Feedbacks.WaitModeSelection := MachineState.ActualState = WAITING_MODE_SELECTION;
	
	gMainMachine.Feedbacks.Stopping := gMainMachine.Feedbacks.Started AND Internal.OnPhaseStopRequest;
	
	gMainMachine.Feedbacks.WaitingInit := MachineState.ActualState = AUTO_WAITING_INIT;
	
	// Started
	IF (MachineState.ActualState = AUTO_WAITING_MODULES_READY)
		OR (MachineState.ActualState = AUTO_PUSH_CAP)
		OR (MachineState.ActualState = AUTO_PICK_CAP)
		OR (MachineState.ActualState = AUTO_WAITING_CAP_DELIVERY) THEN
	
		gMainMachine.Feedbacks.Started := TRUE;
	ELSE
		gMainMachine.Feedbacks.Started := FALSE;
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
	IF MachineState.TimeoutTimer.Q THEN
        
		// Throw here timeout alarms
		//CASE MachineState.ActualState OF
		//    <STATE_1_WITH_TIMEOUT>: MpAlarmXSet(gAlarmXCoreMpLink,'<AlarmName>'); // Edge alarm!
		//    <STATE_2_WITH_TIMEOUT>: MpAlarmXSet(gAlarmXCoreMpLink,'<AlarmName>'); // Edge alarm!
		//END_CASE

		MachineState.NextState := ERROR;		
	END_IF 
	
	IF FALSE THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'MainMachineEmergencyCircuitInterrupted'); // Persistent alarm
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'MainMachineEmergencyCircuitInterrupted'); // Persistent alarm
	END_IF
	
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
	IF EDGE(gMainMachine.Commands.HeartBeat) THEN
		Internal.CommunicationTimeoutTimer.IN := FALSE;
		CommunicationInitialized := TRUE;
	ELSE
		Internal.CommunicationTimeoutTimer.IN := TRUE;
	END_IF
	Internal.CommunicationTimeoutTimer();
	Internal.MasterCommunicationOk := NOT Internal.CommunicationTimeoutTimer.Q AND CommunicationInitialized;
	
	gMainMachine.Feedbacks.LinkOk := Internal.MasterCommunicationOk;
	
END_ACTION

ACTION EnableModules:
	
	gPusher.Commands.Enable := TRUE;
	
	gPicker.Commands.Enable := TRUE;
	
	gConveyor.Commands.Enable := TRUE;
	
	IF MachineState.ActualState = WAITING_MODE_SELECTION THEN
		gStamper.Commands.Enable := gMainMachine.Parameters.StamperEnable;	
	END_IF
	
END_ACTION

ACTION StopModules:
	
	gPusher.Commands.Start := FALSE;
	gPusher.Commands.Init := FALSE;
	
	gPicker.Commands.Start := FALSE;
	gPicker.Commands.Init := FALSE;
	
	gConveyor.Commands.Start := FALSE;
	gConveyor.Commands.Init := FALSE;
	
	gStamper.Commands.Start := FALSE;
	gStamper.Commands.Init := FALSE;		
	
END_ACTION


ACTION CheckReactions:
	
	IF MpAlarmXCheckReaction(gAlarmXCoreMpLink,'MACHINE_IMMEDIATELY_STOP') THEN
		Internal.ErrorReaction := TRUE;
		MachineState.NextState := ERROR;
		
	ELSIF MpAlarmXCheckReaction(gAlarmXCoreMpLink,'MACHINE_ON_PHASE_STOP') THEN
		Internal.ErrorReaction := TRUE;
		Internal.OnPhaseStopRequest := TRUE;
		
	ELSE
		Internal.ErrorReaction := FALSE;
		Internal.OnPhaseStopRequest := FALSE;
	END_IF
	
END_ACTION