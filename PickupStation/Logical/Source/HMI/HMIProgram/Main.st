PROGRAM _INIT
	gHMI.AutomaticPage.ConveyorSpeed := gConveyor.Parameters.TargetSpeed;
END_PROGRAM

PROGRAM _CYCLIC
	
	HeaderContentAction;
	
	AutomaticPageAction;
	
END_PROGRAM

PROGRAM _EXIT
    
END_PROGRAM