function []=mriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray)

% Build some arrays to identify the stimulus types in each packet
nSubjects=size(fitResultsStructAvgResponseCellArray,1);
nDirections=size(fitResultsStructAvgResponseCellArray,2);
nORders=size(fitResultsStructAvgResponseCellArray,3);

modDirections={'LightFlux','L-M','S'};
stimOrders={'A','B'};

fprintf('>> Generating TTF plots\n');

for ss=1:nSubjects
    figure
    for ii=1:length(modDirections)
        for jj=1:length(stimOrders)

            
            tempPacket.response.values=mean(responseArray);
            tempPacket.response.sem=std(responseArray)/sqrt(length(theCellIndices));            
            [paramsFit,rSquared,modelResponseStruct]=mriBDFM_FitIAMPModelToPacket(tempPacket, hrfKernelStructCellArray{ss});
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.paramsFit=paramsFit;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.rSquared=rSquared;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.modelResponseStruct=modelResponseStruct;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.responseStruct=tempPacket.response;
            subplot(length(modDirections),length(stimOrders),jj+(ii-1)*length(stimOrders));
            plotModelFit(tempPacket.stimulus,tempPacket.response,modelResponseStruct)
            title([modDirections{ii} ' order ' stimOrders{jj}]);
        end % loop over modulation directions
    end % loop over stimulus orders
end % loop over subjects
