
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
		ConveyorJogButtonEnable : BOOL;
		ConveyorJogButton : BOOL;
		ConveyorSpeed : REAL;
		ConveyorSpeedEnable : BOOL;
		ConveyorAxisHomed : BOOL;
		ConveyorAxisPowered : BOOL;
	END_STRUCT;
	HMIHeaderContentType : 	STRUCT  (*HMI Interface Output type*)
		MasterConnectionOk : BOOL;
		PendingAlarms : STRING[3];
	END_STRUCT;
END_TYPE
