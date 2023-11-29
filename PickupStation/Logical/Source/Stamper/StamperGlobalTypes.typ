
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
		CapOnMotion : BOOL;
	END_STRUCT;
	StamperFeedbacksType : 	STRUCT  (*Stamper Feedbacks type*)
		Enabled : BOOL;
		Waiting : BOOL;
		Error : BOOL;
		OnSyncMotion : BOOL;
	END_STRUCT;
	StamperParametersType : 	STRUCT  (*Stamper Parameters type*)
		Var : BOOL;
	END_STRUCT;
	StamperInterfaceType : 	STRUCT  (*Stamper Interface type*)
		Inputs : StamperInterfaceInputsType;
		Outputs : StamperInterfaceOutputsType;
	END_STRUCT;
	StamperInterfaceOutputsType : 	STRUCT  (*Stamper Interface Output type*)
		StampForward : BOOL;
		SetPosition : REAL;
	END_STRUCT;
	StamperInterfaceInputsType : 	STRUCT  (*Stamper Interface Input type*)
		ActualPosition : REAL;
		StampIsForward : BOOL;
		StampIsBackward : BOOL;
	END_STRUCT;
END_TYPE
