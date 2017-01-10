function [peakFreqArray,peakAmpArray]=fmriBDFM_DerivePeakAmpFreq(fitResultsStructAvgResponseCellArray)

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
fprintf('\t>> Generating Amplitude and Frequency plots\n');

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
        [~, ~, frequenciesHz_fine,hi_resWatsonFit,offset] = ...
            fitWatsonToTTF_errorGuided(theFrequencies(2:7),meanAmplitudeByFreq(2:7),semAmplitudeByFreq(2:7),0);
        
        % Identify and retain the amplitude and peak frequency for this
        % stimulus
        
        maxAmplitude=max(hi_resWatsonFit);
        peakFreqIdx=find(hi_resWatsonFit==maxAmplitude);
        peakFreqArray(ss,ii)=frequenciesHz_fine(peakFreqIdx(1));
        peakAmpArray(ss,ii)=maxAmplitude+offset;
        

    end % loop over modulation directions
end % loop over subjects
