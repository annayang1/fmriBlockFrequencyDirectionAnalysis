function [hrfKernelStructCellArray] = fmriBDFN_CreateSubjectAverageHRFs(packetCellArray)
%function [hrfKernelStructCellArray] = fmriBDFN_CreateSubjectAverageHRFs(packetCellArray)
%
% Create an average HRF for each subject across all runs

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

for ss=1:nSubjects
    hrfArray=[];
    counter=1;
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            hrfArray(counter,:)=thePacket.response.metaData.fourierFitToAttentionEvents.values;
            currentTimebase=thePacket.response.metaData.fourierFitToAttentionEvents.timebase;
            counter=counter+1;
        end % not an empty packet
    end % loop over runs
    
    % Obtain the mean HRF
    meanHRF=mean(hrfArray);
    hrfKernelStructCellArray{ss}.values=meanHRF;
    hrfKernelStructCellArray{ss}.timebase=currentTimebase;
    hrfKernelStructCellArray{ss}.metaData.SEM=std(hrfArray)/sqrt(counter-1);

end % loop over subjects
