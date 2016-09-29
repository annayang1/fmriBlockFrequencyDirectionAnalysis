function [responseStruct] = mriBFDM_MakeResponseStruct(params)
% [values,TimeVectorFine] = mriBFDM_MakeResponseStruct(params)
%
% loads time series data

%% load the response
resp                    = load_nifti(params.responseFile);

% create the timebase
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
responseStruct.timebase = 0:TR:(runDur*TR)-TR;

% load the region of interest
roi                     = load_nifti(params.areasFile);
regionIndicies                   = find(abs(roi.vol)==params.areasIndex);
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));
% Pull out the indicated region index signal
regionTimeSeries                = flatVol(regionIndicies,:);
regionalSignal                = median(regionTimeSeries,1);
timeSeriesMean=mean(regionalSignal);
regionalSignal=(regionalSignal-timeSeriesMean)/timeSeriesMean*100;
% add the response to the struct
responseStruct.values=regionalSignal;
responseStruct.metaData.packetType='bold';
responseStruct.metaData.responseFile=params.responseFile;
responseStruct.metaData.responseUnits='psc';
responseStruct.metaData.originalTimeSeriesMean=timeSeriesMean;