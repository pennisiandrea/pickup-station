
TYPE
	MainMachineType : 	STRUCT  (*MainMachine Main type*)
		Commands : MainMachineCommadsType;
		Feedbacks : MainMachineFeedbacksType;
		Parameters : MainMachineParametersType;
		Statistics : MainMachineStatisticsType;
	END_STRUCT;
	MainMachineCommadsType : 	STRUCT  (*MainMachine Commands type*)
		LinkMode : BOOL;
		Reset : BOOL;
		HeartBeat : BOOL;
		ClearStats : BOOL;
		Automatic : MainMachineAutomaticCommadsType;
		Manual : MainMachineManualCommadsType;
		OpcuaClientOk : BOOL;
	END_STRUCT;
	MainMachineFeedbacksType : 	STRUCT  (*MainMachine Feedbacks type*)
		WaitingStart : BOOL;
		Started : BOOL;
		Stopping : BOOL;
		Error : BOOL;
		HeartBeat : BOOL;
		AutomaticMode : BOOL;
		LinkOk : BOOL;
		ManualMode : BOOL;
		InitDone : BOOL;
		WaitModeSelection : BOOL;
		WaitingInit : BOOL;
		NewCapOnWork : BOOL;
		ClearStatsDone : BOOL;
		Initializing : BOOL;
		WaitingModulesReady : BOOL;
		PushingCap : BOOL;
		PickingCap : BOOL;
		DeliveringCap : BOOL;
	END_STRUCT;
	MainMachineParametersType : 	STRUCT  (*MainMachine Parameters type*)
		StamperEnable : BOOL := TRUE;
	END_STRUCT;
	MainMachineStatisticsType : 	STRUCT 
		CapsCounter : UDINT;
		CurrentCapWorkingTime : TIME;
		LastCapWorkingTime : TIME;
		AverageCapWorkingTime : TIME;
	END_STRUCT;
	MainMachineAutomaticCommadsType : 	STRUCT  (*MainMachine Commands type*)
		Enable : BOOL;
		Init : BOOL;
		Start : BOOL;
	END_STRUCT;
	MainMachineManualCommadsType : 	STRUCT  (*MainMachine Commands type*)
		Enable : BOOL;
	END_STRUCT;
END_TYPE
