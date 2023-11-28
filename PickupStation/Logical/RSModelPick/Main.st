
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
	gPicker.Interface.Inputs.CapPusherForward := diCapPusherForward;
	gPicker.Interface.Inputs.CapPusherBackward := diCapPusherBack;
	gPicker.Interface.Inputs.CapAtPickPosition := diCapAtPickup;
	gPicker.Interface.Inputs.MagazineEmpty := diMagazineEmpty;
	gPicker.Interface.Inputs.ArmForward := diPickupArmForward;
	gPicker.Interface.Inputs.ArmBackward := diPickupArmBack;
	gPicker.Interface.Inputs.GripperVacuum := diCapGripperVacuum;
	
	doCapPusher := gPicker.Interface.Outputs.CapPusherForward;
	doPickupArmForward := gPicker.Interface.Outputs.ArmForward;
	doPickupArmBack := gPicker.Interface.Outputs.ArmBackward;
	doCapGripperPick := gPicker.Interface.Outputs.GripperPick;
	 
END_PROGRAM

PROGRAM _EXIT
	
	 
END_PROGRAM

