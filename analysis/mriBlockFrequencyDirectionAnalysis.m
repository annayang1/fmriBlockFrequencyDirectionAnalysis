% mriBlockFrequencyDirectionAnalysis.
%
% Code to analyze data collected at Mt. Sinai using 12-second blocked
%  stimulus presentations of uniform field flicker between 2 and 64 Hz,
%  with different modulation directions (Light flux, L-M, and S) in
%  separate runs. The stimuli had a three-second half-cosine window at
%  onset and offset.

% Housekeeping
clearvars; close all; clc;
warning on;

% Discover user name 
[~, userName] = system('whoami');
userName = strtrim(userName);

% obtain the stimulus structures for all sessions and run
[stimStructCellAray] = mriBFDM_LoadStimStructCellArray(userName);

% obtain the response structures for all sessions and run
[responseStructCellAray] = mriBFDM_LoadResponseStructCellArray(userName);







% 1 -> use canonical HRF, 0 -> extract HRF using FIR
bCanonicalHRF = 0;

% Boolean: 1 -> go into debug mode--only fit light flux A
bDEBUG = 0;
bFreeFloatParams = 1;


%% LOAD TIME SERIES AND GET STIMULUS (& ATTENTION) START TIMES

% load time series
[avgTS, avgTSprc, tsFileNames, stimTypeArr, runOrder] ...
= loadTimeSeriesData(subj_name,session);

% get all stimulus values and start times, as well as the attention task
% start times
[startTimesSorted, stimValuesSorted, attnStartTimes] = mriBlockFrequencyDirectionMakeStimStruct(subj_name,session);

% Time Series sampling points
TS_timeSamples = [1:336]-1;

%% HRF PARAMETERS

% how long we expect the HRF to be
lengthHRF = 15;

%% DERIVE HRF FROM DATA, CREATE STIMULUS MODELS

% derive HRF from data
[BOLDHRF, cleanedData, SEHRF]= deriveHRFwrapper(avgTSprc,attnStartTimes,lengthHRF,'Fourier');

% in case we use the FIR extracted HRF; if we are not, 'hrf' never gets
% used
hrfPointsToSample = [1 1000:1000:length(BOLDHRF)];

hrf = BOLDHRF(hrfPointsToSample);

if bCanonicalHRF == 1     
   % Double Gamma HRF--get rid of the FIR-extracted HRF from earlier
   clear BOLDHRF
   clear hrf
   BOLDHRF = createCanonicalHRF(0:lengthHRF,6,12,10);
else 
   % initialize vector for HRF
   BOLDHRF = zeros([1 size(avgTSprc,2)]);
   % align HRF with 0 mark
   hrf = hrf-hrf(1);
   
   figure;
   errorbar(0:lengthHRF,hrf,SEHRF(hrfPointsToSample),'LineWidth',2)
   xlabel('Time/s'); ylabel('Signal'); set(gca,'FontSize',15);
   title('HRF');
   
   % make it the right size
   BOLDHRF(1:length(hrf)) = hrf;     
end

%% STIMULUS VECTOR CREATION

% resolution to sample stimulus step function
stepFunctionRes = 50;
% length of cosine ramp (seconds)
cosRamp = 3;
% stimulus duration
stimDuration = 12;

if bFreeFloatParams == 1
   startTimesSorted = 0:stimDuration:max(TS_timeSamples); 
   startTimesSorted = repmat(startTimesSorted,[size(stimValuesSorted,1) 1]);
end

%% GET BETA AND MODEL FIT

% create stimulus vector
[stimMatrix,stimValuesForRunStore,startTimesSorted_A,startTimesSorted_B, ...
stimValuesSorted_A,stimValuesSorted_B,actualStimulusValues] ...
= createStimMatrix(startTimesSorted,stimValuesSorted,tsFileNames, ...
TS_timeSamples,stimDuration,stepFunctionRes,cosRamp,bFreeFloatParams);

if bFreeFloatParams == 1
    stimValuesSorted_A = [0 stimValuesSorted_A];    
end

%% SPECIFY PARAMETERS TO FIT 

