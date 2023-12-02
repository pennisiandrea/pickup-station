
TYPE
	StamperType : 	STRUCT  (*Stamper Main type*)
		Commands : StamperCommadsType;
		Feedbacks : StamperFeedbacksType;
		Parameters : StamperParametersType;
		Interface : StamperInterfaceType;
	END_STRUCT;
	StamperCommadsType : 	STRUCT  (*Stamper Commands type*)
		Enable : BOOL;
		Reset : BOOL;
		Automatic : StamperAutomaticCommadsType;
		Manual : StamperManualCommadsType;
	END_STRUCT;
	StamperFeedbacksType : 	STRUCT  (*Stamper Feedbacks type*)
		Enabled : BOOL;
		WaitingStart : BOOL;
		Error : BOOL;
		OnSyncMotion : BOOL;
		WaitingCap : BOOL;
		StampCapDone : BOOL;
		InitDone : BOOL;
		InitPosition : BOOL;
		AxisSpeed : REAL;
		AxisPosition : LREAL;
		AxisHomed : BOOL;
		AxisPowered : BOOL;
	END_STRUCT;
	StamperParametersType : 	STRUCT  (*Stamper Parameters type*)
		Offset : LREAL;
		Speed : REAL := 10000;
		Acceleration : REAL := 20000;
	END_STRUCT;
	StamperInterfaceType : 	STRUCT  (*Stamper Interface type*)
		Inputs : StamperInterfaceInputsType;
		Outputs : StamperInterfaceOutputsType;
	END_STRUCT;
	StamperInterfaceOutputsType : 	STRUCT  (*Stamper Interface Output type*)
		StampForward : BOOL;
		SetPosition : LREAL;
	END_STRUCT;
	StamperInterfaceInputsType : 	STRUCT  (*Stamper Interface Input type*)
		ActualPosition : REAL;
		StampIsForward : BOOL;
		StampIsBackward : BOOL;
	END_STRUCT;
	StamperAutomaticCommadsType : 	STRUCT  (*Stamper Commands type*)
		Start : BOOL;
		Init : BOOL;
		StampCap : BOOL;
	END_STRUCT;
	StamperManualCommadsType : 	STRUCT  (*Stamper Commands type*)
		Enable : BOOL;
		StamperForward : BOOL;
		Position : LREAL;
		Acceleration : REAL := 500;
		Speed : REAL := 50;
		PowerOn : BOOL;
		Move : BOOL;
		Home : BOOL;
	END_STRUCT;
END_TYPE
