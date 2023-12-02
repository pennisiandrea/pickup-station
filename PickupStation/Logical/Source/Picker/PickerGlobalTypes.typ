
TYPE
	PickerType : 	STRUCT  (*Picker Main type*)
		Commands : PickerCommadsType;
		Feedbacks : PickerFeedbacksType;
		Interface : PickerInterfaceType;
	END_STRUCT;
	PickerCommadsType : 	STRUCT  (*Picker Commands type*)
		Enable : BOOL;
		Reset : BOOL;
		Manual : PickerManualCommadsType;
		Automatic : PickerAutomaticCommadsType;
	END_STRUCT;
	PickerFeedbacksType : 	STRUCT  (*Picker Feedbacks type*)
		Enabled : BOOL;
		WaitingPickCommand : BOOL;
		Error : BOOL;
		WaitingStart : BOOL;
		PickACapDone : BOOL;
		InitDone : BOOL;
		InitPosition : BOOL;
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
	PickerAutomaticCommadsType : 	STRUCT  (*Picker Commands type*)
		PickACap : BOOL;
		Init : BOOL;
		Start : BOOL;
	END_STRUCT;
	PickerManualCommadsType : 	STRUCT  (*Picker Commands type*)
		Enable : BOOL;
		MoveForward : BOOL;
		MoveBackward : BOOL;
		ActivateGrip : BOOL;
	END_STRUCT;
END_TYPE
