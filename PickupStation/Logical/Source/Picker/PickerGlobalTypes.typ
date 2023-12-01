
TYPE
	PickerType : 	STRUCT  (*Picker Main type*)
		Commands : PickerCommadsType;
		Feedbacks : PickerFeedbacksType;
		Interface : PickerInterfaceType;
	END_STRUCT;
	PickerCommadsType : 	STRUCT  (*Picker Commands type*)
		Enable : BOOL;
		PickACap : BOOL;
		Init : BOOL;
		Start : BOOL;
		ForwardManualCommand : BOOL;
		BackwardManualCommand : BOOL;
		VaacumManualCommand : BOOL;
		ManualMode : BOOL;
	END_STRUCT;
	PickerFeedbacksType : 	STRUCT  (*Picker Feedbacks type*)
		Enabled : BOOL;
		WaitingPickCommand : BOOL;
		Error : BOOL;
		WaitingStart : BOOL;
		PickACapDone : BOOL;
		InitDone : BOOL;
	END_STRUCT;
	PickerInterfaceType : 	STRUCT  (*Picker Interface type*)
		Inputs : PickerInterfaceInputsType;
		Outputs : PickerInterfaceOutputsType;
	END_STRUCT;
	PickerInterfaceOutputsType : 	STRUCT  (*Picker Interface Output type*)
		ArmForward : BOOL;
		ArmBackward : BOOL;
		GripperPick : BOOL;
	END_STRUCT;
	PickerInterfaceInputsType : 	STRUCT  (*Picker Interface Input type*)
		ArmBackward : BOOL;
		ArmForward : BOOL;
		GripperVacuum : BOOL;
	END_STRUCT;
END_TYPE
