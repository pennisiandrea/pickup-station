ACTION FeedbacksUpdateAction: 

    gPusher.Feedbacks.Enabled := TRUE;
    gPusher.Feedbacks.Waiting := MachineState.ActualState = WAITING_START; 
    gPusher.Feedbacks.Error := MachineState.ActualState = ERROR;

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
    // Timeouts alarms
	IF MachineState.TimeoutTimer.Q THEN  
		CASE MachineState.ActualState OF
			MOVE_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PusherTimeoutBackward'); // Edge alarm!
			MOVE_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PusherTimeoutForward'); // Edge alarm!
			WAITING_MAGAZINE: MpAlarmXSet(gAlarmXCoreMpLink,'PusherTimeoutMagazineEmpty'); // Edge alarm!
		END_CASE
		MachineState.NextState := ERROR;		
	END_IF

	// PusherInvalidSensorsCombination
	IF gPusher.Interface.Inputs.PusherInBackwardPosition AND gPusher.Interface.Inputs.PusherInForwardPosition THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'PusherInvalidSensorsCombination'); // Periodic alarm!
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'PusherInvalidSensorsCombination');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction: 
	
	MpAlarmXReset(gAlarmXCoreMpLink,'PusherInvalidSensorsCombination');
	
END_ACTION


