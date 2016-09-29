function halfCosine = createStimVector(t,startTime,stimTime,stepFunctionRes,cosRamp)

% function createStimVector(t,startTime,stepFunctionRes,cosRamp)
%
% creates stimulus vector with cosine window. does this for one stimulus
% only. 

% Make 'BOX' Add tiny offset to make sure interpolation works well
timeValues = [startTime linspace(startTime+1e-7,startTime+stimTime-1e-5,stepFunctionRes) ...
             startTime+stimTime-1e-7] ; 
stimValues = [0 ones([1 length(timeValues)-2]) 0] ;

% Shift Time Values so that Stimulus Onset becomes the 0
timeForCos = timeValues - startTime ;

% Remove Stimulus Onset markers (for now)
timeForCos = timeForCos(2:length(timeForCos)-1) ;

% Define positions for left & right ramp
leftRampInd = timeForCos <= cosRamp ;
rightRampInd = timeForCos >= stimTime - cosRamp ;

% Create half Cosine
halfCosine = ones([1 length(timeForCos)]) ;
halfCosine(leftRampInd) = fliplr((cos(linspace(0,pi,sum(leftRampInd)))+1)/2) ;
halfCosine(rightRampInd) = (cos(linspace(0,pi,sum(rightRampInd)))+1)/2 ;

% Put in points corresponding to Stimulus Start and End
halfCosinePreInterp = [0 halfCosine 0] ;

% sample at desired times
halfCosine = interp1(timeValues,halfCosinePreInterp,t);
halfCosine(isnan(halfCosine)) = 0;

gribble = 1;