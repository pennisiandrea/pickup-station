
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
		WAITING, (*WAITING state*)
		POWER_ON, (*INIT state*)
		ERROR, (*ERROR state*)
		HOMING,
		ACTIVATE_SYNC_MOTION,
		STAMP_FORWARD,
		STAMPING,
		STAMP_BACKWARD
		);
	InternalType : 	STRUCT 
		Axis : MpAxisBasic;
		Parameters : MpAxisBasicParType;
		Cam : MC_BR_CamAutomatCommand;
	END_STRUCT;
END_TYPE
