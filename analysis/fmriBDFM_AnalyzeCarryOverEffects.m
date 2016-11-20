function [ plotHandles ] = fmriBDFM_AnalyzeCarryOverEffects( fitResultsStructAvgResponseCellArray )
% function [  ] = fmriBDFM_AnalyzeCarryOverEffects( fitResultsStructAvgResponseCellArray )

% Get the dimensions of the passed cell array
nSubjects=size(fitResultsStructAvgResponseCellArray,1);
nDirections=size(fitResultsStructAvgResponseCellArray,2);
nOrders=size(fitResultsStructAvgResponseCellArray,3);

% Define these constants. Probably should have the first three pulled from
% the passed cell array
modDirections={'LightFlux','L-M','S'};
clims=[-0.2,1;-0.2,0.6;0,0.4];
stimOrders={'A','B'};
theFrequencies=[0,2,4,8,16,32,64];
colorStr = 'krb';

plotHandles=figure();

for ss=1:nSubjects
    
    plotHandles(ss)=figure();
    
    for ii=1:nDirections
        responseMatrix=fmriBDFM_MakeCarryOverMatrix( fitResultsStructAvgResponseCellArray(ss,ii,:) );
        
        % Adjust the data to have a mean response of zero to zero frequency
        % stimuli
        zeroFrequencyValue=mean(responseMatrix(:,1));
        responseMatrix=responseMatrix-zeroFrequencyValue;
        
        subplot(1,nDirections,ii);
        imagesc(responseMatrix,clims(ii,:));
        title(modDirections(ii)); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
        set(gca,'yticklabel',([0 2 4 8 16 32 64]));
        xlabel('Current stimulus'); ylabel('Prior stimulus');
        set(gca,'FontSize',15); colorbar;
    end
end

