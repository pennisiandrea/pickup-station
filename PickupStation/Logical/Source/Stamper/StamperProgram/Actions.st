ACTION FeedbacksUpdateAction: 

    gStamper.Feedbacks.Enabled := TRUE;
    gStamper.Feedbacks.Waiting := (MachineState.ActualState = WAITING); 
	gStamper.Feedbacks.Error := (MachineState.ActualState = ERROR);
	gStamper.Feedbacks.OnSyncMotion := Internal.Cam.InCam;
END_ACTION

ACTION ResetOutputsAction: 

    memset(ADR(gStamper.Interface.Outputs),0,SIZEOF(gStamper.Interface.Outputs));

END_ACTION

ACTION ResetFeedbacksAction: 

    memset(ADR(gStamper.Feedbacks),0,SIZEOF(gStamper.Feedbacks));

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
        
		CASE MachineState.ActualState OF
			HOMING: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutHoming'); // Edge alarm!
			POWER_ON: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutPowerOn'); // Edge alarm!
			STAMP_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutStampForward'); // Edge alarm!
			STAMP_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutStampBackward'); // Edge alarm!
			ACTIVATE_CAM: MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisTimeout'); // Edge alarm!
			SET_SHIFT: MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisTimeout'); // Edge alarm!
			RESET_SHIFT: MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisTimeout'); // Edge alarm!
		END_CASE

		MachineState.NextState := ERROR;		
	END_IF 

	IF Internal.Axis.Error OR Internal.Cam.Error OR Internal.Offset.Error THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisFault');
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'StamperAxisFault');
	END_IF
	
	IF gStamper.Interface.Inputs.StampIsForward AND gStamper.Interface.Inputs.StampIsBackward THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'StamperInvalidSensorsCombination');
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'StamperInvalidSensorsCombination');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction:  
	
	MpAlarmXReset(gAlarmXCoreMpLink,'StamperAxisFault');
	MpAlarmXReset(gAlarmXCoreMpLink,'StamperInvalidSensorsCombination');
	
END_ACTION   