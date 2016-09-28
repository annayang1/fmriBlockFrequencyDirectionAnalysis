function [meanMatrix, SEmatrix, stimTypeTagMatrix, paramNamesTagMatrix] = paramStatistics(storeUnique,stimTypeArr,paramNamesCell)

% function [meanMatrix, SEmatrix] = paramStatistics(storeUnique,stimTypeArr,paramNamesCell)
%
% after parameters have been fit for each run, this sorts them according to
% condition and gets some statistics

% matrix for storing parameter means & SE
meanMatrix = [];
SEmatrix = [];
stimTypeCode = unique(stimTypeArr);
% number of runs assumes that each condition has the same number of runs
numberOfRuns = sum(stimTypeArr == stimTypeCode(1));
% tag the matrices we get out by condition (just to be sure)
stimTypeTagMatrix = [];
paramNamesTagMatrix = {};

% for each parameter position
for i = 1:length(paramNamesCell)
    % and modulation direction
   for j = 1:length(stimTypeCode)
       meanMatrix(size(meanMatrix,1)+1,:) = mean(storeUnique ...
                                            (stimTypeArr == stimTypeCode(j),:,i));
       SEmatrix(size(SEmatrix,1)+1,:) = ((std(storeUnique ...
                                        (stimTypeArr == stimTypeCode(j),:,i))) ...
                                        ./sqrt(numberOfRuns));
       stimTypeTagMatrix(length(stimTypeTagMatrix)+1) = stimTypeCode(j);
       paramNamesTagMatrix(length(paramNamesTagMatrix)+1) = paramNamesCell(i);
   end
end

gribble = 1;