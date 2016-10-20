function [  ] = fmriBDFM_AnalyzeCarryOverEffects( fitResultsStructAvgResponseCellArray )
% function [  ] = fmriBDFM_AnalyzeCarryOverEffects( fitResultsStructAvgResponseCellArray )

% Get the dimensions of the passed cell array
nSubjects=size(fitResultsStructAvgResponseCellArray,1);
nDirections=size(fitResultsStructAvgResponseCellArray,2);
nOrders=size(fitResultsStructAvgResponseCellArray,3);

% Define these constants. Probably should have the first three pulled from
% the passed cell array
modDirections={'LightFlux','L-M','S'};
stimOrders={'A','B'};
theFrequencies=[0,2,4,8,16,32,64];
colorStr = 'krb';

figure
for ss=1:nSubjects
    for ii=1:nDirections
        responseMatrix=mriBDFM_MakeCarryOverMatrix( fitResultsStructAvgResponseCellArray(ss,ii,:) );
        subplot(nSubjects,nDirections,ii+(ss-1)*nDirections);
        imagesc(responseMatrix);
        title(modDirections(ii)); set(gca,'xticklabel',([0 2 4 8 16 32 64]));
        set(gca,'yticklabel',([0 2 4 8 16 32 64])); xlabel('Current stimulus');
        ylabel('Prior stimulus'); set(gca,'FontSize',15); colorbar;
    end
end

