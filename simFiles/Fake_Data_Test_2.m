%% TEST HRF FUNCTIONS

%% Specify Subject & Session, With Dropbox Folder

addpath('/Users/Shared/mriTemporalFitting/');

subj_name = 'HERO_gka1' ; 
% *** Subject Pool ***
%     'HERO_asb1' 
%     'HERO_gka1'


session = 'all' ;
% *** Dates ***
%     '041416' ...
%     '041516' ...

%% LOAD TIME SERIES AND GET STIMULUS (& ATTENTION) START TIMES

% load time series
[avgTS, avgTSprc, tsFileNames, stimTypeArr, runOrder] ...
= loadTimeSeriesData(subj_name,session);

% get all stimulus values and start times, as well as the attention task
% start times
[startTimesSorted, stimValuesSorted, attnStartTimes] = orderStartTimes(subj_name,session);

% Time Series sampling points
t = 0:335;

%% PICK JUST ONE RUN

% index for one run
testIndex = 36;

% grab start times, corresponding stimulus values, attention times
% curStartTimesSorted = startTimesSorted(testIndex,:);
% curStimValuesSorted = stimValuesSorted(testIndex,:);
curAttnStartTimes = attnStartTimes(testIndex,:);

% matrix has some filler -1 values, so eliminate those
% goodInd = curStimValuesSorted > 0;
% 
% curStartTimesSorted = curStartTimesSorted(goodInd);
% curStimValuesSorted = curStimValuesSorted(goodInd);

% has its own set of fillers
curAttnStartTimes = curAttnStartTimes(curAttnStartTimes>-1);

%% STIMULUS VECTOR CREATION

% resolution to sample stimulus step function
stepFunctionRes = 50;
% length of cosine ramp (seconds)
cosRamp = 3;
% stimulus duration
stimDuration = 12;

%%

% create stimulus vector
[stimMatrix,paramLockMatrix,startTimesSorted_A,startTimesSorted_B, ...
stimValuesSorted_A,stimValuesSorted_B,actualStimulusValues] ...
= createStimMatrix(startTimesSorted,stimValuesSorted,tsFileNames, ...
t,stimDuration,stepFunctionRes,cosRamp);

% get just one stimulus
curStimMatrix = squeeze(stimMatrix(testIndex,:,:));
%%
% random amplitudes
ampRand = rand([size(curStimMatrix,1) 1]).*2 - 1;

% create neural vector
neuralVec = sum(repmat(ampRand,[1 size(curStimMatrix,2)]).*curStimMatrix);

%%
% round attention start times
curAttnStartTimesRound = round(curAttnStartTimes);

estimatedAttnAmplitude = 1;

% throw them in--amplitude can vary
neuralVec(curAttnStartTimesRound) = neuralVec(curAttnStartTimesRound)+estimatedAttnAmplitude;
%% EXAMPLE HRF, THEN CONVOLVE
gamma1 = 6; gamma2 = 12; gammaScale = 10; HRFexpectedLength = 16;

BOLDHRF = createCanonicalHRF(t,gamma1,gamma2,gammaScale);
BOLDHRFtoTest = createCanonicalHRF(1:HRFexpectedLength,gamma1,gamma2,gammaScale);
% convolve with neural vector
fakeTimeSeries = neuralVec2BOLD(neuralVec,t,BOLDHRF,t);
%%
[hrf] = attentionFourier(t,fakeTimeSeries,curAttnStartTimesRound,HRFexpectedLength,1) ;
hrf_Fourier = hrf ;
hrf_Fourier = hrf_Fourier - hrf_Fourier(1);
clear hrf ;

[hrf] = attentionFIR(t,fakeTimeSeries,curAttnStartTimesRound',HRFexpectedLength,1) ;
hrf_FIR = hrf ;
hrf_FIR = hrf_FIR - hrf_FIR(1);

figure ;
set(gcf,'Position',[401 418 1474 460]);

subplot(2,2,2)
plot(hrf_FIR) ; title('FIR'); axis square;

subplot(2,2,1)
plot(1:HRFexpectedLength,BOLDHRFtoTest); axis square;
title('Ground-truth HRF');

subplot(2,2,3)
plot(t,fakeTimeSeries); title('Fake Timeseries');

subplot(2,2,4)
plot(hrf_Fourier) ; title('Fourier');
axis square ;
