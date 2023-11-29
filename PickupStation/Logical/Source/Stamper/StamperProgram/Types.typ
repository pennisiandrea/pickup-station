
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
		SET_SHIFT,
		HOMING,
		ACTIVATE_CAM,
		WAITING_SYNC_MOTION,
		STAMP_FORWARD,
		STAMPING,
		STAMP_BACKWARD,
		RESET_SHIFT,
		ERROR (*ERROR state*)
		);
	InternalType : 	STRUCT 
		Axis : MpAxisBasic;
		Parameters : MpAxisBasicParType;
		Cam : MC_BR_CamAutomatCommand;
		Offset : MC_BR_Offset;
		LastOffset : LREAL;
	END_STRUCT;
END_TYPE