% -------- SPECIFY ALL NEURAL PARAMETERS HERE --------

paramStruct = paramCreateBDCM(size(stimMatrix,2));

% --------

% put HRF in parameter struct
paramStruct.HRF = BOLDHRF;
paramStruct.HRFtimeSamples = 0:lengthHRF;

% automatically get number of parameters
numParamTypes = size(paramStruct.paramMainMatrix,2);

% for each run, create a locking matrix

if bFreeFloatParams == 1
    paramLockMatrix = [];
elseif bFreeFloatParams == 0
    for i = 1:size(stimValuesForRunStore,1)
       paramLockMatrix(i,:,:) = createParamLockMatrixVanilla(actualStimulusValues, ...
                                stimValuesForRunStore(i,:),numParamTypes);
    end
else
   error('bFreeFloatParams not set to valid value'); 
end

%%
% store parameters--initialize matrices
storeUnique = zeros([0 0 0]);
storeAll = zeros([0 0 0]);

reconstructedTSmat = [];
MSEstore = [];

% if in debug mode, only fit light flux A
if bDEBUG == 1
   runsToFit = find(stimTypeArr == 1 & runOrder == 'A');
else
   runsToFit = 1:size(stimMatrix,1);  
end

for i = 1:length(runsToFit)
    if bFreeFloatParams == 0
        % call fitting routine
        [paramStructFit,fval]= fitNeuralParams(squeeze(stimMatrix(runsToFit(i),:,:)),TS_timeSamples,squeeze(paramLockMatrix(runsToFit(i),:,:)),cleanedData(runsToFit(i),:),paramStruct);
    elseif bFreeFloatParams == 1
        [paramStructFit,fval]= fitNeuralParams(squeeze(stimMatrix(runsToFit(i),:,:)),TS_timeSamples,paramLockMatrix,cleanedData(runsToFit(i),:),paramStruct);
    else
       error('bFreeFloatParams set at invalid value'); 
    end
    % store all parameters for each run, regardless of daisy-chaining
    storeAll(size(storeAll,1)+1,:,:) = paramStructFit.paramMainMatrix; 
    
    % store MSE measure
    MSEstore(length(MSEstore)+1) = fval;
    
     % Determine which stimulus values went with which parameter
   if strfind(char(tsFileNames(runsToFit(i))),'_A_')
      valueLookup = stimValuesSorted_A(stimValuesSorted_A>0);
   elseif strfind(char(tsFileNames(runsToFit(i))),'_B_')
      valueLookup = stimValuesSorted_B(stimValuesSorted_B>0);
   else
      valueLookup = [] ; 
   end
   
    % get only unique stim values, and their corresponding locked params
   [stimValueToPlot,ia] = unique(valueLookup);     
   
   % sort parameters of each type
   paramsForUniqueStim = [];
    for j = 1:size(paramStructFit.paramMainMatrix,2)
       paramsForUniqueStim(:,j) = paramStructFit.paramMainMatrix(ia,j);
    end
    
    % do this for each run
    storeUnique(size(storeUnique,1)+1,:,:) = paramsForUniqueStim;
    
    % store reconstructed time series
     [~,reconstructedTS] = forwardModel(squeeze(stimMatrix(runsToFit(i),:,:)),TS_timeSamples,cleanedData(runsToFit(i),:),paramStructFit);
     reconstructedTSmat(size(reconstructedTSmat,1)+1,:) = reconstructedTS;
     display(['run number: ' num2str(i)]);
