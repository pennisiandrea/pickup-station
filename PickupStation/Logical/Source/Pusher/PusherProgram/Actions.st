ACTION FeedbacksUpdateAction: 

	gPusher.Feedbacks.Enabled := TRUE;
    gPusher.Feedbacks.WaitingStart := MachineState.ActualState = WAITING_START; 
	gPusher.Feedbacks.Error := MachineState.ActualState = ERROR;
	gPusher.Feedbacks.WaitingTakeACapCommand := MachineState.ActualState = WAITING_TAKE_A_CAP_COMMAND;	
	gPusher.Feedbacks.CapReady := gPusher.Interface.Inputs.CapAtPickPosition;		
	gPusher.Feedbacks.InitPosition := gPusher.Interface.Inputs.PusherInBackwardPosition;
	gPusher.Feedbacks.InitDone := gPusher.Feedbacks.InitPosition AND gPusher.Commands.Automatic.Init;
	
END_ACTION

ACTION ResetOutputsAction: 

    memset(ADR(gPusher.Interface.Outputs),0,SIZEOF(gPusher.Interface.Outputs));

END_ACTION

ACTION ResetFeedbacksAction: 

    memset(ADR(gPusher.Feedbacks),0,SIZEOF(gPusher.Feedbacks));

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
	IF gPusher.Commands.Reset THEN
		Internal.Error := FALSE;
	END_IF
	
    // Timeouts alarms
	IF MachineState.TimeoutTimer.Q THEN  
		CASE MachineState.ActualState OF
			MOVE_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PusherTimeoutBackward'); // Edge alarm!
			MOVE_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PusherTimeoutForward'); // Edge alarm!
			WAITING_MAGAZINE: MpAlarmXSet(gAlarmXCoreMpLink,'PusherTimeoutMagazineEmpty'); // Edge alarm!
		END_CASE
		Internal.Error := TRUE;	
		MachineState.NextState := ERROR;	
	END_IF

	// PusherInvalidSensorsCombination
	IF gPusher.Interface.Inputs.PusherInBackwardPosition AND gPusher.Interface.Inputs.PusherInForwardPosition THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'PusherInvalidSensorsCombination'); // Periodic alarm!
		Internal.Error := TRUE;		
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'PusherInvalidSensorsCombination');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction: 
	
	MpAlarmXReset(gAlarmXCoreMpLink,'PusherInvalidSensorsCombination');
	
END_ACTION


