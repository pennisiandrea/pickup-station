PROGRAM _INIT
        
    
END_PROGRAM

PROGRAM _CYCLIC
	
	// MainMachine -> Master 
	gMaster.Inputs.ClearStatsDone := gMainMachine.Feedbacks.ClearStatsDone;
	gMaster.Inputs.Error := gMainMachine.Feedbacks.Error;
	gMaster.Inputs.InitDone := gMainMachine.Feedbacks.InitDone;
	gMaster.Inputs.Started := gMainMachine.Feedbacks.Started;
	gMaster.Inputs.WaitingStart := gMainMachine.Feedbacks.WaitingStart;
	gMaster.Inputs.WaitingInit := gMainMachine.Feedbacks.WaitingInit;
	gMaster.Inputs.WaitingModeSelection := gMainMachine.Feedbacks.WaitModeSelection;
	gMaster.Inputs.HeartBeat := gMainMachine.Feedbacks.HeartBeat;
	gMaster.Inputs.ActStampIncluded := gMainMachine.Parameters.StamperEnable;
	gMaster.Inputs.ActStampOffset := gStamper.Parameters.Offset;
	gMaster.Inputs.LinkActive := gMainMachine.Commands.LinkMode;
	gMaster.Inputs.CapsOnConveyor := gMainMachine.Feedbacks.CapsOnConveyor;
	
	gMainMachine.Commands.HeartBeat := gMaster.Outputs.HeartBeat;
    	
	IF NOT gMainMachine.Commands.LinkMode THEN
		MpAlarmXReset(gAlarmXCoreMpLink,'MasterInError');		
		RETURN;
	END_IF
	
	// Master -> MainMachine
	gMainMachine.Commands.Reset := gMaster.Outputs.Reset;
	gMainMachine.Commands.ClearStats := gMaster.Outputs.ClearStats;
	
	gMainMachine.Commands.Automatic.Enable := gMaster.Outputs.AutomaticMode;	
	IF gMaster.Outputs.AutomaticMode THEN
		gMainMachine.Commands.Manual.Enable := FALSE;
	END_IF
	gMainMachine.Commands.Automatic.Init := gMaster.Outputs.Init;
	gMainMachine.Commands.Automatic.Start := gMaster.Outputs.Start;
	
	gConveyor.Parameters.TargetSpeed := gMaster.Outputs.ConveyorSpeed;
	gMainMachine.Parameters.StamperEnable := gMaster.Outputs.StampIncluded;
	gStamper.Parameters.Offset := gMaster.Outputs.StampOffset;
	
	IF EDGEPOS(gMaster.Outputs.Error) AND gAlarms.Feedbacks.Pendings = 0 THEN
		MpAlarmXSet(gAlarmXCoreMpLink,'MasterInError');
	END_IF
	
END_PROGRAM

PROGRAM _EXIT
	
    
END_PROGRAM