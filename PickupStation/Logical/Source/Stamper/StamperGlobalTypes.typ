
TYPE
	StamperType : 	STRUCT  (*Stamper Main type*)
		Commands : StamperCommadsType;
		Feedbacks : StamperFeedbacksType;
		Parameters : StamperParametersType;
		Interface : StamperInterfaceType;
	END_STRUCT;
	StamperCommadsType : 	STRUCT  (*Stamper Commands type*)
		Enable : BOOL;
		Start : BOOL;
		Init : BOOL;
		NewCapTrigger : BOOL;
	END_STRUCT;
	StamperFeedbacksType : 	STRUCT  (*Stamper Feedbacks type*)
		Enabled : BOOL;
		WaitingStart : BOOL;
		Error : BOOL;
		OnSyncMotion : BOOL;
		WaitingCap : BOOL;
	END_STRUCT;
	StamperParametersType : 	STRUCT  (*Stamper Parameters type*)
		Offset : LREAL;
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
END_TYPE
