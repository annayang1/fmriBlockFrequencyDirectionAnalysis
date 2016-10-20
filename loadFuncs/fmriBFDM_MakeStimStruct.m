function [values,timebase,metaData] = fmriBFDM_MakeStimStruct(makeStimStructParams)
% function [values,timebase,metaData] = fmriBFDM_MakeStimStruct(makeStimStructParams)
%
%

%% Stimulus
% Load that .mat file produced by the stimulus computer
stimulus.metaData                           = load(makeStimStructParams.stimulusFile);
% Get run duration
runDur                                      = sum(stimulus.metaData.params.trialDuration)*1000; % length of run (msec)
% Set the timebase
stimulus.timebase                           = 0:runDur-1;
zVect                                       = zeros(1,runDur);

% Loop through the event instances
for j = 1:size(stimulus.metaData.params.responseStruct.events,2)
    % phase offset
    if ~isempty(stimulus.metaData.params.thePhaseOffsetSec)
        phaseOffsetSec = stimulus.metaData.params.thePhaseOffsetSec(...
            stimulus.metaData.params.thePhaseIndices(j));
    else
        phaseOffsetSec = 0;
    end
    % start time
    startTime = stimulus.metaData.params.responseStruct.events(j).tTrialStart - ...
        stimulus.metaData.params.responseStruct.tBlockStart + phaseOffsetSec;
    % duration
    if isfield(stimulus.metaData.params.responseStruct.events(1).describe.params,'stepTimeSec')
        durTime = stimulus.metaData.params.responseStruct.events(j).describe.params.stepTimeSec + ...
            2*stimulus.metaData.params.responseStruct.events(j).describe.params.cosineWindowDurationSecs;
    else
        durTime = stimulus.metaData.params.responseStruct.events(j).tTrialEnd - ...
            stimulus.metaData.params.responseStruct.events(j).tTrialStart;
    end
    % stimulus window
    stimWindow                              = ceil((startTime*1000) : (startTime*1000 + ((durTime*1000)-1)));
    % Save the stimulus values
    thisStim                                = zVect;
    thisStim(stimWindow)                    = 1;
    % cosine ramp onset
    if stimulus.metaData.params.responseStruct.events(j).describe.params.cosineWindowIn
        winDur  = stimulus.metaData.params.responseStruct.events(j).describe.params.cosineWindowDurationSecs;
        cosOn   = (cos(pi+linspace(0,1,winDur*1000)*pi)+1)/2;
        thisStim(stimWindow(1:winDur*1000)) = cosOn;
    end
    % cosine ramp offset
    if stimulus.metaData.params.responseStruct.events(j).describe.params.cosineWindowOut
        winDur  = stimulus.metaData.params.responseStruct.events(j).describe.params.cosineWindowDurationSecs;
        cosOff   = fliplr((cos(pi+linspace(0,1,winDur*1000)*pi)+1)/2);
        thisStim(stimWindow(end-((winDur*1000)-1):end)) = cosOff;
    end
    % trim stimulus
    thisStim                                = thisStim(1:runDur); % trim events past end of run (occurs for stimuli presented near the end of the run)
    % save stimulus values
    stimulus.values(j,:)                    = thisStim;
end % loop through stimulus instances

timebase = stimulus.timebase;
values = stimulus.values;

% Construct the stimulus types and labels
conditionArray = [stimulus.metaData.params.theDirections' stimulus.metaData.params.theFrequencyIndices' stimulus.metaData.params.theContrastRelMaxIndices'];
[uniqueConditions, ~, idx] = unique(conditionArray, 'rows');
metaData.stimTypes = idx;
for ii = 1:length(uniqueConditions)
    % Check if there is frequency information included
    if ~(stimulus.metaData.params.theFrequenciesHz == -1)
        metaData.stimLabels{ii}=stimulus.metaData.params.theFrequenciesHz(ii);
    else
        tmp = strsplit(stimulus.metaData.params.modulationFiles, ',');
        tmp = strsplit(tmp{conditionArray(ii, 1)}, '-');
        [~, tmp2] = fileparts(tmp{3});
        metaData.stimLabels{ii} = [tmp{2} '_' tmp2 '_' num2str(100*stimulus.metaData.params.theFrequenciesHz(conditionArray(ii, 3))) '%'];
    end
end

% Get and save the modulation direction
if ~isempty(strfind(stimulus.metaData.params.cacheFileName{1},'LightFlux'))
    metaData.modulationDirection='LightFlux';
end % check for LightFlux modulation
if ~isempty(strfind(stimulus.metaData.params.cacheFileName{1},'LMinusM'))
    metaData.modulationDirection='L-M';
end % check for L-M modulation
if ~isempty(strfind(stimulus.metaData.params.cacheFileName{1},'S'))
    metaData.modulationDirection='S';
end % check for S modulation

% Copy relevant param info from the passed makeStimStructParams into the
% metaData structure
metaData.sessionType=makeStimStructParams.sessionType;
metaData.sessionObserver = makeStimStructParams.sessionObserver;
metaData.sessionDate = makeStimStructParams.sessionDate;
metaData.stimulusDir = makeStimStructParams.stimulusDir;
metaData.runNum = makeStimStructParams.runNum;
metaData.stimulusFile = makeStimStructParams.stimulusFile;
metaData.experimentTimeDateString = stimulus.metaData.exp.experimentTimeDateString;

% Get the stimulus ordering (A or B) from the protocol file name, and save
% this information in the metaData. This is derived from the last
% characeter of the protocol name.
tmp=stimulus.metaData.exp.protocolList(stimulus.metaData.exp.protocolIndex).name;
metaData.stimulusOrderAorB = tmp(end:end);

% Get the timing of the attention events and put this in the metaData
eventTimesArray=fmriBFDM_GetAttentionEvents(stimulus.metaData.params);
metaData.eventTimesArray=eventTimesArray;
[hitRate, falseAlarmRate]=fmriBFDM_GetAttentionPerformance(stimulus.metaData.params);
metaData.hitRate=hitRate;
metaData.falseAlarmRate=falseAlarmRate;
