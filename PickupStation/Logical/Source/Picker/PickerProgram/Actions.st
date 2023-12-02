ACTION FeedbacksUpdateAction: 

	gPicker.Feedbacks.Enabled := TRUE;
    gPicker.Feedbacks.WaitingPickCommand := MachineState.ActualState = WAITING_PICK_COMMAND; 
    gPicker.Feedbacks.Error := MachineState.ActualState = ERROR;		
	gPicker.Feedbacks.InitPosition := gPicker.Interface.Inputs.ArmBackward AND NOT gPicker.Interface.Inputs.GripperVacuum;
	gPicker.Feedbacks.InitDone := gPicker.Feedbacks.InitPosition AND gPicker.Commands.Automatic.Init;

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
	 
	IF gPicker.Commands.Reset THEN
		Internal.Error := FALSE;
	END_IF
	
	// Timeouts alarms
	IF MachineState.TimeoutTimer.Q THEN  
		CASE MachineState.ActualState OF
			MOVE_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PickerTimeoutBackward'); // Edge alarm!
			MOVE_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'PickerTimeoutForward'); // Edge alarm!
			PLACE_CAP: MpAlarmXSet(gAlarmXCoreMpLink,'PickerTimeoutVacuumPlace'); // Edge alarm!
			PICK_CAP: MpAlarmXSet(gAlarmXCoreMpLink,'PickerTimeoutVacuumPick'); // Edge alarm!
		END_CASE
		Internal.Error := TRUE;		
		MachineState.NextState := ERROR;		
	END_IF
	
	// PickupArmInvalidSensorsCombination
	IF gPicker.Interface.Inputs.ArmBackward AND gPicker.Interface.Inputs.ArmForward THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'PickerInvalidSensorsCombination'); // Periodic alarm!
		Internal.Error := TRUE;
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'PickerInvalidSensorsCombination');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction: 
	
	MpAlarmXReset(gAlarmXCoreMpLink,'PickerInvalidSensorsCombination');
	
END_ACTION
