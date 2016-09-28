function plotParamsWrapper(actualStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell,plotPosition)

% function plotParamsWrapper(actualStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell,plotPosition)
%
% plotting function. currently set up for 3x3 plot.

xString = 'Temporal Frequency';

colorStr = 'krb';

if ~exist('plotPosition')
   plotPosition = 1:size(meanMatrix,1); 
end

figure;
set(gcf,'Position',[321 200 1179 845])

for i = 1:size(meanMatrix,1)
   meansToPlot = meanMatrix(i,:);
   SEtoPlot = SEmatrix(i,:);
   stimTypeString = stimNamesCell(stimTypeTagMatrix(i));
   paramTypeString = paramNamesTagMatrix(i);
   
   if strcmp('Amplitude',paramTypeString)
       subplot(3,3,plotPosition(i))
       [~, ~, frequenciesHz_fine,y,offset] = ...
       fitWatsonToTTF_errorGuided(actualStimulusValues',meansToPlot,SEtoPlot,0); 
       plot(frequenciesHz_fine,y+offset,[colorStr(stimTypeTagMatrix(i)) '-']); hold on
       errorbar(actualStimulusValues',meansToPlot,SEtoPlot,[colorStr(stimTypeTagMatrix(i)) 'o']); set(gca,'FontSize',15);
       set(gca,'Xtick',actualStimulusValues'); title(stimTypeString); axis square;
       set(gca,'Xscale','log'); xlabel(xString); ylabel(paramTypeString);
   else
       subplot(3,3,plotPosition(i))  
       errorbar(actualStimulusValues',meansToPlot,SEtoPlot,[colorStr(stimTypeTagMatrix(i)) 'o']); set(gca,'FontSize',15);
       set(gca,'Xtick',actualStimulusValues'); title(stimTypeString); axis square;
       set(gca,'Xscale','log'); xlabel(xString); ylabel(paramTypeString);
   end
end

gribble = 1;