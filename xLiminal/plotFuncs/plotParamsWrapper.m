function plotParamsWrapper(actualStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell,plotPosition)

% function plotParamsWrapper(actualStimulusValues,meanMatrix,SEmatrix,stimTypeTagMatrix,paramNamesTagMatrix,stimNamesCell,plotPosition)
%
% plotting function. currently set up for 3x3 plot. Give it the 1) actual
% stimulus values, 2) a matrix of means (one row for each plot), 3) a matrix of
% standard errors, 4, 5, 6) vectors/cells specifying the modulation direction and
% temporal frequency, 7) and the option of manually specifying where each plot
% goes (in order).

% put this on x-axis
xString = 'Temporal Frequency';

% three colors to plot modulation directions
colorStr = 'krb';

if ~exist('plotPosition')
   plotPosition = 1:size(meanMatrix,1); 
end

actualStimulusValues = reshape(actualStimulusValues,[1 length(actualStimulusValues)]);

figure;
set(gcf,'Position',[321 200 1179 845])

for i = 1:size(meanMatrix,1)
   meansToPlot = meanMatrix(i,:);
   SEtoPlot = SEmatrix(i,:);
   stimTypeString = stimNamesCell(stimTypeTagMatrix(i));
   paramTypeString = paramNamesTagMatrix(i);
   
   if strcmp('Amplitude',paramTypeString)
       subplot(3,3,plotPosition(i))
       % because of log scale, a value of 0 must be plotted as 1
       actualStimulusValuesToPlot = actualStimulusValues;
       actualStimulusValuesToPlot(actualStimulusValuesToPlot==0)=1;
       % fit Watson model
       [~, ~, frequenciesHz_fine,y,offset] = ...
       fitWatsonToTTF(actualStimulusValues,meansToPlot,SEtoPlot,0); 
       % if we want to limit the portion of the Watson fit to plot
       validForPlot = frequenciesHz_fine>=0;
       plot(frequenciesHz_fine(validForPlot),y(validForPlot)+offset,[colorStr(stimTypeTagMatrix(i)) '-']); hold on
       errorbar(actualStimulusValuesToPlot,meansToPlot,SEtoPlot,[colorStr(stimTypeTagMatrix(i)) 'o']); set(gca,'FontSize',15);
       set(gca,'Xtick',actualStimulusValuesToPlot); title(stimTypeString); axis square;
       set(gca,'Xticklabel',actualStimulusValues);
       set(gca,'Xscale','log'); xlabel(xString); ylabel(paramTypeString);
       xlim([min(actualStimulusValuesToPlot).*0.9 max(actualStimulusValuesToPlot).*1.1]);
   else
       subplot(3,3,plotPosition(i))  
       % because of log scale, a value of 0 must be plotted as 1
       actualStimulusValuesToPlot = actualStimulusValues;
       actualStimulusValuesToPlot(actualStimulusValuesToPlot==0)=1;
       errorbar(actualStimulusValuesToPlot,meansToPlot,SEtoPlot,[colorStr(stimTypeTagMatrix(i)) 'o']); set(gca,'FontSize',15);
       set(gca,'Xtick',actualStimulusValuesToPlot); title(stimTypeString); axis square;
       set(gca,'Xticklabel',actualStimulusValues);
       set(gca,'Xscale','log'); xlabel(xString); ylabel(paramTypeString);
       xlim([min(actualStimulusValuesToPlot).*0.9 max(actualStimulusValuesToPlot).*1.1]);
   end
end

gribble = 1;