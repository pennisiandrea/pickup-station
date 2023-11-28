
TYPE
	MachineStateType : 	STRUCT  (*Machine state main type*)
		OldState : MachineStateEnum; (*Actual state*)
		ActualState : MachineStateEnum; (*Actual state*)
		NextState : MachineStateEnum; (*Next state*)
		NewTriggerState : BOOL; (*Trigger state change*)
		TimeoutTimer : TON; (*State timeout*)
	END_STRUCT;
	MachineStateEnum : 
		( (*Machine State enumeration*)
		WAITING_ACTIVATE,
		ARM_BACKWARD, (*INIT state*)
		PLACE_CAP, (*WAITING state*)
		CAP_PUSHER_BACKWARD,
		WAITING_MAGAZINE,
		WAITING_PICK_COMMAND, (*ERROR state*)
		PUSH_CAP,
		ARM_FORWARD,
		PICK_CAP,
		ERROR
		);
	InternalType : 	STRUCT 
		CapPicked : BOOL;
	END_STRUCT;
END_TYPE
