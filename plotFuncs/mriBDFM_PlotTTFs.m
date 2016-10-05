function []=mriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray)

% Build some arrays to identify the stimulus types in each packet
nSubjects=size(fitResultsStructAvgResponseCellArray,1);
nDirections=size(fitResultsStructAvgResponseCellArray,2);
nOrders=size(fitResultsStructAvgResponseCellArray,3);

modDirections={'LightFlux','L-M','S'};
stimOrders={'A','B'};
theFrequencies=[0,2,4,8,16,32,64];

fprintf('>> Generating TTF plots\n');

figure
for ss=1:nSubjects
    for ii=1:nDirections
        for ff=1:length(theFrequencies)
            theAmplitudes=[];
            for jj=1:nOrders
                stimTypes=fitResultsStructAvgResponseCellArray{ss,ii,jj}.stimTypes;
                theIndices=find(stimTypes==ff);
                theAmplitudes=[theAmplitudes fitResultsStructAvgResponseCellArray{ss,ii,jj}.paramsFit.paramMainMatrix(theIndices)'];
            end % loop through stim orders
            meanAmplitudeByFreq(ff)=mean(theAmplitudes);
            semAmplitudeByFreq(ff)=std(theAmplitudes)/sqrt(length(theAmplitudes));
        end % loop through frequencies
        subplot(nSubjects,nDirections,ii+(ss-1)*nDirections);
        plot(meanAmplitudeByFreq);
    end % loop over modulation directions
end % loop over subjects
gribble=1;