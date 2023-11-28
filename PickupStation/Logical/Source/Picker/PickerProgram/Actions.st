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
			MOVE_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutBackward'); // Edge alarm!
			MOVE_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutForward'); // Edge alarm!
			PLACE_CAP: MpAlarmXSet(gAlarmXCoreMpLink,'PickupArmTimeoutVacuumPlace'); // Edge alarm!
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
	
END_ACTION

ACTION ResetAlarmsAction: 
	
	MpAlarmXReset(gAlarmXCoreMpLink,'PickupArmInvalidSensorsCombination');
	
END_ACTION