end
%%
if bDEBUG == 1
    % getting statistics over runs
   [meanMatrix, SEmatrix, stimTypeTagMatrix, paramNamesTagMatrix] = ...
    paramStatistics(storeUnique,stimTypeArr(runsToFit),paramStructFit.paramNameCell);
   
   AvgTS = mean(cleanedData(runsToFit,:));
   StdTS =  std(cleanedData(runsToFit,:))./sqrt(size(storeUnique,1));
   MSE = mean(MSEstore);
   AvgTS_model = mean(reconstructedTSmat);
   
   % create cell for plotting stimulus starts
   stimValuesMatSorted_A_cell = {} ;
    for j = 1:length(stimValuesSorted_A)
       stimValuesMatSorted_A_cell{j} = num2str(stimValuesSorted_A(j)) ; 
    end
    
    stimNamesCell = {'Light Flux'};    
    plotParamsWrapper(actualStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell,[1 4 7])
    
    % plot full time series
    figure;
    plotLinModelFits(TS_timeSamples,AvgTS,AvgTS_model, ...
                 startTimesSorted_A,stimValuesMatSorted_A_cell,stimValuesSorted_A,StdTS,MSE);
    title('Light flux A'); xlabel('Time / s'); ylabel('% signal change');
else
    % Self-Explanatory Variable Names
    numberOfRuns = sum(stimTypeArr==1) ;
    numRunsPerStimOrder = sum(stimTypeArr==1 & runOrder=='A') ;   % Stim order A -or- B
    %% Parameter averaging    
    [meanMatrix, SEmatrix, stimTypeTagMatrix, paramNamesTagMatrix] = ...
    paramStatistics(storeUnique,stimTypeArr,paramStructFit.paramNameCell);
    %% TTF & HRF Plots
    stimNamesCell = {'Light Flux','L - M','S'};    
    plotParamsWrapper(actualStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell)
    %%  TIME SERIES MEAN AND STD ERROR
    
    % Average Time Series for Each Combination of Stimulus Type & Run order
    LightFluxAvgTS_A =  mean(cleanedData(stimTypeArr == 1 & runOrder == 'A',:)) ;
    L_minus_M_AvgTS_A = mean(cleanedData(stimTypeArr == 2 & runOrder == 'A',:)) ;
    S_AvgTS_A =         mean(cleanedData(stimTypeArr == 3 & runOrder == 'A',:)) ;

    LightFluxAvgTS_B =  mean(cleanedData(stimTypeArr == 1 & runOrder == 'B',:)) ;
    L_minus_M_AvgTS_B = mean(cleanedData(stimTypeArr == 2 & runOrder == 'B',:)) ;
    S_AvgTS_B =         mean(cleanedData(stimTypeArr == 3 & runOrder == 'B',:)) ;

    % Standard Error of Time Series
    LightFluxStdTS_A =  (std(cleanedData(stimTypeArr == 1 & runOrder == 'A',:)))./sqrt(numRunsPerStimOrder) ;
    L_minus_M_StdTS_A = (std(cleanedData(stimTypeArr == 2 & runOrder == 'A',:)))./sqrt(numRunsPerStimOrder) ;
    S_StdTS_A =         (std(cleanedData(stimTypeArr == 3 & runOrder == 'A',:)))./sqrt(numRunsPerStimOrder) ;

    LightFluxStdTS_B =  (std(cleanedData(stimTypeArr == 1 & runOrder == 'B',:)))./sqrt(numRunsPerStimOrder) ;
    L_minus_M_StdTS_B = (std(cleanedData(stimTypeArr == 2 & runOrder == 'B',:)))./sqrt(numRunsPerStimOrder) ;
    S_StdTS_B =         (std(cleanedData(stimTypeArr == 3 & runOrder == 'B',:)))./sqrt(numRunsPerStimOrder) ;
    
    %% MEAN SQUARED ERROR VALUES
    
    LightFluxMSE_A =  mean(MSEstore(stimTypeArr == 1 & runOrder == 'A')) ;
    L_minus_M_MSE_A = mean(MSEstore(stimTypeArr == 2 & runOrder == 'A')) ;
    S_MSE_A =         mean(MSEstore(stimTypeArr == 3 & runOrder == 'A')) ;

    LightFluxMSE_B =  mean(MSEstore(stimTypeArr == 1 & runOrder == 'B')) ;
    L_minus_M_MSE_B = mean(MSEstore(stimTypeArr == 2 & runOrder == 'B')) ;
    S_MSE_B =         mean(MSEstore(stimTypeArr == 3 & runOrder == 'B')) ;

    %% MEANS FOR MODEL FITS

    % Do the Same for 'Reconstructed' Time Series
    LightFluxAvgTS_Model_A =  mean(reconstructedTSmat(stimTypeArr == 1 & runOrder == 'A',:)) ;
    L_minus_M_AvgTS_Model_A = mean(reconstructedTSmat(stimTypeArr == 2 & runOrder == 'A',:)) ;
    S_AvgTS_Model_A =         mean(reconstructedTSmat(stimTypeArr == 3 & runOrder == 'A',:)) ;

    LightFluxAvgTS_Model_B =  mean(reconstructedTSmat(stimTypeArr == 1 & runOrder == 'B',:)) ;
    L_minus_M_AvgTS_Model_B = mean(reconstructedTSmat(stimTypeArr == 2 & runOrder == 'B',:)) ;
    S_AvgTS_Model_B =         mean(reconstructedTSmat(stimTypeArr == 3 & runOrder == 'B',:)) ;

    %yLimits = [min([LightFluxBeta L_minus_M_Beta S_Beta]) max([LightFluxBeta L_minus_M_Beta S_Beta])] ;

    %% Time Series plots 
    % Use Function for plotting Data:
    % -- plotLinModelFits -- 

    % Create Cells for Labeling Plots
    stimValuesMatSorted_A_cell = {} ;
    for i = 1:length(stimValuesSorted_A)
       stimValuesMatSorted_A_cell{i} = num2str(stimValuesSorted_A(i)) ; 
    end

    stimValuesMatSorted_B_cell = {} ;
    for i = 1:length(stimValuesSorted_B)
       stimValuesMatSorted_B_cell{i} = num2str(stimValuesSorted_B(i)) ; 
    end

    % Set Figure Dimensions
    figure;
    set(gcf,'Position',[156 372 1522 641])

    % Light Flux -A
    subplot(3,2,1)
    plotLinModelFits(TS_timeSamples,LightFluxAvgTS_A,LightFluxAvgTS_Model_A, ...
                     startTimesSorted_A,stimValuesMatSorted_A_cell,stimValuesSorted_A,LightFluxStdTS_A,LightFluxMSE_A);
    title('Light flux A'); xlabel('Time / s'); ylabel('% signal change');

    % L minus M -A
    subplot(3,2,3)
    plotLinModelFits(TS_timeSamples,L_minus_M_AvgTS_A,L_minus_M_AvgTS_Model_A, ...
                     startTimesSorted_A,stimValuesMatSorted_A_cell,stimValuesSorted_A,L_minus_M_StdTS_A,L_minus_M_MSE_A);
    title('L - M A'); xlabel('Time / s'); ylabel('% signal change');

    % S -A
    subplot(3,2,5)
    plotLinModelFits(TS_timeSamples,S_AvgTS_A,S_AvgTS_Model_A, ...
                     startTimesSorted_A,stimValuesMatSorted_A_cell,stimValuesSorted_A,S_StdTS_A,S_MSE_A);
    title('S A'); xlabel('Time / s'); ylabel('% signal change');

    % Light Flux -B
    subplot(3,2,2)
    plotLinModelFits(TS_timeSamples,LightFluxAvgTS_B,LightFluxAvgTS_Model_B, ...
                     startTimesSorted_B,stimValuesMatSorted_B_cell,stimValuesSorted_B,LightFluxStdTS_B,LightFluxMSE_B);
    title('Light flux B');

    % L minus M -B
    subplot(3,2,4)
    plotLinModelFits(TS_timeSamples,L_minus_M_AvgTS_B,L_minus_M_AvgTS_Model_B, ...
                     startTimesSorted_B,stimValuesMatSorted_B_cell,stimValuesSorted_B,L_minus_M_StdTS_B,L_minus_M_MSE_B);
    title('L - M B');

    % S -B
    subplot(3,2,6)
    plotLinModelFits(TS_timeSamples,S_AvgTS_B,S_AvgTS_Model_B, ...
                     startTimesSorted_B,stimValuesMatSorted_B_cell,stimValuesSorted_B,S_StdTS_B,S_MSE_B);
    title('S B');
end
