
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
		ERROR, (*ERROR state*)
		HOMING,
		POWER_ON,
		WAITING_CAP,
		MOTION,
		POWER_OFF,
		INIT,
		WAITING_START
		);
	InternalType : 	STRUCT 
		Axis : MpAxisBasic;
		Parameters : MpAxisBasicParType;
	END_STRUCT;
END_TYPE
