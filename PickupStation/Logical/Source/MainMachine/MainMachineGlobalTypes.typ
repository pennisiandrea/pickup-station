
TYPE
	MainMachineType : 	STRUCT  (*MainMachine Main type*)
		Commands : MainMachineCommadsType;
		Feedbacks : MainMachineFeedbacksType;
		Parameters : MainMachineParametersType;
		Statistics : MainMachineStatisticsType;
	END_STRUCT;
	MainMachineCommadsType : 	STRUCT  (*MainMachine Commands type*)
		Start : BOOL;
		Reset : BOOL;
		HeartBeat : BOOL;
		LinkMode : BOOL;
		AutomaticMode : BOOL;
		Init : BOOL;
		ManualMode : BOOL;
		ClearStats : BOOL;
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
	END_STRUCT;
	MainMachineParametersType : 	STRUCT  (*MainMachine Parameters type*)
		StamperEnable : BOOL := TRUE;
	END_STRUCT;
	MainMachineStatisticsType : 	STRUCT 
		CurrentCapWorkingTime : TIME;
		LastCapWorkingTime : TIME;
		AverageCapWorkingTime : TIME;
	END_STRUCT;
END_TYPE
