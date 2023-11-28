
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
	 
END_PROGRAM

PROGRAM _EXIT
	
	 
END_PROGRAM

