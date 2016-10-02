function [packetCellArray] = mriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = mriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray)
%
%

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Construct the model object
temporalFit = tfeIAMP('verbosity','none');

% Define a parameter lock matrix, which in this case is empty
paramLockMatrix = [];

fprintf('>> Regressing out the attention event effects\n');

for ss=1:nSubjects
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            fprintf('\t* Session <strong>%g</strong> / <strong>%g</strong>, Run <strong>%g</strong> / <strong>%g</strong>\n', ss, nSubjects, rr, nRuns);
            
            tempPacket=thePacket;
            tempPacket.stimulus.values=zeros(1,size(thePacket.stimulus.timebase,2));
            tempPacket.stimulus.values(1,thePacket.stimulus.metaData.eventTimesArray)=50;
            tempPacket.stimulus.values= ...
                    tempPacket.stimulus.values-mean(tempPacket.stimulus.values);
            tempPacket.kernel=hrfKernelStructCellArray{ss};
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
