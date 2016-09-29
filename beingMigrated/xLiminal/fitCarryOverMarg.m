function [m, c, fit]= fitCarryOverMarg(directEffect,precEffect)

% function m = fitCarryOverMarg(directEffect,precEffect)
%
% find best fitting simple model for preceding effect as a function of
% direct effect

% make sure both inputs are vectors
directEffect = reshape(directEffect,[1 length(directEffect)]);
precEffect = reshape(precEffect,[1 length(precEffect)]);

% directEffect = directEffect-mean(directEffect);
% precEffect = precEffect - mean(precEffect);

% run a regression on preceding effects vector, y = mx+c, where x is the
% direct effect, c is an offset, and y is the preceding effect
regMat = [directEffect' ones(size(directEffect'))];
weights = regMat\precEffect';
m = weights(1); c = weights(2);
fit = regMat*weights;

end