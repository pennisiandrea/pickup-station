
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
		WAITING_START, (*WAITING state*)
		MOVE_BACKWARD,
		WAITING_MAGAZINE, (*ERROR state*)
		MOVE_FORWARD,
		WAITING_TAKE_A_CAP_COMMAND,
		ERROR
		);
END_TYPE
