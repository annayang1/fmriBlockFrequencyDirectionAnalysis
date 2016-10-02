function [packetCellArray] = mriBDFM_FitModelToPacketCellArray(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = mriBDFM_FitModelToPacketCellArray(packetCellArray, hrfKernelStructCellArray)
%

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Construct the model object
temporalFit = tfeBTRM('verbosity','none');

% Define a parameter lock matrix, which in this case is empty
paramLockMatrix = [];

for ss=1:nSubjects
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            
            % How many trial instances are in this packet?
            defaultParamsInfo.nInstances = size(thePacket.stimulus.values,2);
            [paramsFit,~,modelResponseStruct] = ...
                temporalFit.fitResponse(thePacket,...
                'defaultParamsInfo', defaultParamsInfo, ...
                'paramLockMatrix',paramLockMatrix);
            
            temporalFit.plot(thePacket.response);
            temporalFit.plot(modelResponseStruct,'NewWindow','false');
            
        end % not an empty packet
    end % loop over runs
end % loop over subjects

end

