function f = forwardModelObjectiveFunction(stimMatrix,t,data,prmVec,paramStructFixed)

% function f = forwardModelObjectiveFunction(stimMatrix,t,data,paramVec)
%
% same as forwardModel, except it returns just the error. Also, it takes in
% a parameter vector, not a struct, to fit. However, note paramStructFixed,
% which contains parameters that are locked down, like the HRF

% get parameters into matrix form
prmVecReshaped = reshape(prmVec,[size(stimMatrix,1) length(prmVec)./size(stimMatrix,1)]);

% sort parameters
ampVec = prmVecReshaped(:,strcmp(paramStructFixed.paramNameCell,'Amplitude'));
tau2vec = prmVecReshaped(:,strcmp(paramStructFixed.paramNameCell,'tau2'));
% ARampVec = prmVecReshaped(:,strcmp(paramStructFixed.paramNameCell,'ARAmplitude'));

% run the neural model on each stimulus, then get the full neural vector
neuralVec = sum(createNeuralTemporalModelFromStimMatrix(t,stimMatrix,ampVec,tau2vec));

% neural to BOLD
reconstructedTS = neuralVec2BOLD(neuralVec,paramStructFixed.HRF);

% mean center the BOLD signal
reconstructedTS=reconstructedTS-mean(reconstructedTS);

% get error
f = mean((data-reconstructedTS).^2);

gribble = 1;