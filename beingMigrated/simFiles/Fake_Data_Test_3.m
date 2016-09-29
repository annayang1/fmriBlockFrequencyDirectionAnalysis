%% RUN fitBOLDmodel FIRST, AND THEN SET THE INDEX IMMEDIATELY BELOW TO WHAT
%  RUN YOU WANT, THEN JUST CALL THE ENTIRE THING

addpath('/Users/Shared/mriTemporalFitting/');

clear curStimMatrix
clear neuralVec
clear curAttnStartTimes
clear curAttnStartTimesRound

% pick a run index: between 1 and 6, if debugging (only light flux A)
indexToTest = 1;

% get the stimulus matrix
curStimMatrix = squeeze(stimMatrix(runsToFit(indexToTest),:,:));

% scale each neural vector by the amplitude parameter, then sum
neuralVec = sum(createNeuralTemporalModelFromStimMatrix(TS_timeSamples,curStimMatrix, ...
                ampStoreAll(indexToTest,:)',tau2storeAll(indexToTest,:)', ...
               ARampStoreAll(indexToTest,:)',paramStructFit));

% get attention start times for that run
curAttnStartTimes = attnStartTimes(runsToFit(indexToTest),:);

% get rid of filler values
curAttnStartTimes = curAttnStartTimes(curAttnStartTimes>-1);

% round attention start times
curAttnStartTimesRound = round(curAttnStartTimes);

% give an arbitrary value to the attention parameter. ~ 0.2
estimatedAttnAmplitude = 1;
            
% throw them in--amplitude can vary
neuralVec(curAttnStartTimesRound+1) = neuralVec(curAttnStartTimesRound+1)+estimatedAttnAmplitude;

%% EXAMPLE HRF, THEN CONVOLVE
gamma1 = 6; gamma2 = 12; gammaScale = 10; HRFexpectedLength = 16;

BOLDHRF = createCanonicalHRF(TS_timeSamples,gamma1,gamma2,gammaScale);
BOLDHRFtoTest = createCanonicalHRF(0:HRFexpectedLength,gamma1,gamma2,gammaScale);
% convolve with neural vector
fakeTimeSeries = neuralVec2BOLD(neuralVec,TS_timeSamples,BOLDHRF,TS_timeSamples);

%%
[hrf] = attentionFourier(TS_timeSamples,fakeTimeSeries,curAttnStartTimesRound,HRFexpectedLength,1) ;
hrf_Fourier = hrf ;
hrf_Fourier = hrf_Fourier - hrf_Fourier(1);
clear hrf ;

[hrf] = attentionFIR(TS_timeSamples,fakeTimeSeries,curAttnStartTimesRound',HRFexpectedLength,1) ;
hrf_FIR = hrf ;
hrf_FIR = hrf_FIR - hrf_FIR(1);

figure ;
set(gcf,'Position',[401 418 1474 460]);

subplot(2,2,2)
plot(0:HRFexpectedLength-1,hrf_FIR) ; title('FIR'); axis square;

subplot(2,2,1)
plot(0:HRFexpectedLength,BOLDHRFtoTest); axis square;
title('Ground-truth HRF');

subplot(2,2,3)
plot(TS_timeSamples,fakeTimeSeries); title('Fake Timeseries');

subplot(2,2,4)
plot(0:HRFexpectedLength-1,hrf_Fourier) ; title('Fourier');
axis square ;
