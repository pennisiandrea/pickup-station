
PROGRAM _INIT
	aiLogoAxisActPos;
	diMagazineEmpty;
	diCapAtPickup;
	diCapPusherForward;
	diCapPusherBack;
	diPickupArmBack;
	diPickupArmForward;
	diCapGripperVacuum;
	diCapOnLogoConveyor;
	diCapExitLogoConveyor;
	diLogoStamperBack;
	diLogoStamperForward;
	aoLogoConveyorSetSpeed;
	doCapPusher;
	doPickupArmForward;
	doPickupArmBack;
	doCapGripperPick;
	aoLogoAxisSetPos;
	doLogoStamper;
	doLogoConveyorClear;
	 
END_PROGRAM

PROGRAM _CYCLIC
	// Pusher
	gPusher.Interface.Inputs.PusherInForwardPosition := diCapPusherForward;
	gPusher.Interface.Inputs.PusherInBackwardPosition := diCapPusherBack;
	gPusher.Interface.Inputs.CapAtPickPosition := diCapAtPickup;
	gPusher.Interface.Inputs.MagazineEmpty := diMagazineEmpty;
	
	doCapPusher := gPusher.Interface.Outputs.MoveForward;
	
	// Picker
	gPicker.Interface.Inputs.ArmForward := diPickupArmForward;
	gPicker.Interface.Inputs.ArmBackward := diPickupArmBack;
	gPicker.Interface.Inputs.GripperVacuum := diCapGripperVacuum;
	
	doPickupArmForward := gPicker.Interface.Outputs.ArmForward;
	doPickupArmBack := gPicker.Interface.Outputs.ArmBackward;
	doCapGripperPick := gPicker.Interface.Outputs.GripperPick;
	 
	// Conveyor
	gConveyor.Interface.Inputs.CapInStartPosition := diCapOnLogoConveyor;
	gConveyor.Interface.Inputs.CapInExitPosition := diCapExitLogoConveyor;
	
	aoLogoConveyorSetSpeed := gConveyor.Interface.Outputs.SetSpeed/1000;
	
	// Stamper
	gStamper.Interface.Inputs.ActualPosition := aiLogoAxisActPos*1000;
	gStamper.Interface.Inputs.StampIsForward := diLogoStamperForward;
	gStamper.Interface.Inputs.StampIsBackward := diLogoStamperBack;
	
	aoLogoAxisSetPos := LREAL_TO_REAL(gStamper.Interface.Outputs.SetPosition/1000);
	doLogoStamper := gStamper.Interface.Outputs.StampForward;
END_PROGRAM

PROGRAM _EXIT
	
	 
END_PROGRAM

