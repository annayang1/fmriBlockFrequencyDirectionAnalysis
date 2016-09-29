function plotLinModelFits(timeSamples,timeSeriesAvgAct,timeSeriesAvgModel,startTimes,stimValuesCell,stimValuesMat,timeSeriesStd,MSE)

% function plotLinModelFits(timeSamples,timeSeriesAvgAct,timeSeriesAvgModel,startTimes,stimValuesCell,stimValuesMat,timeSeriesStd)
%
% specialized function for making plots

plot(timeSamples,timeSeriesAvgAct); hold on
plot(timeSamples,timeSeriesAvgModel);
text(startTimes,repmat(max(timeSeriesAvgAct),[1 length(startTimes)]),stimValuesCell);
fill([timeSamples fliplr(timeSamples)], ...
     [timeSeriesAvgAct+timeSeriesStd fliplr(timeSeriesAvgAct-timeSeriesStd)],'k','FaceAlpha',0.15,'EdgeColor','none');
makeStimColorLine(startTimes, ...
                  repmat(min(timeSeriesAvgAct-timeSeriesStd), ...
                  [1 length(startTimes)]),stimValuesMat)
yLims = get(gca,'YLim'); xLims = get(gca,'XLim');

text(xLims(2).*0.8,min(timeSeriesAvgAct),['MSE = ' num2str(round(MSE,3))]);

gribble = 1;