
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
		WAITING_INIT,
		WAITING_START,
		MOVE_BACKWARD, (*INIT state*)
		PLACE_CAP, (*WAITING state*)
		WAITING_PICK_COMMAND, (*ERROR state*)
		MOVE_FORWARD,
		PICK_CAP,
		ERROR,
		MANUALS
		);
	InternalType : 	STRUCT 
		CapPicked : BOOL;
	END_STRUCT;
END_TYPE
