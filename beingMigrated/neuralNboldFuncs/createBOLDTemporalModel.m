function [yBOLD] = createBOLDTemporalModel(t, yNeural, displayFitPlotIn, paramIn)

%% createBOLDTemporalModel
%
% This function creates a model of BOLD fMRI response response given a
% vector of neural input, a vector of time points, and a set of parameters.
%
% The model includes the following stages:
%
%   - convolution with an HRF
%
%
% Input properties:
%
%   t - a vector of time points, in seconds
%   yNeural - a vector of neural amplitude. The length must be the same
%               as t. The absolute amplitude is arbitraty.
%   displayFitPlotIn - Boolean flag indicating if you want a plot. Optional.
%   paramIn - a structure of parameters that define the model. These are
%             described below. Optional.
%
% Output properties:
%
%   yBOLD - a vector of response amplitudes, of the same length as t.
%
%
% 06-23-2016 -  gka split this off from the neural model
%
%


%% Deal with the passed parameters and flags

% The user passed nothing, return an error
if nargin==0
    msg = 'Need at least a vector of time points and a stimulus vector.';
    error(msg)
end

% The user just passed a stimulus or a time vector, return an error
if nargin==1
    msg = 'Please provide both a vector of time points and a stimulus vector.';
    error(msg)
end

% Sanity check the input and derive the modelLength
if length(yNeural)~=length(t)
    msg = 'The vector of time points and the stimulus vector are different lengths.';
    error(msg)
end

modelLength = length(t);

% Assume that we do not want to plot the fit unless we receive a
% corresponding flag, or if no arguments were passed, in which case we will
% set display to true as we are in demo mode.

displayFitPlot=false;
if nargin==0
    displayFitPlot=true;
end
if nargin==3
    displayFitPlot=displayFitPlotIn;
end

%% define default parameters

% parameters of the double-gamma hemodynamic filter (HRF)
param.gamma1 = 6;   % positive gamma parameter (roughly, time-to-peak in seconds)
param.gamma2 = 12;  % negative gamma parameter (roughly, time-to-peak in seconds)
param.gammaScale = 10; % scaling factor between the positive and negative gamma componenets

% if no parameters were passed in, use the defaults
if nargin==4
    param=paramIn;
end


%% Convolve the neural model by the BOLD HRF

% Create a double-gamma model of the hemodynamic response function (HRF)
BOLDHRF = gampdf(t, param.gamma1, 1) - ...
    gampdf(t, param.gamma2, 1)/param.gammaScale;

% scale to unit sum to preserve amplitude of y following convolution
BOLDHRF = BOLDHRF/sum(BOLDHRF);

% Perform the convolution
yBOLD = conv(yNeural,BOLDHRF);

% Truncate the convolved vector to the input length. Not sure why I have to
% do this. Probably mis-using the conv function.
yBOLD = yBOLD(1:modelLength);

%% Plot the model
if displayFitPlot
    figure;
    subplot(1,2,1);
    hold on;
    r1 = plot(BOLDHRF);
    plot(BOLDHRF,'.');
    title('Convolution functions used in the model');
    legend([r1], 'BOLDHRF');
    legend boxoff
    hold off;
    
    subplot(1,2,2);
    hold on;
    r1 = plot(yNeural);
    r2 = plot(yBOLD);
    legend([r1 r2], 'yNeural', 'yBOLD');
    title('Responses at sequential filter stages');
    legend boxoff
    hold off;
end

%% Return yBOLD

yBOLD=yBOLD;

