function makeStimColorLine(stimXcoordinates,stimYcoordinates,stimValues)

% function makeStimColorLine(stimXcoordinates,stimYcoordinates,stimValues)
%
% makes colorbar for stimuli
%
% stimXcoordinates: starting times of blocks
% stimYcoordinates: where to plot the line
% stimValues      : stimulus values for each block

% DEFINE BLACK COLOR
blackWhiteArr = [1 1 1];
% DEFINE A BUNCH OF GRAYSCALE LEVELS
blackWhiteArrGradient = linspace(0,1,length(unique(stimValues)));
% ASSIGN EACH LEVEL TO A GIVEN STIMULUS VALUE
colorStimLookup = [unique(stimValues)' flipud(blackWhiteArrGradient')];

% FOR EACH STIMULUS BLOCK
for i = 2:length(stimXcoordinates)
    % PLOT A TWO-POINT LINE
    xLineCoordinates2 = stimXcoordinates(i);
    xLineCoordinates1 = stimXcoordinates(i-1);
    yLineCoordinates2 = stimYcoordinates(i);
    yLineCoordinates1 = stimYcoordinates(i-1);
    bwGradient = colorStimLookup(colorStimLookup(:,1) == stimValues(i-1),2);
    plot([xLineCoordinates1 xLineCoordinates2], ...
         [yLineCoordinates1 yLineCoordinates2],'Color',bwGradient.*blackWhiteArr,'LineWidth',6); hold on
end

gribble = 1;