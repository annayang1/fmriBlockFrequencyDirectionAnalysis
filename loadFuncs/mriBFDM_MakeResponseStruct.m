function [values,timebase,metaData] = mriBFDM_MakeResponseStruct(makeResponseStructParams)
% function [values,timebase,metaData] = mriBFDM_MakeResponseStruct(makeResponseStructParams)
%
%

% load the response file
resp                    = load_nifti(makeResponseStructParams.responseFile);

% create the timebase
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
timebase = (0:TR:(runDur*TR)-TR)*1000;

% load the region of interest

eccData                      = load_nifti(makeResponseStructParams.eccFile);
areaData                     = load_nifti(makeResponseStructParams.areasFile);
areaIndices = find(abs(areaData.vol)==makeResponseStructParams.areaIndex &...
    eccData.vol>makeResponseStructParams.eccRange(1) &...
    eccData.vol<makeResponseStructParams.eccRange(2));

volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));

% Assemble the values
regionTimeSeries                = flatVol(areaIndices,:);
regionalSignal                = median(regionTimeSeries,1);
timeSeriesMean=mean(regionalSignal);
regionalSignal=(regionalSignal-timeSeriesMean)/timeSeriesMean*100;
values=regionalSignal;

% Assemble the metaData
metaData.packetType='bold';
metaData.centralTendencyMethod='median';
metaData.responseFile=makeResponseStructParams.responseFile;
metaData.areasFile=makeResponseStructParams.areasFile;
metaData.eccFile=makeResponseStructParams.eccFile;
metaData.areasIndex=makeResponseStructParams.areaIndex;
metaData.eccRange=makeResponseStructParams.eccRange;
metaData.responseUnits='%change';
metaData.originalTimeSeriesMean=timeSeriesMean;
metaData.scanNumber=makeResponseStructParams.scanNumber;
metaData.modulationDirection=makeResponseStructParams.modulationDirection;
metaData.blockOrder=makeResponseStructParams.blockOrder;
metaData.sessionObserver=makeResponseStructParams.sessionObserver;
metaData.sessionDate=makeResponseStructParams.sessionDate;
metaData.TRmsecs=TR*1000;
metaData.stimulusOrderAorB = makeResponseStructParams.stimulusOrderAorB;
