ACTION FeedbacksUpdateAction: 

    gConveyor.Feedbacks.Enabled := TRUE;
    gConveyor.Feedbacks.WaitingStart := MachineState.ActualState = WAITING_START; 
    gConveyor.Feedbacks.Error := MachineState.ActualState = ERROR;
	gConveyor.Feedbacks.WaitingCap := NOT gConveyor.Interface.Inputs.CapInStartPosition;
	gConveyor.Feedbacks.NewCapTrigger := EDGENEG(gConveyor.Interface.Inputs.CapInStartPosition);
	
END_ACTION

ACTION ResetOutputsAction: 

    memset(ADR(gConveyor.Interface.Outputs),0,SIZEOF(gConveyor.Interface.Outputs));

END_ACTION

ACTION ResetFeedbacksAction: 

    memset(ADR(gConveyor.Feedbacks),0,SIZEOF(gConveyor.Feedbacks));

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
			HOMING: 
				MpAlarmXSet(gAlarmXCoreMpLink,'ConveyorTimeoutHoming'); // Edge alarm!
				MachineState.NextState := ERROR;
				
			POWER_ON: 
				MpAlarmXSet(gAlarmXCoreMpLink,'ConveyorTimeoutPowerOn'); // Edge alarm!
				MachineState.NextState := ERROR;
				
			MOTION: 
				MpAlarmXSet(gAlarmXCoreMpLink,'ConveyorMissedCap'); // Edge alarm! NO ERROR STATE IN THIS CASE
				Internal.CapsCount := MAX(0,Internal.CapsCount - 1);
				
			INIT: 
				MpAlarmXSet(gAlarmXCoreMpLink,'ConveyorInitFail'); // Edge alarm!
				MachineState.NextState := ERROR;
		END_CASE
		
	END_IF            

	IF Internal.Axis.Error THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'ConveyorAxisError');
		MachineState.NextState := ERROR;
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'ConveyorAxisError');
	END_IF
	
END_ACTION

ACTION ResetAlarmsAction:
	
	MpAlarmXReset(gAlarmXCoreMpLink,'ConveyorAxisError');
	
END_ACTION