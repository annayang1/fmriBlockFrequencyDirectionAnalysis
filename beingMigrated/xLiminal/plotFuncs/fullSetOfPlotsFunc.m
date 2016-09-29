function fullSetOfPlotsFunc(fitResults)

% makes full set of plots for BDCM model. Specific to BDCM modeling.

%% PLOT HRF

figure;
errorbar(0:fitResults.lengthHRF,fitResults.hrf,fitResults.SEHRF(fitResults.hrfPointsToSample),'LineWidth',2)
xlabel('Time/s'); ylabel('Signal'); set(gca,'FontSize',15);
title('HRF');

%% PARAMETER PLOTS

% Parameter averaging    
[meanMatrix, SEmatrix, stimTypeTagMatrix, paramNamesTagMatrix] = ...
paramStatistics(permute(fitResults.storeFitParams,[1 3 2]),fitResults.stimTypeCode,fitResults.paramsFit.paramNameCell);
% TTF & tau2 plots
stimNamesCell = {'Light Flux','L - M','S'};    
plotParamsWrapper(fitResults.uniqueStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell)

%% TIME SERIES FIT PLOTS

% get time series statistics
[avgTS, stdTS, RMS, modelTS, idCell] = timeSeriesStatisticsBDCM(fitResults.cleanedData,fitResults.errorStore,fitResults.reconstructedTSmat,fitResults.stimTypeCode,fitResults.runOrder);
% plot
plotModelFitsWrap(fitResults.timebase, avgTS, stdTS, RMS, modelTS, idCell, ...
                     fitResults.startTimesSorted_A, fitResults.stimValuesSorted_A, ...
                     fitResults.startTimesSorted_B, fitResults.stimValuesSorted_B)

%% CARRY OVER MATRICES

