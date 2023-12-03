
TYPE
	MasterType : 	STRUCT  (*Master Main type*)
		Inputs : MasterInputsType;
		Outputs : MasterOutputsType;
	END_STRUCT;
	MasterInputsType : 	STRUCT  (*Master Commands type*)
		HeartBeat : BOOL;
		Error : BOOL;
		WaitingStart : BOOL;
		WaitingModeSelection : BOOL;
		WaitingInit : BOOL;
		InitDone : BOOL;
		Started : BOOL;
		ClearStatsDone : BOOL;
	END_STRUCT;
	MasterOutputsType : 	STRUCT  (*Master Feedbacks type*)
		HeartBeat : BOOL;
		Reset : BOOL;
		Error : BOOL;
		ClearStats : BOOL;
		Init : BOOL;
		Start : BOOL;
		AutomaticMode : BOOL;
		StampIncluded : BOOL;
		StampOffset : LREAL;
		ConveyorSpeed : REAL;
	END_STRUCT;
END_TYPE