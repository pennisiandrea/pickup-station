
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
		WAITING_MODE_SELECTION,
		AUTO_WAITING_INIT,
		AUTO_INITIALIZING,
		AUTO_WAITING_START,
		AUTO_PUSH_CAP,
		AUTO_PICK_CAP,
		AUTO_WAITING_CAP_DELIVERY,
		MANUAL,
		ERROR, (*ERROR state*)
		AUTO_WAITING_MODULES_READY
		);
	InternalType : 	STRUCT 
		HeartBeatTimer : TON := (PT:=T#250MS);
		CommunicationTimeoutTimer : TON := (PT:=T#3S);
		MasterCommunicationOk : BOOL;
		OnPhaseStopRequest : BOOL;
		ErrorReaction : BOOL;
	END_STRUCT;
END_TYPE
