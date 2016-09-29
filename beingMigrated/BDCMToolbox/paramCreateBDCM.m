function paramStruct = paramCreateBDCM(nStimuli)
% paramStruct = paramCreateBDCM(nStimuli)
%
% Create a default parameters structure for the BDCM fMRI modeling.
% This includes default parameters plus lower and upper bounds,
% as well as a field with parameter names.


% cell for labeling each parameter column
paramStruct.paramNameCell = {'Amplitude','tau2'};

% initial values
paramStruct.paramMainMatrix = [];
paramStruct.paramMainMatrix(:,1) = 0.5.*ones([nStimuli 1]);
paramStruct.paramMainMatrix(:,2) = 0.001.*ones([nStimuli 1]);
% paramStruct.paramMainMatrix(:,3) = (-0.125).*ones([nStimuli 1]);

% set lower bounds
paramStruct.vlb(:,1) = repmat(-10,[nStimuli 1]);
paramStruct.vlb(:,2) = repmat(0.0001,[nStimuli 1]);
% paramStruct.vlb(:,3) = repmat(-10,[nStimuli 1]);

% set upper bounds
paramStruct.vub(:,1) = repmat(10,[nStimuli 1]);
paramStruct.vub(:,2) = repmat(1,[nStimuli 1]);
% paramStruct.vub(:,3) = repmat(10,[nStimuli 1]);