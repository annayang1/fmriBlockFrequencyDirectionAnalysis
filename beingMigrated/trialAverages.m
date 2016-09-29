%%

addpath('storedData/');

subj_name = 'gka1';

% load parameters and fits
if strcmp(subj_name,'asb1')
    carryOver = load('asb1CarryOver');
    carryOver = carryOver.carryOver;
    unlockedParamFits = load('asb1UnlockedParamFits');
    unlockedParamFits = unlockedParamFits.unlockedParamFits;
elseif strcmp(subj_name,'gka1')
    carryOver = load('gka1CarryOver');
    carryOver = carryOver.carryOver;
    unlockedParamFits = load('gka1UnlockedParamFits');
    unlockedParamFits = unlockedParamFits.unlockedParamFits;
else
   error('specify valid subject name: asb1 or gka1'); 
end

lightModDir = {'Light Flux','L - M','S'};

T_R = 1;

timeBase = 0:T_R:T_R*length(unlockedParamFits.cleanedData(1,:))-1;

windowLength = 24;

% loop over stimulus modulation directions
for i = 1:length(lightModDir)
   % get all the unique temporal frequencies
   uniqueTempFreq = unique(carryOver.stimValuesForRunStore(1,:));
   % find all indices for a given modulation direction
   runIndices = find(carryOver.stimTypeCode==i);
   % get all data for given modulation direction
   cleanedDataForModDir = unlockedParamFits.cleanedData(runIndices,:);
   % get corresponding fits
   reconTsForModDir = unlockedParamFits.reconstructedTSmat(runIndices,:);
   % for each unique temporal frequency
   for j = 1:length(uniqueTempFreq)
       % initialize arrays for storing data and fits
       windowStoreData = [];
       windowStoreFit = [];
       % want to search across runs
       for k = 1:length(runIndices)
           % get the current run's stimulus values
           curRunOrder = carryOver.stimValuesForRunStore(runIndices(k),:);
           % for each unique temporal frequency, get all times at which a
           % stimulus with its value came on
           startPoints = carryOver.startTimesSorted(runIndices(k),uniqueTempFreq(j)==curRunOrder);
           % for each of these starting times
           for l = 1:length(startPoints)
              % grab all time points within the window, get their indices
              aWindow = find(timeBase>=startPoints(l) ...
                        & timeBase<=(startPoints(l)+windowLength));
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
set(gcf,'Position',[379 259 1112 787]);
for i = 1:size(meanDataStore,1)
    for j = 1:size(meanDataStore,2)
       subplot(3,7,(i-1).*7+j) 
       plot(0:size(meanDataStore,3)-1,squeeze(meanDataStore(i,j,:))'); hold on
       plot(0:size(meanDataStore,3)-1,squeeze(meanFitStore(i,j,:))'); axis square;
       fill([0:size(meanDataStore,3)-1 fliplr(0:size(meanDataStore,3)-1)], ...
      [squeeze(meanDataStore(i,j,:))'+squeeze(SEdataStore(i,j,:))' ...
      fliplr(squeeze(meanDataStore(i,j,:))'-squeeze(SEdataStore(i,j,:))')], ...
      'k','FaceAlpha',0.15,'EdgeColor','none');
       if j == 1
          ylabel('% signal change');
       end
       if i == 3
          xlabel('time/s'); 
       end
       if j == 4 
          title([lightModDir(i) num2str(uniqueTempFreq(j)) ' Hz']);
       else
          title([num2str(uniqueTempFreq(j)) ' Hz']);
       end
    end
end