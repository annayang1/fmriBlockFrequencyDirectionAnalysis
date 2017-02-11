function [plotHandles]=fmriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray)

% Get the dimensions of the passed cell array
nSubjects=size(fitResultsStructAvgResponseCellArray,1);
nDirections=size(fitResultsStructAvgResponseCellArray,2);
nOrders=size(fitResultsStructAvgResponseCellArray,3);

% Define these constants. Probably should have the first three pulled from
% the passed cell array
modDirections={'LightFlux','L-M','S'};
stimOrders={'A','B'};
theFrequencies=[0,2,4,8,16,32,64];
colorStr = 'krb';
yAxisLimits=[-0.5 1.5];

% alert the user
fprintf('\t>> Generating TTF plots\n');

for ss=1:nSubjects
    
    plotHandles(ss)=figure();

    for ii=1:nDirections

        % Loop over the frequencies (and across the stimulus orders within
        % frequencies
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
        
        % Adjust the data to have the zero frequency response
        % correspond to zero percent signal change
        zeroFrequencyValue=meanAmplitudeByFreq(1);
        meanAmplitudeByFreq=meanAmplitudeByFreq-zeroFrequencyValue;
        
        % Fit the Watson model to the data, leaving out the 0th frequency
        [~, ~, frequenciesHz_fine,y,offset] = ...
            fitWatsonToTTF_errorGuided(theFrequencies(2:7),meanAmplitudeByFreq(2:7),semAmplitudeByFreq(2:7),0);
        
        % Plot this subject / direction
        subplot(1, nDirections,ii);
        plot(frequenciesHz_fine,y+offset,[colorStr(ii) '-']);
        hold on
        errorbar(theFrequencies(2:7),meanAmplitudeByFreq(2:7),semAmplitudeByFreq(2:7),[colorStr(ii) 'o']);
        set(gca,'FontSize',10); set(gca,'Xtick',theFrequencies); title(modDirections{ii}); axis square;
        set(gca,'Xscale','log'); xlabel('Frequency [Hz]'); ylabel('% change from 0 Hz condition');
        
        % Add bars to indicate the ±SEM boundary of the 0 Hz condition        
        plot(get(gca,'xlim'), [0 0], '--k'); % Adapts to x limits of current axes
        plot(get(gca,'xlim'), [semAmplitudeByFreq(1) semAmplitudeByFreq(1)], 'color',[0.5 0.5 0.5]); % Adapts to x limits of current axes
        plot(get(gca,'xlim'), [-semAmplitudeByFreq(1) -semAmplitudeByFreq(1)], 'color',[0.5 0.5 0.5]); % Adapts to x limits of current axes
        
        % Set the ylim
        ylim(yAxisLimits);
        
    end % loop over modulation directions
end % loop over subjects
