function [ theResponseMatrix ] = fmriBDFM_MakeCarryOverMatrix( fitResultsStructAvgResponseCellArray )
% function [ theResponseMatrix ] = fmriBDFM_MakeCarryOverMatrix( fitResultsStructAvgResponseCellArray )
%

nResultsStuctures=length(fitResultsStructAvgResponseCellArray);

% Assume that all the packets have the same stimLabels. Might want to
% check this one day.
nStimlabels=length(fitResultsStructAvgResponseCellArray{1}.stimLabels);

theResponseMatrix=zeros(nStimlabels,nStimlabels);
theCountMatrix=zeros(nStimlabels,nStimlabels);

for ss=1:nResultsStuctures
    stimTypes=fitResultsStructAvgResponseCellArray{ss}.stimTypes;
    
    for jj=1:length(stimTypes)
        currentStimulus=stimTypes(jj);
        if jj==1
            priorStimulus=stimTypes(end);
        else
            priorStimulus=stimTypes(jj-1);
        end
        theResponseMatrix(priorStimulus,currentStimulus)= ...
            theResponseMatrix(priorStimulus,currentStimulus)+ ...
            fitResultsStructAvgResponseCellArray{ss}.paramsFit.paramMainMatrix(jj);
        theCountMatrix(priorStimulus,currentStimulus) = ...
            theCountMatrix(priorStimulus,currentStimulus) +1;
    end % loop over the stimType vector
end % loop over the number of result structures passed

badCells=find(theCountMatrix==0);
if ~isempty(badCells)
    error('There is a bad cell with no values in this carry over matrix');
end

theResponseMatrix=theResponseMatrix./theCountMatrix;