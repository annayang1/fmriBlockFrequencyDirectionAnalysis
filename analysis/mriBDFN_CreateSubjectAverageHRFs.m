function [hrfKernelStructCellArray] = mriBDFN_CreateSubjectAverageHRFs(packetCellArray)
%function [hrfKernelStructCellArray] = mriBDFN_CreateSubjectAverageHRFs(packetCellArray)
%
% Create an average HRF for each subject across all runs

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);
hrfArray=[];
for ss=1:nSubjects
hrfArray=[];
counter=1;
for rr=1:nRuns
    thePacket=packetCellArray{ss,rr};
    if ~isempty(thePacket)
        hrfArray(counter,:)=thePacket.metaData.fourierFitToAttentionEvents.values;
        counter=counter+1;
    end % not an empty packet
end % loop over runs
meanHRF=mean(hrfArray);
meanHRF=meanHRF-meanHRF(1);
hrfKernelStructCellArray{ss}.values=meanHRF;
hrfKernelStructCellArray{ss}.timebase=thePacket.metaData.fourierFitToAttentionEvents.timebase;
hrfKernelStructCellArray{ss}.metaData.SEM=std(hrfArray)/sqrt(counter-1);
end % loop across subjects
