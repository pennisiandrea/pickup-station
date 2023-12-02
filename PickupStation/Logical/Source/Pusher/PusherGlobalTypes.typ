
TYPE
	PusherType : 	STRUCT  (*Pusher Main type*)
		Commands : PusherCommandsType;
		Feedbacks : PusherFeedbacksType;
		Interface : PusherInterfaceType;
	END_STRUCT;
	PusherCommandsType : 	STRUCT 
		Enable : BOOL;
		Reset : BOOL;
		Automatic : PusherAutomaticCommandsType;
		Manual : PusherManualCommandsType;
	END_STRUCT;
	PusherFeedbacksType : 	STRUCT  (*Pusher Feedbacks type*)
		Enabled : BOOL;
		WaitingStart : BOOL;
		Error : BOOL;
		CapReady : BOOL;
		WaitingTakeACapCommand : BOOL;
		InitDone : BOOL;
		InitPosition : BOOL;
		TakeACapDone : BOOL;
	END_STRUCT;
	PusherInterfaceType : 	STRUCT  (*Pusher Interface type*)
		Inputs : PusherInterfaceInputsType;
		Outputs : PusherInterfaceOutputsType;
	END_STRUCT;
	PusherInterfaceOutputsType : 	STRUCT  (*Pusher Interface Output type*)
		MoveForward : BOOL;
	END_STRUCT;
	PusherInterfaceInputsType : 	STRUCT  (*Pusher Interface Input type*)
		PusherInBackwardPosition : BOOL;
		PusherInForwardPosition : BOOL;
		CapAtPickPosition : BOOL;
		MagazineEmpty : BOOL;
	END_STRUCT;
	PusherManualCommandsType : 	STRUCT 
		PushManualCommand : BOOL;
	END_STRUCT;
	PusherAutomaticCommandsType : 	STRUCT 
		Start : BOOL;
		Init : BOOL;
		TakeACap : BOOL;
	END_STRUCT;
END_TYPE
