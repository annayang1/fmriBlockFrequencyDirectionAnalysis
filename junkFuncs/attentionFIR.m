function [hrf, timeSeriesNoAttn] = attentionFIR(originalTimeSamples,timeSeries,eventTimes,HRFduration,sampT,unitOfTime)

% function [hrf, timeSeriesNoAttn] = attentionFIR(originalTimeSamples,timeSeries,eventTimes,HRFduration,sampT)
%
% infers HRF from attention task
%
% originalTimeSamples: time samples for time series
% timeSeries         : self-explanatory
% eventTimes     : when each attention task began
% HRFduration        : duration of the HRF. should be a multiple of sampT
% sampT  : TR

if strcmp(unitOfTime,'milliseconds')
    originalTimeSamples = originalTimeSamples./1000;
    eventTimes = eventTimes./1000;
    HRFduration = HRFduration./1000;
    sampT = sampT./1000;
elseif strcmp(unitOfTime,'seconds')
    originalTimeSamples = originalTimeSamples./1;
else
    error('attentionFIR: pick valid unit of time. Valid inputs: 1) milliseconds 2) seconds');
end

% normalize everything to 1 to make shift easier
TRsFromTimeSamples = originalTimeSamples./sampT;
eventTimes = eventTimes./sampT;
eventTimes = round(eventTimes);

% HELPER VECTOR FOR SHIFT
timeShiftScale = [1:HRFduration./sampT]-1;

% MATRIX OF START TIMES TO BE SHIFTED
timesToBeShifted = repmat(eventTimes',[1 HRFduration]);
timesToBeShifted = round(timesToBeShifted);

% IMPLEMENT SHIFT
timeShiftedMatrix = timesToBeShifted+repmat(timeShiftScale,[size(timesToBeShifted,1) 1]).*sampT;

% CREATES DESIGN MATRIX
for i = 1:length(timeShiftScale);
   impulseVector = double(ismember(TRsFromTimeSamples,timeShiftedMatrix(:,i)));
%   designMatrix(:,i) = impulseVector;
   designMatrix(:,i) = impulseVector - mean(impulseVector);
end

% ADD THE REGRESSOR FOR THE MEAN
designMatrix = [ones([size(designMatrix,1) 1]) designMatrix];

% GET BETA VALUES
betaValues = designMatrix\timeSeries;

% HRF IS ALL BETA VALUES EXCEPT FOR THE MEAN VECTOR
hrf = betaValues(2:length(betaValues))';

% REGRESS ATTENTION FROM TIMES SERIES
% timeSeriesNoAttn = timeSeries - sum(designMatrix(:,2:size(designMatrix,2)).*repmat(hrf,[size(designMatrix,1) 1]),2)';

timeSeriesNoAttn = timeSeries - designMatrix*betaValues; 
timeSeriesNoAttn = timeSeriesNoAttn';

gribble = 1;