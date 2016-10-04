function [hitRate, falseAlarmRate] = mriBFDM_GetAttentionPerformance(params)
% function eventTimesArray = mriBFDM_GetAttentionEvents(params)
%
% Returns performance on attention trials
%

nTrials=params.nTrials;

attentionTaskFlag   = zeros(1,nTrials);
responseDetection   = zeros(1,nTrials);
hit                 = zeros(1,nTrials);
miss                = zeros(1,nTrials);
falseAlarm          = zeros(1,nTrials);
for i = 1:nTrials
    % Attentional 'blinks'
    if ~(params.responseStruct.events(i).attentionTask.theStartBlankIndex==-1);
        attentionTaskFlag(i) = 1;
    end
    % Subject key press responses
    if ~isempty(params.responseStruct.events(i).buffer) && ...
            any(~strcmp({params.responseStruct.events(i).buffer.charCode}, '='))
        responseDetection(i) = 1;
    end
    % Hits
    if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 1)
        hit(i) = 1;
    end
    % Misses
    if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 0)
        miss(i) = 1;
    end
    % False Alarms
    if (attentionTaskFlag(i) == 0) && (responseDetection(i) == 1)
        falseAlarm(i) = 1;
    end
end

hitRate = sum(hit)/sum(attentionTaskFlag);
falseAlarmRate = sum(falseAlarm)/(nTrials-sum(attentionTaskFlag));
end