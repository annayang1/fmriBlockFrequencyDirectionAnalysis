function eventTimesArray = mriBFDM_GetAttentionEvents(params)
% function eventTimesArray = mriBFDM_GetAttentionEvents(params)
%
% Returns an array of attention events for a given run
%

nTrials=params.nTrials;

eventTimesArray = [];
eventTimesArrayIndex = 1;

for ii = 1:nTrials
    % Check if an attention event occurred on this trial
    if ~(params.responseStruct.events(ii).attentionTask.theStartBlankIndex==-1);

        % Get the time of onset of this stimulus trial relative to the
        % start of the run        
        trialOnsetTimeSecs = ...
            params.responseStruct.events(ii).t(params.responseStruct.events(ii).attentionTask.T == 1)...
            - params.responseStruct.tBlockStart;
        eventTimesArray(eventTimesArrayIndex)=round(trialOnsetTimeSecs * 1000); % convert to msecs
        eventTimesArrayIndex=eventTimesArrayIndex+1;

    end % an attention event took place
end
