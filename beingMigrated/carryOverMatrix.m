%%

addpath('storedData/');

subj_name = 'asb1';
% NOTE THAT THE COUNTERBALANCING ISN'T PERFECT--MANUALLY CORRECTED IN CODE
% FOR RUN A: 2 PRECEDED BY 0 APPEARS 2 TIMES, 0 PRECEDED BY 0 APPEARS 2
%            TIMES
% FOR RUN B: 0 PRECEDED BY 0 APPEARS 3 TIMES

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

% loop over runs
for i = 1:size(carryOver.storeAll,1)
    stimForRun = carryOver.stimValuesForRunStore(i,:);
    % get unique stimulus values
    uniqueTempFreq = unique(stimForRun);
    % initialize carry over matrices
    carryOverMatSubAmpl = 0./zeros([length(uniqueTempFreq) length(uniqueTempFreq)]);
    carryOverMatSubtau2 = 0./zeros([length(uniqueTempFreq) length(uniqueTempFreq)]);
    counterMatrixSub = zeros([length(uniqueTempFreq) length(uniqueTempFreq)]);
    % loop over temp freqs in each run
    for j = 2:length(stimForRun)
        % get the amplitude and tau values
        ampl = carryOver.storeAll(i,j,1);
        tau2 = carryOver.storeAll(i,j,2);
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
   if carryOver.runOrder(i)=='A'
       
       carryOverMatSubAmpl(1,1) = carryOverMatSubAmpl(1,1)./2;
       carryOverMatSubAmpl(2,1) = carryOverMatSubAmpl(2,1)./2;
       
       carryOverMatSubtau2(1,1) = carryOverMatSubtau2(1,1)./2;
       carryOverMatSubtau2(2,1) = carryOverMatSubtau2(2,1)./2;
       
   elseif carryOver.runOrder(i)=='B'
       
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
   runIndices = find(carryOver.stimTypeCode==i);
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


figure; imagesc(squeeze(finalCarryOverMatAmpl(1,2:size(finalCarryOverMatAmpl,2),2:size(finalCarryOverMatAmpl,3))))
title('Light Flux Amplitude'); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Preceding stimulus (Hz)');
ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;

figure; imagesc(squeeze(finalCarryOverMatAmpl(2,2:size(finalCarryOverMatAmpl,2),2:size(finalCarryOverMatAmpl,3))))
title('L - M Amplitude'); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Preceding stimulus (Hz)');
ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;

figure; imagesc(squeeze(finalCarryOverMatAmpl(3,2:size(finalCarryOverMatAmpl,2),2:size(finalCarryOverMatAmpl,3))))
title('S Amplitude'); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Preceding stimulus (Hz)');
ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;

figure; imagesc(squeeze(finalCarryOverMattau2(1,2:size(finalCarryOverMattau2,2),2:size(finalCarryOverMattau2,3))))
title('Light Flux tau2'); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Preceding stimulus (Hz)');
ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;

figure; imagesc(squeeze(finalCarryOverMattau2(2,2:size(finalCarryOverMattau2,2),2:size(finalCarryOverMattau2,3))))
title('L - M tau2'); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Preceding stimulus (Hz)');
ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;

figure; imagesc(squeeze(finalCarryOverMattau2(3,2:size(finalCarryOverMattau2,2),2:size(finalCarryOverMattau2,3))))
title('S tau2'); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Preceding stimulus (Hz)');
ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;