% loop over runs
for i = 1:size(fitResults.storeFitParams,1)
    stimForRun = fitResults.stimValues(i,:);
    % get unique stimulus values
    uniqueTempFreq = unique(stimForRun);
    % initialize carry over matrices
    carryOverMatSubAmpl = 0./zeros([length(uniqueTempFreq) length(uniqueTempFreq)]);
    carryOverMatSubtau2 = 0./zeros([length(uniqueTempFreq) length(uniqueTempFreq)]);
    counterMatrixSub = zeros([length(uniqueTempFreq) length(uniqueTempFreq)]);
    % loop over temp freqs in each run
    for j = 2:length(stimForRun)
        % get the amplitude and tau values
        ampl = fitResults.storeAll(i,j,1);
        tau2 = fitResults.storeAll(i,j,2);
        whereToPut1 = stimForRun(j)  ==uniqueTempFreq;
        whereToPut2 = stimForRun(j-1)==uniqueTempFreq;
        if isnan(carryOverMatSubAmpl(whereToPut1,whereToPut2))
            % place them appropriately in the carry over matrix for ampllitude
            carryOverMatSubAmpl(whereToPut1,whereToPut2) = ampl;
            % do the same for tau2
            carryOverMatSubtau2(whereToPut1,whereToPut2) = tau2;
        else
            % place them appropriately in the carry over matrix for amplitude
            carryOverMatSubAmpl(whereToPut1,whereToPut2) = ...
            carryOverMatSubAmpl(whereToPut1,whereToPut2)+ampl;
            % do the same for tau2
            carryOverMatSubtau2(whereToPut1,whereToPut2) = ...
            carryOverMatSubtau2(whereToPut1,whereToPut2)+tau2;
        end
        counterMatrixSub(whereToPut1,whereToPut2) = ...
        counterMatrixSub(whereToPut1,whereToPut2)+1;
    end
   
   % manually account for overlapping combinations
   if fitResults.runOrder(i)=='A'
       
       carryOverMatSubAmpl(1,1) = carryOverMatSubAmpl(1,1)./2;
       carryOverMatSubAmpl(2,1) = carryOverMatSubAmpl(2,1)./2;
       
       carryOverMatSubtau2(1,1) = carryOverMatSubtau2(1,1)./2;
       carryOverMatSubtau2(2,1) = carryOverMatSubtau2(2,1)./2;
       
   elseif fitResults.runOrder(i)=='B'
       
       carryOverMatSubAmpl(1,1) = carryOverMatSubAmpl(1,1)./3;
       carryOverMatSubtau2(1,1) = carryOverMatSubtau2(1,1)./3;
       
   else
      dummy = [];
   end
   
   % add 'labels'
   carryOverMatSubAmpl = [uniqueTempFreq' carryOverMatSubAmpl];
   carryOverMatSubAmpl = [[0 uniqueTempFreq]; carryOverMatSubAmpl];
   % store for each run
   carryOverMatAmpl(i,:,:) = carryOverMatSubAmpl;
   
   % repeat for tau2
   carryOverMatSubtau2 = [uniqueTempFreq' carryOverMatSubtau2];
   carryOverMatSubtau2 = [[0 uniqueTempFreq]; carryOverMatSubtau2];
   % store for each run
   carryOverMattau2(i,:,:) = carryOverMatSubtau2;
   
   % matrix for keeping track of repeats
   counterMatrix(i,:,:) = counterMatrixSub;
   
end

lightModDir = {'Light Flux','L - M','S'};

for i = 1:length(lightModDir)
   % create empty matrix
   finalCarryOverMatAmplSub = zeros(size(carryOverMatSubAmpl));
   finalCarryOverMattau2Sub = zeros(size(carryOverMatSubtau2));
   % get all runs with a given modulation direction
   runIndices = find(fitResults.stimTypeCode==i);
   % grab their carry over matrices, sum them
   for j = 1:length(runIndices)
      % convert nan's to 0's
      curCarryOverAmpl = squeeze(carryOverMatAmpl(runIndices(j),:,:));
      curCarryOverTau2 = squeeze(carryOverMattau2(runIndices(j),:,:));
      curCarryOverAmpl(isnan(curCarryOverAmpl)) = 0;
      curCarryOverTau2(isnan(curCarryOverTau2)) = 0;
      % add
      finalCarryOverMatAmplSub = finalCarryOverMatAmplSub+curCarryOverAmpl; 
      finalCarryOverMattau2Sub = finalCarryOverMattau2Sub+curCarryOverTau2; 
   end
   % divide by half the number of runs at that modulation direction--two
   % run orders to get proper counterbalancing
   finalCarryOverMatAmplSub = finalCarryOverMatAmplSub./(length(runIndices)./2);
   finalCarryOverMattau2Sub = finalCarryOverMattau2Sub./(length(runIndices)./2);
   % divide the 'labels' by 6
   finalCarryOverMatAmplSub(1,:) = finalCarryOverMatAmplSub(1,:)./2;
   finalCarryOverMatAmplSub(:,1) = finalCarryOverMatAmplSub(:,1)./2;  
   finalCarryOverMattau2Sub(1,:) = finalCarryOverMattau2Sub(1,:)./2;
   finalCarryOverMattau2Sub(:,1) = finalCarryOverMattau2Sub(:,1)./2;
   % manually average overlapping cells
   finalCarryOverMatAmplSub(2,2) = finalCarryOverMatAmplSub(2,2)./2;
   finalCarryOverMattau2Sub(2,2) = finalCarryOverMattau2Sub(2,2)./2;
   finalCarryOverMatAmplSub(2,6) = finalCarryOverMatAmplSub(2,6)./2;
   finalCarryOverMattau2Sub(2,6) = finalCarryOverMattau2Sub(2,6)./2;
   % assign
   finalCarryOverMatAmpl(i,:,:) = finalCarryOverMatAmplSub;
   finalCarryOverMattau2(i,:,:) = finalCarryOverMattau2Sub;
   
end

for i = 1:length(lightModDir)
   plotCarryOver(uniqueTempFreq,squeeze(finalCarryOverMatAmpl( ...
                i,2:size(finalCarryOverMatAmpl,2),2:size(finalCarryOverMatAmpl,3))), ...
                'Amplitude',lightModDir(i))
   plotCarryOver(uniqueTempFreq,squeeze(finalCarryOverMattau2( ...
                i,2:size(finalCarryOverMattau2,2),2:size(finalCarryOverMattau2,3))), ...
                'tau2',lightModDir(i))
end

%% TRIAL AVERAGES

windowLength = 24;

% loop over stimulus modulation directions
for i = 1:length(lightModDir)
   % get all the unique temporal frequencies
   uniqueTempFreq = unique(fitResults.stimValues(1,:));
   % find all indices for a given modulation direction
   runIndices = find(fitResults.stimTypeCode==i);
   % get all data for given modulation direction
   cleanedDataForModDir = fitResults.cleanedData(runIndices,:);
   % get corresponding fits
   reconTsForModDir = fitResults.reconstructedTSmat(runIndices,:);
   % for each unique temporal frequency
   for j = 1:length(uniqueTempFreq)
       % initialize arrays for storing data and fits
       windowStoreData = [];
       windowStoreFit = [];
       % want to search across runs
       for k = 1:length(runIndices)
           % get the current run's stimulus values
           curRunOrder = fitResults.stimValues(runIndices(k),:);
           % for each unique temporal frequency, get all times at which a
           % stimulus with its value came on
           startPoints = fitResults.startTimesSorted(runIndices(k),uniqueTempFreq(j)==curRunOrder);
           % for each of these starting times
           for l = 1:length(startPoints)
              % grab all time points within the window, get their indices
              aWindow = find(fitResults.timebase>=startPoints(l) ...
                        & fitResults.timebase<=(startPoints(l)+windowLength));
              % store the data and reconstructed time series
              windowStoreData(size(windowStoreData,1)+1,1:length(aWindow)) = cleanedDataForModDir(k,aWindow);
              windowStoreFit(size(windowStoreFit,1)+1,1:length(aWindow)) = reconTsForModDir(k,aWindow);
           end
       end
       meanData = mean(windowStoreData);
       meanFit = mean(windowStoreFit);
       SEdata = std(windowStoreData)./sqrt(size(windowStoreData,1));
       SEfit = std(windowStoreFit)./sqrt(size(windowStoreFit,1));
       meanDataStore(i,j,:) = meanData;
       meanFitStore(i,j,:) = meanFit;
       SEdataStore(i,j,:) = SEdata;
       SEfitStore(i,j,:) = SEfit;
       display(num2str(size(windowStoreData,1)));
   end
end

figure;
set(gcf,'Position',[25 303 1872 788]);
for i = 1:size(meanDataStore,1)
    for j = 1:size(meanDataStore,2)
       subplot(length(lightModDir),length(uniqueTempFreq),(i-1).*length(uniqueTempFreq)+j) 
       plot(0:size(meanDataStore,3)-1,squeeze(meanDataStore(i,j,:))'); hold on
       plot(0:size(meanDataStore,3)-1,squeeze(meanFitStore(i,j,:))'); axis square;
       fill([0:size(meanDataStore,3)-1 fliplr(0:size(meanDataStore,3)-1)], ...
      [squeeze(meanDataStore(i,j,:))'+squeeze(SEdataStore(i,j,:))' ...
      fliplr(squeeze(meanDataStore(i,j,:))'-squeeze(SEdataStore(i,j,:))')], ...
      'k','FaceAlpha',0.15,'EdgeColor','none');
       set(gca,'FontSize',13);
       if j == 1
          ylabel('% signal change');
       end
       if i == 3
          xlabel('time/s'); 
       end
       if j == 4 
           freqForTitle = [char(num2str(uniqueTempFreq(j))) ' Hz'];
           title([lightModDir(i) freqForTitle]);
%            title(['Light Flux' ' 8 Hz']);
       else
          title([num2str(uniqueTempFreq(j)) ' Hz']);
       end
    end
end

end