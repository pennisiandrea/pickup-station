
TYPE
	PickerType : 	STRUCT  (*Picker Main type*)
		Commands : PickerCommadsType;
		Feedbacks : PickerFeedbacksType;
		Interface : PickerInterfaceType;
	END_STRUCT;
	PickerCommadsType : 	STRUCT  (*Picker Commands type*)
		Enable : BOOL;
		Activate : BOOL;
		PickACap : BOOL;
		Init : BOOL;
	END_STRUCT;
	PickerFeedbacksType : 	STRUCT  (*Picker Feedbacks type*)
		Enabled : BOOL;
		Activated : BOOL;
		Waiting : BOOL;
		Error : BOOL;
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
