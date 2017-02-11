# mriBlockFrequencyDirectionAnalysis
Code for the analysis of blocks of fMRI data. Originally written to analyze data collected at Mt. Sinai at 7T, using 12 second blocks of stimulation, varying flicker frequencies and modulation directions.

To configure the code for running, first install ToolBox ToolBox:

Then, copy the file

	/configuration/mriBlockFrequencyDirectionAnalysisLocalHookTemplate.m

into your localToolboxHooks directory. Remove the suffix "LocalHookTemplate" from the filename, and edit the file to reflect your username and paths.

In Matlab, issue the tbUse command:

	tbUse('fmriBlockFrequencyDirectionAnalysis','reset','full');
	
The analysis is stated by running:

	mriBFDM_main.m