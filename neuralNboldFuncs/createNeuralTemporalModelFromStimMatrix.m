function [neuralMatrix] = createNeuralTemporalModelFromStimMatrix(t, stimMatrix, ampVec, tau2vec)
%% createNeuralTemporalModelFromStimMatrix
%
% This function creates a model of neural response given a vector of
% stimulus input, a vector of time points, and a set of parameters.
%
% The model includes the following stages:
%
%  - a neural impulse response function (modeled as a gamma function)
%  - a compressive non-linearity
%  - a delayed, divisive normalization stage
%    [or, a simple multiplicative exponential decay temporal scaling]
%  - an after-response
%
% The approach is inspired by:
%
%   Zhou, Benson, Kay, Winawer (2016) VSS annual meeting
%   Temporal Summation and Adaptation in Human Visual Cortex
%
%   With additional modeling details taken from:
%
%   McLelland, D., Ahmed, B., & Bair, W. (2009). Responses to static visual
%   images in macaque lateral geniculate nucleus: implications for
%   adaptation, negative afterimages, and visual fading.
%   The Journal of Neuroscience, 29(28), 8996-9001.
%
%   McLelland, D., Baker, P. M., Ahmed, B., & Bair, W. (2010).
%   Neuronal responses during and after the presentation of static visual
%   stimuli in macaque primary visual cortex.
%   The Journal of Neuroscience, 30(38), 12619-12631.
%
% This model implements a negative after-response. Based upon the findings
%   of McLelland et al., 2010, it seems that (for the most part) V1 neurons
%   respond with an after-response that has an amplitude that is
%   proportional to the main response, with a very similar time constant.
%
%   We adopt these properties in the model by treating the after-response
%   as an inverted, shifted, and scaled version of the main-response.
%
% Input properties:
%
%   t - a vector of time points, in seconds
%   yStimulus - a vector of stimulus amplitude. The length must be the same
%               as t. The absolute amplitude is arbitraty.
%   displayFitPlotIn - Boolean flag indicating if you want a plot. Optional.
%   paramIn - a structure of parameters that define the model. These are
%             described below. Optional.
%
% Output properties:
%
%   yBOLD - a vector of response amplitudes, of the same length as t.
%   t - the temporal vector
%   paramOut - the parameters passed back out
%
%
% 05-30-2016 -  gka wrote it
% 06-23-2016 -  gka modified to serve as a function call in fminsearch

modelLength = length(t);
stimDimension=size(stimMatrix,1);

%% define default parameters
% parameters of the stimulus. This could be derived by examining the first
% derivative of the stimulus instead of using this hard-coded value.
param.afterResponseTiming = 10; % Time after stimulus onset at which the offset response occurs.

% parameters of the neural filters
param.MRamplitude = 1;      % multiplicative scaling of the stimulus into the main neural response. Should be unbounded.
param.ARampRelative = 0;    % multiplicative scaling of the after-response, relative to main. Reasonable bounds [-1:1]
param.tau1 = 0.005;         % time constant of the neural IRF (in seconds). In fMRI data modeling, this will be held fixed.
param.epsilon = .35;        % compressive non-linearity parameter. Reasonable bounds [0.1:1]
param.tau2 = 0.001;         % time constant of the low-pass (exponential decay) component. Reasonable bounds [0.0001:0.1]


% We loop through each column of the stimulus matrix
for s=1:stimDimension
    
    % Obtain the model parameters for this stimulus
    param.MRamplitude=ampVec(s);
    param.tau2 = tau2vec(s);
%    param.ARampRelative = ARampVec(s);
    
    %% The neural response begins as the stimulus input
    % scaled by the main response amplitude parameter
    yStimulus = stimMatrix(s,:);
    yNeural = yStimulus.*param.MRamplitude;
    
    %% find the initial peak of the scaled stimulus
    initialPeakPoint=find(abs(yNeural)==max(abs(yNeural)));
    initialPeakPoint=initialPeakPoint(1);
    initialPeakValue=yNeural(initialPeakPoint);
    
%     %% Apply gamma convolution
%     % Define a gamma function that transforms the
%     % stimulus input into a profile of neural activity (e.g., LFP)
%     gammaIRF = t .* exp(-t/param.tau1);
%     
%     %scale the IRF to preserve area of response after convolution
%     gammaIRF=gammaIRF./sum(gammaIRF);
%     
%     % Obtain first stage, linear model, which is the scaled stimulus
%     % convolved by the neural IRF.
%     yNeural = conv(yNeural,gammaIRF);
%     yNeural = yNeural(1:modelLength);
%     
%     %% Implement the compressive non-linearity stage
%     % Obtain second stage, CTS model, which is the output of the linear stage
%     % subjected to a compressive non-linearity. While this is implemented here
%     % as a power law function, it is worth noting that very similar functions
%     % are produced by implementing this as an instantaneous divisive
%     % normalization.
%     yNeural = yNeural.^param.epsilon;
%     
%     % Restore the peak signed, abs amplitude
%     yNeural=(yNeural/yNeural(initialPeakPoint))*initialPeakValue;
    
    % Create the exponential low-pass function that defines the time-domain
    % properties of the normalization
    decayingExponential=(exp(-1*param.tau2*t));
    
    % Position the decaying exponential to have unit value at that time
    % point of the initial peak.
    decayingExponential=circshift(decayingExponential,[0,initialPeakPoint]);
    decayingExponential=decayingExponential/max(decayingExponential);
    decayingExponential(1:initialPeakPoint)=1;
    
    % Apply the exponential decay as a multiplicative scaling
    yNeural=yNeural.*decayingExponential;
    
    %% Create the after-response
    % This is assumed to be a shifted, scaled version of the main response.
    yNeuralAR = yNeural * param.ARampRelative;
    yNeuralAR = circshift(yNeuralAR,[0,param.afterResponseTiming]);
    yNeuralAR(1:param.afterResponseTiming)=NaN;
    yNeural = nansum([yNeural;yNeuralAR]);
    
    %% Place yNeural into the growing neuralMatrix
    neuralMatrix(s,:)=yNeural;
    
end % loop over columns of the stimulus matrix

end