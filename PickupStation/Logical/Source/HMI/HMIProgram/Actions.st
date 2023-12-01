ACTION AutomaticPageAction: 
	
	// Init button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF gMainMachine.Feedbacks.WaitingInit THEN
		
			gHMI.AutomaticPage.InitButtonEnable := TRUE;
		ELSE
			gHMI.AutomaticPage.InitButtonEnable := FALSE;
			gHMI.AutomaticPage.InitButton := FALSE;
		END_IF
		gMainMachine.Commands.Init := gHMI.AutomaticPage.InitButton;
	ELSE
		gHMI.AutomaticPage.InitButtonEnable := FALSE;
		gHMI.AutomaticPage.InitButton := FALSE;
	END_IF
		
	// Start button
	IF NOT gMainMachine.Commands.LinkMode THEN
		
		IF gMainMachine.Feedbacks.WaitingStart THEN
			
			gHMI.AutomaticPage.StartButtonEnable := TRUE;
			gHMI.AutomaticPage.StopButtonVisibility := FALSE;		
			
		ELSIF gMainMachine.Feedbacks.Started AND gMainMachine.Commands.Start THEN		
		
			gHMI.AutomaticPage.StartButtonEnable := FALSE;
			gHMI.AutomaticPage.StopButtonVisibility := TRUE;			
		ELSE
			gHMI.AutomaticPage.StartButtonEnable := FALSE;
			gHMI.AutomaticPage.StopButtonVisibility := FALSE;
			gHMI.AutomaticPage.StartButton := FALSE;
		END_IF
		
		gMainMachine.Commands.Start := gHMI.AutomaticPage.StartButton;
		
	ELSE
		gHMI.AutomaticPage.StartButtonEnable := FALSE;
		gHMI.AutomaticPage.StopButtonVisibility := FALSE;
		gHMI.AutomaticPage.StartButton := FALSE;
	END_IF
		
	// Auto button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF gMainMachine.Feedbacks.WaitModeSelection OR NOT gMainMachine.Feedbacks.Started THEN
		
			gHMI.AutomaticPage.AutoButtonEnable := TRUE;
			gMainMachine.Commands.AutomaticMode := gHMI.AutomaticPage.AutoButton;
		ELSE
			gHMI.AutomaticPage.AutoButtonEnable := FALSE;
		END_IF
	ELSE
		gHMI.AutomaticPage.AutoButtonEnable := FALSE;
		gHMI.AutomaticPage.AutoButton := FALSE;
	END_IF
		
	// Link button
	IF gMainMachine.Feedbacks.WaitModeSelection THEN
		gHMI.AutomaticPage.LinkButtonEnable := TRUE;
		gHMI.AutomaticPage.LinkButton := gHMI.AutomaticPage.LinkButton;
	ELSE
		gHMI.AutomaticPage.LinkButtonEnable := FALSE;
	END_IF
	
	// Conveyor speed slider button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF NOT gMainMachine.Feedbacks.Started THEN
			gHMI.AutomaticPage.ConveyorSpeedEnable := TRUE;
			gConveyor.Parameters.TargetSpeed := gHMI.AutomaticPage.ConveyorSpeed;
		ELSE
			gHMI.AutomaticPage.ConveyorSpeedEnable := FALSE;
		END_IF
	ELSE
		gHMI.AutomaticPage.ConveyorSpeedEnable := FALSE;
		gHMI.AutomaticPage.ConveyorSpeed := gConveyor.Parameters.TargetSpeed;
	END_IF
	
	// Ready to start
	gHMI.AutomaticPage.ReadyToStartVisibility := gMainMachine.Feedbacks.WaitingStart;
	
	// Clear statistics button	
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF NOT gMainMachine.Feedbacks.ClearStatsDone THEN
			gMainMachine.Commands.ClearStats := gHMI.AutomaticPage.ClearStats;
		ELSE
			gMainMachine.Commands.ClearStats := FALSE;
			gHMI.AutomaticPage.ClearStats := FALSE;
		END_IF
	END_IF
	
	// Statistics	
	gHMI.AutomaticPage.CurrentCapWorkingTime := TIME_TO_UDINT(gMainMachine.Statistics.CurrentCapWorkingTime);
	gHMI.AutomaticPage.LastCapWorkedTime := TIME_TO_UDINT(gMainMachine.Statistics.LastCapWorkingTime);
	gHMI.AutomaticPage.AvgCapWorkTime := TIME_TO_UDINT(gMainMachine.Statistics.AverageCapWorkingTime);
	
END_ACTION

	
ACTION HeaderContentAction: 
	
	gHMI.HeaderContent.PendingAlarms := UDINT_TO_STRING(MIN(999,gAlarms.Feedbacks.Pendings));
	
	gHMI.HeaderContent.MasterConnectionOk := gMainMachine.Feedbacks.LinkOk;
	
END_ACTION