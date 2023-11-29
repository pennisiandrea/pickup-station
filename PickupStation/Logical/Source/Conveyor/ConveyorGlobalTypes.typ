
TYPE
	ConveyorType : 	STRUCT  (*Conveyor Main type*)
		Commands : ConveyorCommadsType;
		Feedbacks : ConveyorFeedbacksType;
		Parameters : ConveyorParametersType;
		Interface : ConveyorInterfaceType;
	END_STRUCT;
	ConveyorCommadsType : 	STRUCT  (*Conveyor Commands type*)
		Enable : BOOL;
		Start : BOOL;
		Init : BOOL;
	END_STRUCT;
	ConveyorFeedbacksType : 	STRUCT  (*Conveyor Feedbacks type*)
		Enabled : BOOL;
		WaitingStart : BOOL;
		Error : BOOL;
		CapOnMotion : BOOL;
	END_STRUCT;
	ConveyorParametersType : 	STRUCT  (*Conveyor Parameters type*)
		TargetSpeed : REAL := 100;
	END_STRUCT;
	ConveyorInterfaceType : 	STRUCT  (*Conveyor Interface type*)
		Inputs : ConveyorInterfaceInputsType;
		Outputs : ConveyorInterfaceOutputsType;
	END_STRUCT;
	ConveyorInterfaceOutputsType : 	STRUCT  (*Conveyor Interface Output type*)
		SetSpeed : REAL;
	END_STRUCT;
	ConveyorInterfaceInputsType : 	STRUCT  (*Conveyor Interface Input type*)
		CapInStartPosition : BOOL;
		CapInExitPosition : BOOL;
	END_STRUCT;
END_TYPE