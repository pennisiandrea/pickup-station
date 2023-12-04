ACTION SetInitialValuesAction:
	
	gHMI.AutomaticPage.StamperOffset := gStamper.Parameters.Offset;
	gHMI.AutomaticPage.ConveyorSpeed := gConveyor.Parameters.TargetSpeed;
	gHMI.AutomaticPage.StamperIncludedCheckbox := gMainMachine.Parameters.StamperEnable;
	gHMI.ManualPage.ConveyorAcceleration := gConveyor.Parameters.Acceleration;
	gHMI.ManualPage.ConveyorSpeed := gConveyor.Commands.Manual.Speed;
	gHMI.ManualPage.StamperPosition := gStamper.Commands.Manual.Position;
	gHMI.ManualPage.StamperSpeed := gStamper.Commands.Manual.Speed;
	
END_ACTION

ACTION AutomaticPageAction: 
			
	// Link button
	IF gMainMachine.Feedbacks.WaitModeSelection 
		OR gMainMachine.Feedbacks.Error 
		OR gMainMachine.Feedbacks.WaitingInit 
		OR gMainMachine.Feedbacks.WaitingStart 
		OR gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.AutomaticPage.LinkButtonEnable := TRUE;
		gMainMachine.Commands.LinkMode := gHMI.AutomaticPage.LinkButton;
	ELSE
		gHMI.AutomaticPage.LinkButtonEnable := FALSE;
	END_IF			
	
	// Init button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF gMainMachine.Feedbacks.WaitingInit OR gMainMachine.Feedbacks.Error THEN
		
			gHMI.AutomaticPage.InitButtonEnable := TRUE;
		ELSE
			gHMI.AutomaticPage.InitButtonEnable := FALSE;
			gHMI.AutomaticPage.InitButton := FALSE;
		END_IF
		gMainMachine.Commands.Automatic.Init := gHMI.AutomaticPage.InitButton;
	ELSE
		gHMI.AutomaticPage.InitButtonEnable := FALSE;
		gHMI.AutomaticPage.InitButton := FALSE;
	END_IF
	IF EDGEPOS(gMainMachine.Commands.Automatic.Init) THEN
		gHMI.AutomaticPage.AutoButton := TRUE;
	END_IF
	
	// Auto button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF gMainMachine.Feedbacks.WaitModeSelection OR NOT gMainMachine.Feedbacks.Started THEN
		
			gHMI.AutomaticPage.AutoButtonEnable := TRUE;
			gMainMachine.Commands.Automatic.Enable := gHMI.AutomaticPage.AutoButton;
		ELSE
			gHMI.AutomaticPage.AutoButtonEnable := FALSE;
		END_IF
	ELSE
		gHMI.AutomaticPage.AutoButtonEnable := FALSE;
		gHMI.AutomaticPage.AutoButton := FALSE;
	END_IF
	IF EDGEPOS(gMainMachine.Commands.Automatic.Enable) THEN
		gHMI.ManualPage.ManualButton := FALSE;
	END_IF
		
	// Start button
	IF NOT gMainMachine.Commands.LinkMode THEN
		
		IF gMainMachine.Feedbacks.WaitingStart THEN
			
			gHMI.AutomaticPage.StartButtonEnable := TRUE;
			gHMI.AutomaticPage.StopButtonVisibility := FALSE;		
			
		ELSIF gMainMachine.Feedbacks.Started AND gMainMachine.Commands.Automatic.Start THEN		
		
			gHMI.AutomaticPage.StartButtonEnable := FALSE;
			gHMI.AutomaticPage.StopButtonVisibility := TRUE;			
		ELSE
			gHMI.AutomaticPage.StartButtonEnable := FALSE;
			gHMI.AutomaticPage.StopButtonVisibility := FALSE;
			gHMI.AutomaticPage.StartButton := FALSE;
		END_IF
		
		gMainMachine.Commands.Automatic.Start := gHMI.AutomaticPage.StartButton;
		
	ELSE
		gHMI.AutomaticPage.StartButtonEnable := FALSE;
		gHMI.AutomaticPage.StopButtonVisibility := FALSE;
		gHMI.AutomaticPage.StartButton := FALSE;
	END_IF
	
	// Conveyor speed slider button
	IF gHMI.AutomaticPage.ConveyorSpeed = 0 THEN
		gHMI.AutomaticPage.ConveyorSpeed := gConveyor.Parameters.TargetSpeed;
	END_IF
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
	gHMI.AutomaticPage.CapsCounter := gMainMachine.Statistics.CapsCounter;
	gHMI.AutomaticPage.CurrentCapWorkingTime := TIME_TO_UDINT(gMainMachine.Statistics.CurrentCapWorkingTime);
	gHMI.AutomaticPage.LastCapWorkedTime := TIME_TO_UDINT(gMainMachine.Statistics.LastCapWorkingTime);
	gHMI.AutomaticPage.AvgCapWorkTime := TIME_TO_UDINT(gMainMachine.Statistics.AverageCapWorkingTime);
		
	// Stamper offset slider button
	IF NOT gMainMachine.Commands.LinkMode THEN
		
		gHMI.AutomaticPage.StamperOffsetEnable := TRUE;
		gStamper.Parameters.Offset := gHMI.AutomaticPage.StamperOffset;
		
	ELSE
		gHMI.AutomaticPage.StamperOffsetEnable := FALSE;
		gHMI.AutomaticPage.StamperOffset := gStamper.Parameters.Offset;
	END_IF
	
	// Stamper inclusion
	IF NOT gMainMachine.Commands.LinkMode THEN
		gHMI.AutomaticPage.StamperIncludedCheckboxEnable := TRUE;
		gMainMachine.Parameters.StamperEnable := gHMI.AutomaticPage.StamperIncludedCheckbox;
	ELSE
		gHMI.AutomaticPage.StamperIncludedCheckboxEnable := FALSE;
		gHMI.AutomaticPage.StamperIncludedCheckbox := gMainMachine.Parameters.StamperEnable;
	END_IF
	
