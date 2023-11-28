ACTION FeedbacksUpdateAction: 

    gPicker.Feedbacks.Enabled := TRUE;
    gPicker.Feedbacks.Waiting := MachineState.ActualState = WAITING_PICK_COMMAND; 
    gPicker.Feedbacks.Error := MachineState.ActualState = ERROR;
	
END_ACTION

ACTION ResetOutputsAction: 

    memset(ADR(gPicker.Interface.Outputs),0,SIZEOF(gPicker.Interface.Outputs));

END_ACTION

ACTION ResetFeedbacksAction: 

    memset(ADR(gPicker.Feedbacks),0,SIZEOF(gPicker.Feedbacks));

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
			ARM_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutBackward'); // Edge alarm!
			PLACE_CAP: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutVacuumPlace'); // Edge alarm!
			CAP_PUSHER_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'CapPusherTimeoutBackward'); // Edge alarm!
			WAITING_MAGAZINE: MpAlarmXSet(gAlarmXCoreMpLink,'MagazineEmptyTimeout'); // Edge alarm!
			PUSH_CAP: MpAlarmXSet(gAlarmXCoreMpLink,'CapPusherTimeoutForward'); // Edge alarm!
			ARM_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutForward'); // Edge alarm!
			PICK_CAP: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutVacuumPick'); // Edge alarm!
		END_CASE
		MachineState.NextState := ERROR;		
	END_IF
	
	// PickupArmInvalidSensorsCombination
	IF gPicker.Interface.Inputs.ArmBackward AND gPicker.Interface.Inputs.ArmForward AND gPicker.Commands.Enable THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmInvalidSensorsCombination'); // Periodic alarm!
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'PickupArmInvalidSensorsCombination');
	END_IF
	
	// CapPusherInvalidSensorCombination
	IF gPicker.Interface.Inputs.CapPusherBackward AND gPicker.Interface.Inputs.CapPusherForward AND gPicker.Commands.Enable THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'CapPusherInvalidSensorCombination'); // Periodic alarm!
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'CapPusherInvalidSensorCombination');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction: 
	
	MpAlarmXReset(gAlarmXCoreMpLink,'PickupArmInvalidSensorsCombination');
	MpAlarmXReset(gAlarmXCoreMpLink,'CapPusherInvalidSensorCombination');
	
END_ACTION