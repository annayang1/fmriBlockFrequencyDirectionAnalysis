function [packetCellArray] = mriBDFM_FitModelToPacketCellArray(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = mriBDFM_FitModelToPacketCellArray(packetCellArray, hrfKernelStructCellArray)
%

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Construct the model object
temporalFit = tfeBTRM('verbosity','high');

% Define a parameter lock matrix, which in this case is empty
paramLockMatrix = [];

fprintf('>> Fitting the BTRM model\n');

 
            
for ss=1:nSubjects
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            fprintf('\t* Session <strong>%g</strong> / <strong>%g</strong>, Run <strong>%g</strong> / <strong>%g</strong>\n', ss, nSubjects, rr, nRuns);
            
            % grab the average hrf and prepare it as a kernel
            thePacket.kernel=prepareHRFKernel(hrfKernelStructCellArray{ss});

            % scale the kernel to retain unit amplitude
            thePacket.kernel.values=thePacket.kernel.values/(sum(thePacket.kernel.values)*1000);
            
            % downsample the stimulus values to 100 ms deltaT
            totalResponseDuration=thePacket.response.metaData.TRmsecs * ...
                length(thePacket.response.values);
            newStimulusTimebase=linspace(0,totalResponseDuration-100,totalResponseDuration/100);
            thePacket.stimulus=temporalFit.resampleTimebase(thePacket.stimulus,newStimulusTimebase);
            
            % How many trial instances are in this packet?
            defaultParamsInfo.nInstances = size(thePacket.stimulus.values,2);
            
            % Perform the fit
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