END_ACTION

	
ACTION HeaderContentAction: 
	
	gHMI.HeaderContent.PendingAlarms := UDINT_TO_STRING(MIN(999,gAlarms.Feedbacks.Pendings));
	
	gHMI.HeaderContent.MasterConnectionOk := gMainMachine.Feedbacks.LinkOk;
	
	gHMI.HeaderContent.StateWaitModeSelection := gMainMachine.Feedbacks.WaitModeSelection;
	gHMI.HeaderContent.StateManual := gMainMachine.Feedbacks.ManualMode;
	gHMI.HeaderContent.StateDeliveringCap := gMainMachine.Feedbacks.DeliveringCap;
	gHMI.HeaderContent.StateError := gMainMachine.Feedbacks.Error;
	gHMI.HeaderContent.StateInitializing := gMainMachine.Feedbacks.Initializing;
	gHMI.HeaderContent.StatePickingCap := gMainMachine.Feedbacks.PickingCap;
	gHMI.HeaderContent.StatePushingCap := gMainMachine.Feedbacks.PushingCap;
	gHMI.HeaderContent.StateDeliveringCap := gMainMachine.Feedbacks.DeliveringCap;
	gHMI.HeaderContent.StateWaitingModulesReady := gMainMachine.Feedbacks.WaitingModulesReady;
	gHMI.HeaderContent.StateWaitingStart := gMainMachine.Feedbacks.WaitingStart;
	gHMI.HeaderContent.StateWaitingInit := gMainMachine.Feedbacks.WaitingInit;
	
	IF gMainMachine.Feedbacks.Error AND NOT gMainMachine.Commands.LinkMode THEN
		IF gHMI.HeaderContent.ResetAlarms THEN
			gMainMachine.Commands.Reset := TRUE;
		END_IF 
	ELSE
		gHMI.HeaderContent.ResetAlarms := FALSE;
	END_IF
	
END_ACTION

