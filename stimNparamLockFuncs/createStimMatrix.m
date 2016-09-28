function [stimMatrix,stimValuesForRunStore,startTimesSorted_A,startTimesSorted_B, ...
          stimValuesSorted_A,stimValuesSorted_B,actualStimulusValues] ...
          = createStimMatrix(startTimesSorted,stimValuesSorted, ...
          tsFileNames,TS_timeSamples,stimDuration,stepFunctionRes,cosRamp,bModel0)
      
% function stimMatrix = createStimMatrix(startTimesSorted,stimValuesSorted, ...
%           TS_timeSamples,stimDuration,stepFunctionRes,cosRamp)
%
% creates stimulus matrix
%
% inputs
% startTimesSorted: a vector of starting times of the stimuli
% stimValuesSorted: match each start time to a stimulus value
% tsFileNames     : file name cell for each run
% TS_timeSamples  : the time base
% stimDuration    : duration of stimulus
% stepFunctionRes : stimulus step function has a certain resolution (in Hz)
%                   to make interpolation accurate (recommended 50)
% cosRamp         : length of cosine ramp in seconds
% bModel0         : 1 -> model 0-valued stimuli, 0 -> do not model
% outputs
% stimMatrix           : matrix containing stimulus step function for each 
%                        stimulus block
% stimValuesForRunStore: for each run, stores sequence of stimulus values
% startTimesSorted_A   : specific to current study: two stimulus orders, A
%                        and B. This argument specifies the start times

% get unique stimulus values
if bModel0 == 0
   actualStimulusValues = unique(stimValuesSorted(stimValuesSorted~=-1 & stimValuesSorted~=0));
elseif bModel0 == 1
   actualStimulusValues = unique(stimValuesSorted(stimValuesSorted~=-1));
else
   error('createStimMatrix: bModel0 either 0 or 1'); 
end

% Stire Stimulus Order A & B
stimValuesSorted_A = [] ;
stimValuesSorted_B = [] ;
stimMatrix = [];
% Matrix for locking parameters
stimValuesForRunStore = [];

% for each run
for i = 1:size(startTimesSorted,1)   
    
    % Stores A & B sequences-- For labeling Time Series by Stimulus Period
   if strfind(char(tsFileNames(i)),'_A_') & isempty(stimValuesSorted_A)
      startTimesSorted_A = startTimesSorted(i,startTimesSorted(i,:)~=-1);  
      stimValuesSorted_A = stimValuesSorted(i,stimValuesSorted(i,:)~=-1); 
   elseif strfind(char(tsFileNames(i)),'_B_') & isempty(stimValuesSorted_B)
      startTimesSorted_B = startTimesSorted(i,startTimesSorted(i,:)~=-1); 
      stimValuesSorted_B = stimValuesSorted(i,stimValuesSorted(i,:)~=-1); 
   else
      stimOrderMarker = [] ; 
   end
   
   % start times and corresponding stim values--get rid of filler numbers
   if bModel0 == 0
       startTimesForRun = startTimesSorted(i,stimValuesSorted(i,:)>0);
       stimValuesForRun = stimValuesSorted(i,stimValuesSorted(i,:)>0);
   elseif bModel0 == 1 & strfind(char(tsFileNames(i)),'_A_')
       stimValuesForRun = stimValuesSorted(i,stimValuesSorted(i,:)~=-1);
       stimValuesForRun = [0 stimValuesForRun]; 
       startTimesForRun = startTimesSorted(i,:);
   elseif bModel0 == 1 & strfind(char(tsFileNames(i)),'_B_')
       stimValuesForRun = stimValuesSorted(i,stimValuesSorted(i,:)~=-1);
       startTimesForRun = startTimesSorted(i,:);
   else
      error('createStimMatrix: bModel0 either 0 or 1'); 
   end
   % store for param locking in main function
   stimValuesForRunStore(i,:) = stimValuesForRun;
   
    % for each stimulus
   for j = 1:length(stimValuesForRun)
           % create the stimulus model
           stimVec = createStimVector(TS_timeSamples,startTimesForRun(j), ...
                        stimDuration,stepFunctionRes,cosRamp);
           stimMatrix(i,j,:) = stimVec; 
   end
   
end
      
gribble = 1;