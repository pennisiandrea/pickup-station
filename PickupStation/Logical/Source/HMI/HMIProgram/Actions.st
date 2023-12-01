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

ACTION ManualPageAction: 
	
	// Manual button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF gMainMachine.Feedbacks.WaitModeSelection OR NOT gMainMachine.Feedbacks.Started THEN
		
			gHMI.ManualPage.ManualButtonEnable := TRUE;
			gMainMachine.Commands.ManualMode := gHMI.ManualPage.ManualButton;
		ELSE
			gHMI.ManualPage.ManualButtonEnable := FALSE;
		END_IF
	ELSE
		gHMI.ManualPage.ManualButtonEnable := FALSE;
		gHMI.ManualPage.ManualButton := FALSE;
	END_IF
	
	// Push button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.PushCapButtonEnable := TRUE;
		gPusher.Commands.PushManualCommand := gHMI.ManualPage.PushCapButton;

	ELSE
		gHMI.ManualPage.PushCapButtonEnable := FALSE;
		gHMI.ManualPage.PushCapButton := FALSE;
	END_IF
	
	// Picker forward button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ArmForwardButtonEnable := TRUE;
		gPicker.Commands.ForwardManualCommand := gHMI.ManualPage.ArmForwardButton;

	ELSE
		gHMI.ManualPage.ArmForwardButtonEnable := FALSE;
		gHMI.ManualPage.ArmForwardButton := FALSE;
	END_IF
	
	// Picker backward button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ArmBackwardButtonEnable := TRUE;
		gPicker.Commands.BackwardManualCommand := gHMI.ManualPage.ArmBackwardButton;

	ELSE
		gHMI.ManualPage.ArmBackwardButtonEnable := FALSE;
		gHMI.ManualPage.ArmBackwardButton := FALSE;
	END_IF
	
	// Picker vaacum button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ArmVaacumButtonEnable := TRUE;
		gPicker.Commands.VaacumManualCommand := gHMI.ManualPage.ArmVaacumButton;

	ELSE
		gHMI.ManualPage.ArmVaacumButtonEnable := FALSE;
		gHMI.ManualPage.ArmVaacumButton := FALSE;
	END_IF
	
	// Conveyor home button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorHomeButtonEnable := TRUE;
		gConveyor.Commands.HomeManualCommand := gHMI.ManualPage.ConveyorHomeButton;

	ELSE
		gHMI.ManualPage.ConveyorHomeButtonEnable := FALSE;
		gHMI.ManualPage.ConveyorHomeButton := FALSE;
	END_IF
	gHMI.ManualPage.ConveyorAxisHomed := gConveyor.Feedbacks.AxisHomed;
	
	// Conveyor power button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorPowerButtonEnable := gConveyor.Feedbacks.AxisHomed;
		gConveyor.Commands.PowerManualCommand := gHMI.ManualPage.ConveyorPowerButton;

	ELSE
		gHMI.ManualPage.ConveyorPowerButtonEnable := FALSE;
		gHMI.ManualPage.ConveyorPowerButton := FALSE;
	END_IF
	gHMI.ManualPage.ConveyorAxisPowered := gConveyor.Feedbacks.AxisPowered;
	
	// Conveyor jog button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorJogButtonEnable := gConveyor.Feedbacks.AxisHomed AND gConveyor.Feedbacks.AxisPowered;
		gConveyor.Commands.JogManualCommand := gHMI.ManualPage.ConveyorJogButton;

	ELSE
		gHMI.ManualPage.ConveyorJogButtonEnable := FALSE;
		gHMI.ManualPage.ConveyorJogButton := FALSE;
	END_IF
		
	// Conveyor speed slider button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorSpeedEnable := TRUE;
		gConveyor.Parameters.TargetSpeed := gHMI.ManualPage.ConveyorSpeed;
		
	ELSE
		gHMI.ManualPage.ConveyorSpeedEnable := FALSE;
		gHMI.ManualPage.ConveyorSpeed := gConveyor.Parameters.TargetSpeed;
	END_IF
END_ACTION
	