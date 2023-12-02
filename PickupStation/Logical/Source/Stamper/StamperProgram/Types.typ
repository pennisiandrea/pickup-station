
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
		INIT,
		WAITING_START, (*WAITING state*)
		POWER_ON, (*INIT state*)
		HOMING,
		ACTIVATE_CAM,
		WAITING_CAP,
		STAMP_FORWARD,
		STAMPING,
		STAMP_BACKWARD,
		ERROR, (*ERROR state*)
		MANUAL
		);
	InternalType : 	STRUCT 
		Axis : MpAxisBasic;
		Parameters : MpAxisBasicParType;
		Cam : MC_BR_CamAutomatCommand;
		Offset : MC_BR_Offset;
		LastOffset : LREAL;
		CamStartTrigger : BOOL;
		Error : BOOL;
		OffsetToDo : BOOL;
	END_STRUCT;
END_TYPE
