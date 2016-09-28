function [watsonFitToData, fitParams] = fitWatsonToTTF(frequenciesHz, data, displayFitPlotIn, initialParamsIn)

%% fitWatsonToTTF
%
% This function fits Andrew Watson's two-component linear filter temporal
% sensitivity model to the amplitude components of temporal transfer
% function data. Details of the model are in the functions below.
%
% Input properties:
%
%   frequenciesHz - a vector of frequencies for which the TTF was measured.
%                   Typically, these are log spaced.
%   data - a vector of amplitudes
%   displayFitPlotIn - Boolean flag indicating if you want a plot
%   initialParamsIn - a vector of parameter values, corresponding to:
%      tau              -- time constant of the center filter (in seconds)
%      kappa            -- multiplier of the time-constant for the surround
%      centerAmplitude  -- amplitude of the center filter
%      zeta             -- multiplier that scales the amplitude of the surround filter
%
% 05-30-2016    -  gka wrote it
%

% Assume that we do not want to plot the fit unless we hear otherwise
displayFitPlot = false;

% The user passed nothing, so just demo the code
if nargin==0
    fprintf('A demonstration of the model for an example TTF\n\n');

    frequenciesHz = [2,4,8,16,32,64];
    data = [0.4, 0.75, 0.80, 0.37, 0.1, 0.0];

    displayFitPlot=true;
end

% The user just passed just frequencies or data; return an error
if nargin==1
    msg = 'Please provide both a vector of frequencies and amplitudes.';
    error(msg)
end

% Sanity check the input and derive the modelLength
if length(frequenciesHz)~=length(data)
    msg = 'The vectors of frequencies and data are of different lengths.';
    error(msg)
end

% Check the setting of the displayFitPlot flag
if nargin==3
    displayFitPlot=displayFitPlotIn;
end

% Initial guess for the parameters to define the Watson fit
%   tau              -- time constant of the center filter (in seconds)
%   kappa            -- multiplier of the time-constant for the surround
%   centerAmplitude  -- amplitude of the center filter
%   zeta             -- multiplier that scales the amplitude of the surround filter

initialParams(1) = 0.004;
initialParams(2) = 2;
initialParams(3) = 1;
initialParams(4) = 0.5;

if nargin==4
    initialParams=initialParamsIn;
end

% Some of our BOLD fMRI TTF data has negative values for the response as
% compared to the stationary background. We offset the TTF to have the
% lowest value at zero, and retain this to adjust the fit later.

offset=min(data);
data=data-offset;

% Run the optimization
fitParams = fminsearch( (@(p) WatsonAmplitudeFit(p, frequenciesHz, data)), initialParams);

% Obtain the Watson linear model fit at the passed frequencies. These are
% the values that we return by default

watsonFitToData = abs(WatsonLinearModel(frequenciesHz, fitParams));

% If the user requested a plot, give it to them

if displayFitPlot
    figure;
    frequenciesHz_fine = linspace(frequenciesHz(1), frequenciesHz(end), 100);
    y = abs(WatsonLinearModel(frequenciesHz_fine, fitParams));
    % Plot the data
    r1 = semilogx(frequenciesHz, data+offset, 'sr', 'MarkerFaceColor', 'r'); hold on;
    
    % Plot the finely sampled fit
    r2 = semilogx(frequenciesHz_fine, y+offset, '-k');
    
    % Make the plot pretty
    xlabel('log frequency');
    %title(['Peak frequency: ', num2str(pfit(3)) ' Hz']);
    ylabel('Response');
    legend([r1 r2], 'Data', 'Fit'); legend boxoff;
end


function E = WatsonAmplitudeFit(params, frequenciesHz, y)

% Error function, calculating the sum-of-squares for the data vs. the fit.

% The fit is given by the WatsonLinearModel. The model returns a vector of
% complex values that contain the real and imaginary compoents that define
% the Fourier transform of the system output. We are interested here in
% just fitting the amplitude component of the temporal transfer function.

% params -- a vector of parameters for the fit. These correspond to:
%   tau = p(1); % Time constant of the center filter (in seconds)
%   kappa = p(2); % multiplier of the time-constant for the surround
%   centerAmplitude = p(3); % Amplitude of the center filter
%   zeta = p(4); % multiplier  that scales the amplitude of the surround filter

% The amplitude component is given by abs(H). If we wished to derive the
% phase component, this would be given by angle(H).

yhat = abs(WatsonLinearModel(frequenciesHz, params));

% Calculate the sums-of-squares

E = sum((y-yhat).^2);


function H = WatsonLinearModel(frequenciesHz, params)

% Calculates the two-component (center-surround) Watson temporal model
% The parameters (p) defines both the "center" and the "surround" linear
%  filter components. The entire model is the difference between these
%  two filter components.
%
% The model is expressed in Eq 45 of:
%
%   Watson, A.B. (1986). Temporal sensitivity. In Handbook of Perception
%   and Human Performance, Volume 1, K. Boff, L. Kaufman and
%   J. Thomas, eds. (New York: Wiley), pp. 6-1-6-43..
%
% Note that there is a typo in original manuscript. Equation 45 should be:
%
%   H(frequenciesHz) = a[H1(frequenciesHz) - bH2(frequenciesHz)]
%
% where a and b are scale factors. We have modified the implementation of
% scale factors here.
%
% Additionally, Watson (1986) gives the time-constant of the model in units
% of milliseconds, but we find that, to reproduce the presented figures,
% this time-constant is converted at some point to units of seconds prior
% to its entry into the equations.
%
% The model is the difference between two linear impulse response filters,
% each of which is themselves a cascade of low-pass filters. The number of
% filters in the cascade (the "filterOrder") is set empirically. Center and
% surround orders of "9" and "10" are presented in (e.g.) Figure 6.5 of
% Watson (1986).

% Fixed parameters (taken from Figure 6.4 and 6.5 of Watson 1986)
centerFilterOrder = 9; % Order of the center (usually fast) filter
surroundFilterOrder = 10; % Order of the surround (usually slow) filter

% Un-pack the passed parameters

params_tau = params(1);             % time constant of the center filter (in seconds)
params_kappa = params(2);           % multiplier of the time-constant for the surround
params_centerAmplitude = params(3); % amplitude of the center filter
params_zeta = params(4);            % multiplier that scales the amplitude of the surround filter

% Generate the model. We return H.
H1 = nStageLowPassFilter(params_tau,frequenciesHz,centerFilterOrder);
H2 = nStageLowPassFilter(params_kappa*params_tau,frequenciesHz,surroundFilterOrder);
H = (params_centerAmplitude * H1) - (params_zeta*params_centerAmplitude*H2);


function Hsub = nStageLowPassFilter(tau,frequenciesHz,filterOrder)

% This function implements the system response of the linear filter
% for temporal sensitivity of neural systems in Eq 42 of:
%
%   Watson, A.B. (1986). Temporal sensitivity. In Handbook of Perception
%   and Human Performance, Volume 1, K. Boff, L. Kaufman and
%   J. Thomas, eds. (New York: Wiley), pp. 6-1-6-43..
%
% The implemented function is the "system respone" (Fourier transform) of
% the impulse response of an nth-order filter which is of the form:
%
% h(t) = u(t) * (1/(tau*(n-1)!)) * (t/tau)^(n-1) * exp(-t/tau)
%
% tau -- Time constant of the filter (in seconds)
% frequenciesHz -- a vector of frequencies at which to realize the model
% filterOrder -- the number of low-pass filters which are cascaded in
%                the model

Hsub = (1i*2*pi*frequenciesHz*tau + 1) .^ (-filterOrder);
