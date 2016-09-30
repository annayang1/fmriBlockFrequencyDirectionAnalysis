function [values,timebase,metaData] = mriBFDM_MakeResponseStruct(makeResponseStructParams)
% function [values,timebase,metaData] = mriBFDM_MakeResponseStruct(makeResponseStructParams)
%
%

%% load the response file
resp                    = load_nifti(makeResponseStructParams.responseFile);

% create the timebase
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
timebase = 0:TR:(runDur*TR)-TR;

% load the region of interest
roi                     = load_nifti(makeResponseStructParams.areasFile);
regionIndicies                   = find(abs(roi.vol)==makeResponseStructParams.areasIndex);
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));

% Assemble the values
regionTimeSeries                = flatVol(regionIndicies,:);
regionalSignal                = median(regionTimeSeries,1);
timeSeriesMean=mean(regionalSignal);
regionalSignal=(regionalSignal-timeSeriesMean)/timeSeriesMean*100;
values=regionalSignal;

% Assemble the metaData
metaData.packetType='bold';
metaData.responseFile=makeResponseStructParams.responseFile;
metaData.responseFile=makeResponseStructParams.areasFile;
metaData.responseUnits='%change';
metaData.originalTimeSeriesMean=timeSeriesMean;

% NEED TO DO SOME PROCESSING OF THE FILENAME HERE TO EXTRACT THE
% INFORMATION IT CONTAINS REGARDING THE SERIES NUMBER, STIMULUS TYPE