//******************************************************************************************************
// Program: 	PickerProgram
// Author: 		Andrea Pennisi
// Rev.: 		1.0.0
// Date:		28.11.2023
//
// Description:
// This module uses both cap pusher and pickup arm tools. 
// At init the module try to reach the initial position.
// At start the module uses arm and cap pusher in order to deliver a cap in the conveyor.
//******************************************************************************************************
        
PROGRAM _INIT
        
    ResetOutputsAction;
    ResetFeedbacksAction;
    
    MachineState.NextState := WAITING_INIT;
    
END_PROGRAM

PROGRAM _CYCLIC	
    // Enable module
    IF NOT gPicker.Commands.Enable THEN
        ResetOutputsAction;
		ResetFeedbacksAction;	
		ResetAlarmsAction;
        RETURN;
    END_IF
    
	// Init command management
	IF EDGENEG(gPicker.Commands.Start) OR EDGEPOS(gPicker.Commands.Init) THEN
		MachineState.NextState := WAITING_INIT;
	END_IF
	
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
		WAITING_INIT:
			gPicker.Feedbacks.InitDone := FALSE;
			IF gPicker.Commands.Init THEN
				MachineState.NextState := MOVE_BACKWARD;
			END_IF
        			
		MOVE_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPicker.Interface.Inputs.ArmBackward THEN
				MachineState.NextState := PLACE_CAP;
			END_IF
			 
		PLACE_CAP:
			MachineState.TimeoutTimer.PT := T#3S;
			IF NOT gPicker.Interface.Inputs.GripperVacuum THEN
				gPicker.Feedbacks.PickACapDone := Internal.CapPicked;
				Internal.CapPicked := FALSE;
				MachineState.NextState := WAITING_START;
				gPicker.Feedbacks.InitDone := TRUE;
			END_IF			
								
		WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			gPicker.Feedbacks.PickACapDone := FALSE;
			
			IF gPicker.Commands.Start THEN
				MachineState.NextState := WAITING_PICK_COMMAND;
			END_IF  
			
        WAITING_PICK_COMMAND:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF gPicker.Commands.PickACap THEN
				gPicker.Feedbacks.PickACapDone := FALSE;
                MachineState.NextState := MOVE_FORWARD;
            END_IF         
		
		MOVE_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPicker.Interface.Inputs.ArmForward THEN
				MachineState.NextState := PICK_CAP;
			END_IF
						 
		PICK_CAP:
			MachineState.TimeoutTimer.PT := T#3S;
			IF gPicker.Interface.Inputs.GripperVacuum THEN
				Internal.CapPicked := TRUE;
				MachineState.NextState := MOVE_BACKWARD;
			END_IF
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			gPicker.Feedbacks.InitDone := FALSE;
			gPicker.Feedbacks.PickACapDone := FALSE;
        
        ELSE
            MachineState.NextState := WAITING_INIT;			
        
    END_CASE
    
	gPicker.Interface.Outputs.ArmBackward := MachineState.ActualState = MOVE_BACKWARD;
	gPicker.Interface.Outputs.ArmForward := MachineState.ActualState = MOVE_FORWARD;
	gPicker.Interface.Outputs.GripperPick := (MachineState.ActualState = PICK_CAP OR Internal.CapPicked) AND NOT (MachineState.ActualState = PLACE_CAP);
		
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM