
PROGRAM _INIT
	// This program is used to manage the machine alarms. Alarms are set/reset in the modules.
	
	MpAlarmXCoreFB(MpLink := ADR(gAlarmXCoreMpLink), Enable := TRUE);	
	
	MpAlarmXHistoryFB(MpLink := ADR(gAlarmXHistoryMpLink), Enable := TRUE, DeviceName := ADR('ALARMS'));
	
	MpAlarmXListUIFB(MpLink :=  ADR(gAlarmXCoreMpLink), Enable := TRUE, UIConnect := ADR(MpAlarmXListUIConnect));
	
	MpAlarmXAcknowledgeAllFB(MpLink :=  ADR(gAlarmXCoreMpLink), Enable := TRUE);
END_PROGRAM

PROGRAM _CYCLIC
	MpAlarmXCoreFB();
			
	MpAlarmXHistoryFB();
	
	MpAlarmXListUIFB();
	
	gAlarms.Pending := MpAlarmXCoreFB.PendingAlarms;
	
	MpAlarmXAcknowledgeAllFB();
	
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

