
TYPE
	AlarmsType : 	STRUCT 
		Commands : AlarmsCommandsType;
		Feedbacks : AlarmsFeedbacksType;
	END_STRUCT;
	AlarmsFeedbacksType : 	STRUCT 
		Pendings : UDINT;
	END_STRUCT;
	AlarmsCommandsType : 	STRUCT 
		Acknowledge : BOOL;
		AcknowledgeAll : BOOL;
	END_STRUCT;
END_TYPE
