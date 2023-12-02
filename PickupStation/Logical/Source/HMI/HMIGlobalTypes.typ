
TYPE
	HMIType : 	STRUCT  (*HMI Main type*)
		AutomaticPage : HMIAutomaticPageType;
		ManualPage : HMIManualPageType;
		HeaderContent : HMIHeaderContentType;
	END_STRUCT;
	HMIAutomaticPageType : 	STRUCT  (*HMI Interface Output type*)
		StartButtonEnable : BOOL;
		StartButton : BOOL;
		StopButtonVisibility : BOOL;
		InitButtonEnable : BOOL;
		InitButton : BOOL;
		ConveyorSpeed : REAL;
		ConveyorSpeedEnable : BOOL;
		AutoButtonEnable : BOOL;
		AutoButton : BOOL;
		LinkButtonEnable : BOOL;
		LinkButton : BOOL;
		ReadyToStartVisibility : BOOL;
		CurrentCapWorkingTime : UDINT;
		LastCapWorkedTime : UDINT;
		AvgCapWorkTime : UDINT;
		ClearStats : BOOL;
		StamperIncludedCheckbox : BOOL;
		StamperIncludedCheckboxEnable : BOOL;
		StamperOffset : LREAL;
		StamperOffsetEnable : BOOL;
		CapsCounter : UDINT;
	END_STRUCT;
	HMIManualPageType : 	STRUCT  (*HMI Interface Output type*)
		ManualButtonEnable : BOOL;
		ManualButton : BOOL;
		PushCapButtonEnable : BOOL;
		PushCapButton : BOOL;
		ArmForwardButtonEnable : BOOL;
		ArmForwardButton : BOOL;
		ArmBackwardButtonEnable : BOOL;
		ArmBackwardButton : BOOL;
		ArmVaacumButtonEnable : BOOL;
		ArmVaacumButton : BOOL;
		ConveyorHomeButtonEnable : BOOL;
		ConveyorHomeButton : BOOL;
		ConveyorPowerButtonEnable : BOOL;
		ConveyorPowerButton : BOOL;
		ConveyorMoveButtonEnable : BOOL;
		ConveyorMoveButton : BOOL;
		ConveyorSpeed : REAL;
		ConveyorSpeedEnable : BOOL;
		ConveyorAxisHomed : BOOL;
		ConveyorAxisPowered : BOOL;
		StamperHomeButtonEnable : BOOL;
		StamperHomeButton : BOOL;
		StamperPowerButtonEnable : BOOL;
		StamperPowerButton : BOOL;
		StamperMoveButtonEnable : BOOL;
		StamperMoveButton : BOOL;
		StamperSpeed : REAL;
		StamperSpeedEnable : BOOL;
		StamperAxisHomed : BOOL;
		StamperAxisPowered : BOOL;
		StamperForwardButtonEnable : BOOL;
		StamperForwardButton : BOOL;
		StamperPosition : LREAL;
		StamperPositionEnable : BOOL;
		PusherInterface : PusherInterfaceType;
		PickerInterface : PickerInterfaceType;
		ConveyorInterface : ConveyorInterfaceType;
		StamperInterface : StamperInterfaceType;
		ConveyorActSpeed : REAL;
		ConveyorActPosition : LREAL;
		StamperActSpeed : REAL;
		StamperActPosition : LREAL;
	END_STRUCT;
	HMIHeaderContentType : 	STRUCT  (*HMI Interface Output type*)
		MasterConnectionOk : BOOL;
		PendingAlarms : STRING[3];
	END_STRUCT;
END_TYPE
