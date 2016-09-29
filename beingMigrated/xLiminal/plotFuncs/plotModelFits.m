function plotModelFits(timeSamples,timeSeriesAvgAct,timeSeriesAvgModel,startTimes,stimValuesCell,stimValuesMat,timeSeriesStd,MSE)

% function plotModelFits(timeSamples,timeSeriesAvgAct,timeSeriesAvgModel,startTimes,stimValuesCell,stimValuesMat,timeSeriesStd)
%
% specialized function for making BDCM plots--probably not worth it for
% anyone but Ben Chin to read this code

plot(timeSamples,timeSeriesAvgAct); hold on
plot(timeSamples,timeSeriesAvgModel);
text(startTimes,repmat(max(timeSeriesAvgAct),[1 length(startTimes)]),stimValuesCell);
fill([timeSamples fliplr(timeSamples)], ...
     [timeSeriesAvgAct+timeSeriesStd fliplr(timeSeriesAvgAct-timeSeriesStd)],'k','FaceAlpha',0.15,'EdgeColor','none');
makeStimColorLine(startTimes, ...
                  repmat(min(timeSeriesAvgAct-timeSeriesStd), ...
                  [1 length(startTimes)]),stimValuesMat)
yLims = get(gca,'YLim'); xLims = get(gca,'XLim');
set(gca,'FontSize',12);

text(xLims(2).*0.8,min(timeSeriesAvgAct),['RMS = ' num2str(round(MSE,3))]);

gribble = 1;