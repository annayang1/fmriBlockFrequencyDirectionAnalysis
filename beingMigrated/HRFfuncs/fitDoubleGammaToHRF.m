function [fitParams] = fitDoubleGammaToHRF(t, data, stdError, displayFitPlotIn, initialParamsIn)

%% fitDoubleGammaToHRF
%
% This function fits a double gamma HRF model to an set of amplitufde data.
% In standard use, an HRF is measured using (e.g.) an FIR approach in BOLD
% fMRI data. This routine is then used to produce a parameterized fit to
% these data.
%
% Input properties:
%
%   t - a vector of time points, in seconds
%   data - a vector of BOLD fMRI response amplitudes. The length must be
%               the same as t. The absolute amplitude is arbitraty.
%   stdError - a vector of errors for each data point, used to weight the
%               fit.
%   displayFitPlotIn - Boolean flag indicating if you want a plot. Optional.
%   initialParamsIn - a vector of parameters that define the model. These are
%             described below. Optional.
%
% 06-21-2016    -  gka wrote it
%


%% Deal with the passed parameters and flags

% Assume that we do not want to plot the fit unless we hear otherwise
displayFitPlot = false;

% The user passed nothing, so just demo the code
if nargin==0
    fprintf('A demonstration of the model for an example BOLD HRF\n\n');

    t = linspace(0,15,16);
    data = [0,0.0031,0.0361,0.1008,0.1561,0.1746,0.1584,0.1232,0.0844, ...
            0.0510,0.0265,0.0105,0.0013,-0.0032,-0.0047,-0.0047];
    stdError = ones(1,16)/30;
        
    displayFitPlot=true;
end

% The user just passed just time or data; return an error
if nargin==1
    msg = 'Please provide both a vector of time and amplitudes.';
    error(msg)
end

% Sanity check the input and derive the modelLength
if length(t)~=length(data)
    msg = 'The vectors of time and data are of different lengths.';
    error(msg)
end

% Check the setting of the displayFitPlot flag
if nargin==4
    displayFitPlot=displayFitPlotIn;
end

%% define default parameters

% Initial guess for the parameters to define the Watson fit
%   lag
%   amplitude -- overall amplitude
%   gamma1 -- positive gamma parameter (roughly, time-to-peak in seconds)
%   gamma2 -- negative gamma parameter (roughly, time-to-peak in seconds)
%   Scale  -- scaling factor between the positive and negative gamma componenets

% parameters of the double-gamma hemodynamic filter (HRF)

initialParams(1) = -1;
initialParams(2) = 1;
initialParams(3) = 5;
initialParams(4) = 10;
initialParams(5) = .5;

LowerBounds=[-2,-inf,3,6,0];
UpperBounds=[2,+inf,8,14,1];

if nargin==5
    initialParams=initialParamsIn;
end


% The measured HRF may have a non-zero initial value. We offset the
% response to have an initial value of zero, and retain this to adjust the
% fit later.

offset=data(1);
data=data-offset;

% Run the optimization. We will return these params.
fitParams = fminsearchbnd( (@(p) doubleGammaModelFit(p, t, stdError, data)), initialParams, LowerBounds, UpperBounds);

% Obtain the Double Gamma model fit at the passed time points. This might
% be used for plotting.

doubleGammaFitToData = doubleGammaModel(t, fitParams);

% If the user requested a plot, give it to them

if displayFitPlot
    figure;
    t_fine = linspace(t(1), t(end), 100);
    y = abs(doubleGammaModel(t_fine, fitParams));
    % Plot the data
    r1 = plot(t, data+offset, 'sr', 'MarkerFaceColor', 'r'); hold on;
    hold on
    errorbar(t,data+offset,stdError);
    % Plot the finely sampled fit
    r2 = plot(t_fine, y+offset, '-k');
    
    % Make the plot pretty
    xlabel('time (seconds)');
    ylabel('Response');
    legend([r1 r2], 'Data', 'Fit'); legend boxoff;
end




function E = doubleGammaModelFit(params, t, stdError, y)

% Error function, calculating the sum-of-squares for the data vs. the fit.

yhat = abs(doubleGammaModel(t, params));

% Calculate the sums-of-squares

errorPreSumSquared = (y - yhat).^2;

errorPreSumSquared = errorPreSumSquared.*(1./stdError).^3;

E = sum(errorPreSumSquared);


function H = doubleGammaModel(t, params)

% Calculates the double gamma model typically used to fit the BOLD HRF


% Un-pack the passed parameters

params_lag = params(1);
params_amplitude = params(2);
params_gamma1shape = params(3); 
params_gamma2shape = params(4); 
params_gammaScale = params(5);  % relative amplitude of neg to pos gamma

% Generate the model. We return H.

H =  params_amplitude * ...
    (gampdf(t+params_lag, params_gamma1shape, 1) - ...
     gampdf(t+params_lag, params_gamma2shape, 1)*params_gammaScale);

