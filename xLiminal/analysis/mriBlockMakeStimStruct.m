function [values timebase metaData] = mriBlockMakeStimStruct(params)
% [values timebase metaData] = mriBlockMakeStimStruct(params)
%
% Makes a stimulus structure

%% Copied from Manuel's code for pupil data. Needs to be modified for
% use with the blocked 7T data

%% Stimulus
% Load that .mat file produced by the stimulus computer
stimulus.metaData                           = load(params.stimulusFile);
% Get run duration
runDur                                      = sum(stimulus.metaData.params.trialDuration)*1000; % length of run (msec)
% Set the timebase
stimulus.timebase                           = 0:runDur-1;
zVect                                       = zeros(1,runDur);
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
end
timebase = stimulus.timebase;
values = stimulus.values;

% Trim meta data. Extract the relevant information. We assume that stimulus
% types are described by direction, frequency, and contrast. This might
% change.
conditionArray = [stimulus.metaData.params.theDirections' stimulus.metaData.params.theFrequencyIndices' stimulus.metaData.params.theContrastRelMaxIndices'];
[uniqueConditions, ~, idx] = unique(conditionArray, 'rows');
metaData.stimTypes = idx;
for ii = 1:length(uniqueConditions)
    if ~(stimulus.metaData.params.theFrequenciesHz == -1)
        % Fill out here
    else
        tmp = strsplit(stimulus.metaData.params.modulationFiles, ',');
        tmp = strsplit(tmp{conditionArray(ii, 1)}, '-');
        [~, tmp2] = fileparts(tmp{3});
        metaData.stimLabels{ii} = [tmp{2} '_' tmp2 '_' num2str(100*stimulus.metaData.params.theContrastsPct(conditionArray(ii, 3))*stimulus.metaData.params.theContrastMax) '%'];
    end
end
