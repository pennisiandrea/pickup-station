ACTION FeedbacksUpdateAction: 

    gStamper.Feedbacks.Enabled := TRUE;
    gStamper.Feedbacks.WaitingStart := (MachineState.ActualState = WAITING_START); 
	gStamper.Feedbacks.Error := (MachineState.ActualState = ERROR);
	gStamper.Feedbacks.OnSyncMotion := Internal.Cam.InCam;
	gStamper.Feedbacks.WaitingCap := (Internal.Cam.ActualStateIndex = 0) AND (MachineState.ActualState = WAITING_CAP);	
	gStamper.Feedbacks.InitPosition := ABS(Internal.Axis.Position - Internal.Parameters.Position)<0.1;
	gStamper.Feedbacks.InitDone := gStamper.Feedbacks.InitPosition AND gStamper.Commands.Automatic.Init;
	gStamper.Feedbacks.AxisHomed := Internal.Axis.IsHomed;	
	gStamper.Feedbacks.AxisPowered := Internal.Axis.PowerOn;
	gStamper.Feedbacks.AxisSpeed := Internal.Axis.Velocity;
	gStamper.Feedbacks.AxisPosition := Internal.Axis.Position;
	
END_ACTION

ACTION ResetOutputsAction: 

    memset(ADR(gStamper.Interface.Outputs),0,SIZEOF(gStamper.Interface.Outputs));

END_ACTION

ACTION ResetFeedbacksAction: 

    memset(ADR(gStamper.Feedbacks),0,SIZEOF(gStamper.Feedbacks));

END_ACTION

ACTION ResetMotionCommands:
	Internal.Axis.Power := FALSE;
	Internal.Axis.Home := FALSE;
	Internal.Axis.MoveVelocity := FALSE;
	Internal.Axis.MoveAbsolute := FALSE;
	
	Internal.Cam.Enable := FALSE;
	Internal.Cam.Start := FALSE;
	
	Internal.Offset.Enable := FALSE;
	Internal.Offset.StartShift := FALSE;
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
	
	IF gStamper.Commands.Reset THEN
		Internal.Error := FALSE;
	END_IF
	
	IF MachineState.TimeoutTimer.Q THEN
        
		CASE MachineState.ActualState OF
			HOMING: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutHoming'); // Edge alarm!
			POWER_ON: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutPowerOn'); // Edge alarm!
			STAMP_FORWARD: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutStampForward'); // Edge alarm!
			STAMP_BACKWARD: MpAlarmXSet(gAlarmXCoreMpLink,'StamperTimeoutStampBackward'); // Edge alarm!
			ACTIVATE_CAM: MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisTimeout'); // Edge alarm!
			STAMPING: MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisTimeout'); // Edge alarm!
		END_CASE

		Internal.Error := TRUE;
		MachineState.NextState := ERROR;		
	END_IF 
	
	IF Internal.Axis.Error OR Internal.Cam.Error OR Internal.Offset.Error THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'StamperAxisError');
		Internal.Error := TRUE;
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'StamperAxisError');
	END_IF
	
	IF gStamper.Interface.Inputs.StampIsForward AND gStamper.Interface.Inputs.StampIsBackward THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'StamperInvalidSensorsCombination');
		Internal.Error := TRUE;
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'StamperInvalidSensorsCombination');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction:  
	
	MpAlarmXReset(gAlarmXCoreMpLink,'StamperInvalidSensorsCombination');
	
END_ACTION   

ACTION OffsetManagement:  
	
	Internal.Offset.Enable := Internal.Axis.Info.PLCopenState = mcAXIS_SYNCHRONIZED_MOTION;
	Internal.Offset.StartShift := (Internal.OffsetToDo OR Internal.LastOffset <> gStamper.Parameters.Offset) AND Internal.Offset.Valid;
	Internal.LastOffset := gStamper.Parameters.Offset;
	IF Internal.OffsetToDo AND Internal.Offset.StartShift THEN
		Internal.OffsetToDo := FALSE;
	END_IF
	
END_ACTION  