function [packetCellArray] = fmriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = fmriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray)
%
%

verbosity='none';

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Construct the model object
temporalFit = tfeIAMP('verbosity','none');

% Define a parameter lock matrix, which in this case is empty
paramLockMatrix = [];

fprintf('\t>> Regressing out the attention event effects\n');

for ss=1:nSubjects
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            if strcmp(verbosity,'full')
                fprintf('\t\t* Session <strong>%g</strong> / <strong>%g</strong>, Run <strong>%g</strong> / <strong>%g</strong>\n', ss, nSubjects, rr, nRuns);
            end
            
            % create a stimulusStruct that models the attention events as
            % impulses
            stimulusStruct.timebase=thePacket.stimulus.timebase;
            stimulusStruct.values=stimulusStruct.timebase*0;
            stimulusStruct.values(1,thePacket.stimulus.metaData.eventTimesArray)=1;
            stimulusStruct.values= ...
                stimulusStruct.values-mean(stimulusStruct.values);
            
            % prepare kernelStruct from the mean HRF for each subject
            kernelStruct=prepareHRFKernel(hrfKernelStructCellArray{ss});
            
            % assemble a tempPacket to be used for the fitting
            tempPacket.response = thePacket.response;
            tempPacket.stimulus = stimulusStruct;
            tempPacket.kernel = kernelStruct;
            tempPacket.metaData = [];
            
            defaultParamsInfo.nInstances = 1;
            [paramsFit,~,modelResponseStruct] = ...
                temporalFit.fitResponse(tempPacket,...
                'defaultParamsInfo', defaultParamsInfo, ...
                'paramLockMatrix',paramLockMatrix, ...
                'searchMethod','linearRegression');
            
            % remove the modeled attention event response from the data
            thePacket.response.values=thePacket.response.values-modelResponseStruct.values;
            
        end % not an empty packet
    end % loop over runs
end % loop over subjects

% close the model object
clear temporalFit
