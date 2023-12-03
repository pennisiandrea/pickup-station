
ACTION AcknowledgeManagement: 
	
	IF gAlarms.Commands.Acknowledge OR (gMaster.Outputs.Reset AND gMainMachine.Feedbacks.LinkOk) THEN
		MpAlarmXAcknowledgeID(gAlarmXCoreMpLink, gAlarms.Commands.AlarmID);
	END_IF
	
	MpAlarmXListUIConnect.AcknowledgeAll := gAlarms.Commands.AcknowledgeAll OR (gMaster.Outputs.Reset AND gMainMachine.Feedbacks.LinkOk);
		
	IF gAlarms.Commands.Acknowledge OR gAlarms.Commands.AcknowledgeAll OR (gMaster.Outputs.Reset AND gMainMachine.Feedbacks.LinkOk)THEN
		gMainMachine.Commands.Reset := TRUE;
		gAlarms.Commands.AcknowledgeAll := FALSE;
		gAlarms.Commands.Acknowledge := FALSE;
	END_IF
	
END_ACTION
