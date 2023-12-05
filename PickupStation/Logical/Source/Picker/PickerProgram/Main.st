//******************************************************************************************************
// Program: 	PickerProgram
// Author: 		Andrea Pennisi
// Rev.: 		1.0.0
// Date:		5.12.2023
//
// Description:
// This module is used to pick a cap from the pusher station to the conveyor.
// Only pneumatic motion in this module 
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
    
	IF EDGENEG(gPicker.Commands.Automatic.Start) THEN
		IF MachineState.NextState <> ERROR THEN
			MachineState.NextState := WAITING_START;
		END_IF
	END_IF
	
	IF EDGEPOS(gPicker.Commands.Automatic.Init) THEN
		IF MachineState.NextState <> ERROR THEN
			MachineState.NextState := WAITING_INIT;
		END_IF
	END_IF
	
	// Alarms
	SetAlarmsAction;
	
    // Machine state
    MachineStateManagementAction;
    CASE MachineState.ActualState OF
        
		WAITING_INIT:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			IF MachineState.NewTriggerState THEN
				ResetOutputsAction;
				gPicker.Feedbacks.PickACapDone := FALSE;
			END_IF
			
			IF gPicker.Commands.Automatic.Init THEN
				MachineState.NextState := MOVE_BACKWARD;
				
			ELSIF gPicker.Commands.Manual.Enable THEN
				MachineState.NextState := MANUALS;
				
			END_IF
        
		MANUALS:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			// Manual commands
			gPicker.Interface.Outputs.ArmForward := gPicker.Commands.Manual.MoveForward;
			gPicker.Interface.Outputs.ArmBackward := gPicker.Commands.Manual.MoveBackward;
			gPicker.Interface.Outputs.GripperPick := gPicker.Commands.Manual.ActivateGrip;
			
			IF NOT gPicker.Commands.Manual.Enable THEN
				MachineState.NextState := WAITING_INIT;
			END_IF
        			
		MOVE_BACKWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			gPicker.Interface.Outputs.ArmBackward := TRUE;
			IF gPicker.Interface.Inputs.ArmBackward THEN
				gPicker.Interface.Outputs.ArmBackward := FALSE;
				MachineState.NextState := PLACE_CAP;
			END_IF
			 
		PLACE_CAP:
			MachineState.TimeoutTimer.PT := T#3S;
			gPicker.Interface.Outputs.GripperPick := FALSE;
			IF NOT gPicker.Interface.Inputs.GripperVacuum THEN
				gPicker.Feedbacks.PickACapDone := Internal.CapPicked;
				Internal.CapPicked := FALSE;
				MachineState.NextState := WAITING_START;
			END_IF			
								
		WAITING_START:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			gPicker.Feedbacks.PickACapDone := FALSE;
			
			IF gPicker.Commands.Automatic.Start THEN
				MachineState.NextState := WAITING_PICK_COMMAND;				
				
			ELSIF gPicker.Commands.Manual.Enable THEN
				MachineState.NextState := MANUALS;	
			END_IF  
			
        WAITING_PICK_COMMAND:
			MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			
			IF gPicker.Commands.Automatic.PickACap THEN
				gPicker.Feedbacks.PickACapDone := FALSE;
                MachineState.NextState := MOVE_FORWARD;
            END_IF         
		
		MOVE_FORWARD:
			MachineState.TimeoutTimer.PT := T#3S;
			gPicker.Interface.Outputs.ArmForward := TRUE;
			IF gPicker.Interface.Inputs.ArmForward THEN
				gPicker.Interface.Outputs.ArmForward := FALSE;
				MachineState.NextState := PICK_CAP;
			END_IF
						 
		PICK_CAP:
			MachineState.TimeoutTimer.PT := T#3S;
			gPicker.Interface.Outputs.GripperPick := TRUE;
			IF gPicker.Interface.Inputs.GripperVacuum THEN
				Internal.CapPicked := TRUE;
				MachineState.NextState := MOVE_BACKWARD;
			END_IF
			
        ERROR:
            MachineState.TimeoutTimer.PT := T#0S; // Timeout disabled in this state
			ResetOutputsAction;
			IF NOT Internal.Error THEN
				MachineState.NextState := WAITING_INIT;
			END_IF
        
        ELSE
            MachineState.NextState := WAITING_INIT;			
        
    END_CASE
    		
    FeedbacksUpdateAction;
    
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM