
PROGRAM _INIT
	// This program is used to manage the machine alarms. Alarms are set/reset in the modules.
	
	MpAlarmXCoreFB(MpLink := ADR(gAlarmXCoreMpLink), Enable := TRUE);	
	
	MpAlarmXHistoryFB(MpLink := ADR(gAlarmXCoreHistMpLink), Enable := TRUE, DeviceName := ADR('ALARMS'));
	
	MpAlarmXListUIFB(MpLink :=  ADR(gAlarmXCoreMpLink), Enable := TRUE, UIConnect := ADR(MpAlarmXListUIConnect));
	
	MpAlarmXAcknowledgeAllFB(MpLink :=  ADR(gAlarmXCoreMpLink), Enable := TRUE);
END_PROGRAM

PROGRAM _CYCLIC
	MpAlarmXCoreFB(ErrorReset := gMain.Commands.Reset AND MpAlarmXCoreFB.Error);
			
	MpAlarmXHistoryFB();
	
	MpAlarmXListUIFB();
	
	gAlarms.Pending := MpAlarmXCoreFB.PendingAlarms;
	
	MpAlarmXAcknowledgeAllFB(Execute := gSimulationPanel.Interface.Inputs.diStart AND gAlarms.Pending>0);
	
END_PROGRAM

PROGRAM _EXIT
	MpAlarmXCoreFB.Enable := FALSE;
	MpAlarmXCoreFB();
		
	MpAlarmXHistoryFB.Enable := FALSE;
	MpAlarmXHistoryFB();
		
	MpAlarmXListUIFB.Enable := FALSE;
	MpAlarmXListUIFB();
		
	MpAlarmXAcknowledgeAllFB.Enable := FALSE;
	MpAlarmXAcknowledgeAllFB();
	 
END_PROGRAM
