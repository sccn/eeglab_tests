
// Head Localization parameters.
// 12:40  22/01/2004

CustomDs
{
	FixSensors:	False
}

// PROCESSING PARAMETERS
processing
{
	// balance: order, adapted
	// (adapted=0 -> not adapted)
	// (adapted=1 -> adapted)
	balance:	3,0
}

// Data selector parameters.
DsSelector
{
	RejectBadTrials:	TRUE
	ForceEvenNumTargets:	FALSE
	MaximumOverlap:	0
	StartTime:	1
	EndTime:	2
	EventRange:	ALL
	WholeTrial:	FALSE
	CondSearchStart:	0
	CondSearchEnd:	0
	TargetTrialOffset:	0
}
