function regressor = neuralVec2BOLD(stimulus,hrf)

% function regressor = neuralVec2BOLD(stimulus,stimTimeSamples,hrf,t)
%
% upsamples the stimulus to the same resolution as HRF, then convolves

% Convolve Stimulus with HRF to get Regressor
regressorPreCut = conv(stimulus,hrf) ;

% Cut off extra Conv values --( Need to look more into this. Conv is
% wierd in Matlab)
regressor = regressorPreCut(1:length(stimulus)) ;

gribble = 1;