ACTION ManualPageAction: 
	
	// Manual button
	IF NOT gMainMachine.Commands.LinkMode THEN
		IF gMainMachine.Feedbacks.WaitModeSelection OR NOT gMainMachine.Feedbacks.Started THEN
		
			gHMI.ManualPage.ManualButtonEnable := TRUE;
			gMainMachine.Commands.Manual.Enable := gHMI.ManualPage.ManualButton;
		ELSE
			gHMI.ManualPage.ManualButtonEnable := FALSE;
		END_IF
	ELSE
		gHMI.ManualPage.ManualButtonEnable := FALSE;
		gHMI.ManualPage.ManualButton := FALSE;
	END_IF
	IF EDGEPOS(gMainMachine.Commands.Manual.Enable) THEN
		gHMI.AutomaticPage.AutoButton := FALSE;
	END_IF
	
	// Push button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.PushCapButtonEnable := NOT (gPusher.Interface.Inputs.CapAtPickPosition XOR gPusher.Interface.Inputs.MagazineEmpty);
		gPusher.Commands.Manual.Push := gHMI.ManualPage.PushCapButton;

	ELSE
		gHMI.ManualPage.PushCapButtonEnable := FALSE;
		gHMI.ManualPage.PushCapButton := FALSE;
	END_IF
	
	// Picker forward button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ArmForwardButtonEnable := NOT gPusher.Interface.Inputs.CapAtPickPosition OR (gPusher.Interface.Inputs.CapAtPickPosition AND NOT gPicker.Commands.Manual.ActivateGrip);
		gPicker.Commands.Manual.MoveForward := gHMI.ManualPage.ArmForwardButton;

	ELSE
		gHMI.ManualPage.ArmForwardButtonEnable := FALSE;
		gHMI.ManualPage.ArmForwardButton := FALSE;
	END_IF
	
	// Picker backward button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ArmBackwardButtonEnable := NOT gHMI.ManualPage.ArmForwardButton AND NOT gConveyor.Interface.Inputs.CapInStartPosition;
		gPicker.Commands.Manual.MoveBackward := gHMI.ManualPage.ArmBackwardButton;

	ELSE
		gHMI.ManualPage.ArmBackwardButtonEnable := FALSE;
		gHMI.ManualPage.ArmBackwardButton := FALSE;
	END_IF
	
	// Picker vaacum button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ArmVaacumButtonEnable := (gPusher.Interface.Inputs.CapAtPickPosition AND gPicker.Interface.Inputs.ArmForward) OR (gPicker.Interface.Inputs.ArmBackward AND gPicker.Commands.Manual.ActivateGrip);
		gPicker.Commands.Manual.ActivateGrip := gHMI.ManualPage.ArmVaacumButton;

	ELSE
		gHMI.ManualPage.ArmVaacumButtonEnable := FALSE;
		gHMI.ManualPage.ArmVaacumButton := FALSE;
	END_IF
	
	// Conveyor home button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorHomeButtonEnable := TRUE;
		gConveyor.Commands.Manual.Home := gHMI.ManualPage.ConveyorHomeButton;

	ELSE
		gHMI.ManualPage.ConveyorHomeButtonEnable := FALSE;
		gHMI.ManualPage.ConveyorHomeButton := FALSE;
	END_IF
	gHMI.ManualPage.ConveyorAxisHomed := gConveyor.Feedbacks.AxisHomed;
	
	// Conveyor power button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorPowerButtonEnable := gConveyor.Feedbacks.AxisHomed;
		gConveyor.Commands.Manual.PowerOn := gHMI.ManualPage.ConveyorPowerButton;

	ELSE
		gHMI.ManualPage.ConveyorPowerButtonEnable := FALSE;
		gHMI.ManualPage.ConveyorPowerButton := FALSE;
	END_IF
	gHMI.ManualPage.ConveyorAxisPowered := gConveyor.Feedbacks.AxisPowered;
	
	// Conveyor move button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorMoveButtonEnable := gConveyor.Feedbacks.AxisHomed AND gConveyor.Feedbacks.AxisPowered AND (gConveyor.Commands.Manual.Speed>0 OR NOT gConveyor.Interface.Inputs.CapInStartPosition);
		gConveyor.Commands.Manual.Move := gHMI.ManualPage.ConveyorMoveButton;

	ELSE
		gHMI.ManualPage.ConveyorMoveButtonEnable := FALSE;
		gHMI.ManualPage.ConveyorMoveButton := FALSE;
	END_IF
		
	// Conveyor speed
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorSpeedEnable := NOT gConveyor.Commands.Manual.Move;
		gConveyor.Commands.Manual.Speed := gHMI.ManualPage.ConveyorSpeed;
		
	ELSE
		gHMI.ManualPage.ConveyorSpeedEnable := FALSE;
		gHMI.ManualPage.ConveyorSpeed := gConveyor.Commands.Manual.Speed;
	END_IF
		
	// Conveyor acceleration
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.ConveyorAccelerationEnable := NOT gConveyor.Commands.Manual.Move;
		gConveyor.Parameters.Acceleration := gHMI.ManualPage.ConveyorAcceleration;
	ELSE
		gHMI.ManualPage.ConveyorAccelerationEnable := FALSE;
		gHMI.ManualPage.ConveyorAcceleration := gConveyor.Parameters.Acceleration;
	END_IF
	
	// Stamper home button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.StamperHomeButtonEnable := TRUE;
		gStamper.Commands.Manual.Home := gHMI.ManualPage.StamperHomeButton;

	ELSE
		gHMI.ManualPage.StamperHomeButtonEnable := FALSE;
		gHMI.ManualPage.StamperHomeButton := FALSE;
	END_IF
	gHMI.ManualPage.StamperAxisHomed := gStamper.Feedbacks.AxisHomed;
	
	// Stamper power button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.StamperPowerButtonEnable := gStamper.Feedbacks.AxisHomed;
		gStamper.Commands.Manual.PowerOn := gHMI.ManualPage.StamperPowerButton;

	ELSE
		gHMI.ManualPage.StamperPowerButtonEnable := FALSE;
		gHMI.ManualPage.StamperPowerButton := FALSE;
	END_IF
	gHMI.ManualPage.StamperAxisPowered := gStamper.Feedbacks.AxisPowered;
	
	// Stamper move button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.StamperMoveButtonEnable := gStamper.Feedbacks.AxisHomed AND gStamper.Feedbacks.AxisPowered;
		gStamper.Commands.Manual.Move := gHMI.ManualPage.StamperMoveButton;

	ELSE
		gHMI.ManualPage.StamperMoveButtonEnable := FALSE;
		gHMI.ManualPage.StamperMoveButton := FALSE;
	END_IF
		
	// Stamper speed 
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.StamperSpeedEnable := NOT gStamper.Commands.Manual.Move;
		gStamper.Commands.Manual.Speed := gHMI.ManualPage.StamperSpeed;
		
	ELSE
		gHMI.ManualPage.StamperSpeedEnable := FALSE;
		gHMI.ManualPage.StamperSpeed := gStamper.Commands.Manual.Speed;
	END_IF
				
	// Stamper acceleration
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.StamperAccelerationEnable := NOT gConveyor.Commands.Manual.Move;
		gStamper.Parameters.Acceleration := gHMI.ManualPage.StamperAcceleration;
	ELSE
		gHMI.ManualPage.StamperAccelerationEnable := FALSE;
		gHMI.ManualPage.StamperAcceleration := gStamper.Parameters.Acceleration;
	END_IF
	
	// Stamper position slider button
	IF NOT gMainMachine.Commands.LinkMode AND gMainMachine.Feedbacks.ManualMode THEN
		
		gHMI.ManualPage.StamperPositionEnable := NOT gStamper.Commands.Manual.Move;
		gStamper.Commands.Manual.Position := gHMI.ManualPage.StamperPosition;
		
	ELSE
		gHMI.ManualPage.StamperPositionEnable := FALSE;
		gHMI.ManualPage.StamperPosition := gStamper.Commands.Manual.Position;
	END_IF
	
	// Sensors
	gHMI.ManualPage.PusherInterface := gPusher.Interface;
	gHMI.ManualPage.PickerInterface := gPicker.Interface;
	gHMI.ManualPage.ConveyorInterface := gConveyor.Interface;
	gHMI.ManualPage.StamperInterface := gStamper.Interface;
	
	// Motion Feedback
	gHMI.ManualPage.ConveyorActPosition := gConveyor.Feedbacks.AxisPosition;
	gHMI.ManualPage.ConveyorActSpeed := gConveyor.Feedbacks.AxisSpeed;
	
	gHMI.ManualPage.StamperActPosition := gStamper.Feedbacks.AxisPosition;
	gHMI.ManualPage.StamperActSpeed := gStamper.Feedbacks.AxisSpeed;
	
END_ACTION
