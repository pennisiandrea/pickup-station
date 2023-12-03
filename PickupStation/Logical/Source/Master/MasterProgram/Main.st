PROGRAM _INIT
        
    
END_PROGRAM

PROGRAM _CYCLIC
    // Debug
	DebugHeartBeat(IN:=NOT DebugHeartBeat.Q,PT:=T#250MS);
	IF DebugHeartBeat.Q THEN
		gMaster.Outputs.HeartBeat := NOT gMaster.Outputs.HeartBeat;
	END_IF
	
	IF NOT gMainMachine.Commands.LinkMode THEN
		MpAlarmXReset(gAlarmXCoreMpLink,'MasterInError');
		RETURN;
	END_IF
	
	// MainMachine -> Master 
	gMaster.Inputs.ClearStatsDone := gMainMachine.Feedbacks.ClearStatsDone;
	gMaster.Inputs.Error := gMainMachine.Feedbacks.Error;
	gMaster.Inputs.HeartBeat := gMainMachine.Feedbacks.HeartBeat;
	gMaster.Inputs.InitDone := gMainMachine.Feedbacks.InitDone;
	gMaster.Inputs.Started := gMainMachine.Feedbacks.Started;
	gMaster.Inputs.WaitingStart := gMainMachine.Feedbacks.WaitingStart;
	gMaster.Inputs.WaitingInit := gMainMachine.Feedbacks.WaitingInit;
	gMaster.Inputs.WaitingModeSelection := gMainMachine.Feedbacks.WaitModeSelection;
	
	// Master -> MainMachine
	gMainMachine.Commands.Reset := gMaster.Outputs.Reset;
	gMainMachine.Commands.ClearStats := gMaster.Outputs.ClearStats;
	gMainMachine.Commands.HeartBeat := gMaster.Outputs.HeartBeat;
	
	gMainMachine.Commands.Automatic.Enable := gMaster.Outputs.AutomaticMode;
	gMainMachine.Commands.Automatic.Init := gMaster.Outputs.Init;
	gMainMachine.Commands.Automatic.Start := gMaster.Outputs.Start;
	
	gConveyor.Parameters.TargetSpeed := gMaster.Outputs.ConveyorSpeed;
	gMainMachine.Parameters.StamperEnable := gMaster.Outputs.StampIncluded;
	gStamper.Parameters.Offset := gMaster.Outputs.StampOffset;
	
	IF gMaster.Outputs.Error THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'MasterInError');
	ELSE
		MpAlarmXReset(gAlarmXCoreMpLink,'MasterInError');
	END_IF
	
END_PROGRAM

PROGRAM _EXIT
	
    
END_PROGRAM