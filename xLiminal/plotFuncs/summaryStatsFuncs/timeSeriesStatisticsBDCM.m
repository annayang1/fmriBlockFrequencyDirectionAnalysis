function [avgTS, stdTS, errorTerm, modelTS, idCell] = timeSeriesStatisticsBDCM(cleanedData,MSEstore,reconstructedTSmat,stimTypeArr,runOrder)

% [avgTS, stdTS, errorTerm, modelTS, idCell] = timeSeriesStatisticsBDCM(cleanedData,MSEstore,reconstructedTSmat,stimTypeArr,runOrder)
%
% gets lots of summary statistics for BDCM: 1) average time series, 2) std
% errors for plotting, 3) error terms, 4) model fit averages, and 5) string
% cells for identifying each plot

% unique modulation direction and run order
uniqueStimType = unique(stimTypeArr);
uniqueRunOrder = unique(runOrder);

avgTS = [];
stdTS = [];
errorTerm = [];
modelTS = [];
modDirCell = {'Light Flux','L - M','S'};
idCell = {};

for i = 1:length(uniqueStimType)
    for j = 1:length(uniqueRunOrder)
       % get the current plotting condition
       curInd = find(stimTypeArr == uniqueStimType(i) & runOrder == uniqueRunOrder(j));
       % runs per condition
       runsPerCond = length(curInd);
       % grab all the relevant data
       curCleanedData = cleanedData(curInd,:);
       avgTS(size(avgTS,1)+1,:) = mean(curCleanedData);
       stdTS(size(stdTS,1)+1,:) = std(curCleanedData)./sqrt(runsPerCond);
       errorTerm(size(errorTerm,1)+1,:) = mean(MSEstore(curInd));
       curReconstructedTS = reconstructedTSmat(curInd,:);
       modelTS(size(modelTS,1)+1,:) = mean(curReconstructedTS);
       % make a title for the future plot
       idRun = [char(modDirCell(uniqueStimType(i))) ' ' uniqueRunOrder(j)];
       idCell{length(idCell)+1} = idRun;
    end
end

end