
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
		WAITING_INIT, (*WAITING state*)
		MANUALS,
		WAITING_START, (*WAITING state*)
		MOVE_BACKWARD,
		WAITING_MAGAZINE, (*ERROR state*)
		WAITING_TAKE_A_CAP_COMMAND,
		MOVE_FORWARD,
		ERROR
		);
	InternalType : 	STRUCT 
		Error : BOOL;
	END_STRUCT;
END_TYPE
