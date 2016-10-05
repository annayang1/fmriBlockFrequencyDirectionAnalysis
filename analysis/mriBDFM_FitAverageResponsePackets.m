function [fitResultsStructAvgResponseCellArray] = mriBDFM_FitAverageResponsePackets(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = mriBDFM_FitModelToPacketCellArray(thePacket, hrfKernelStructCellArray)
%

% Build some arrays to identify the stimulus types in each packet
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);
for ss=1:nSubjects
    for rr=1:nRuns
        if ~isempty(packetCellArray{ss,rr})
        modulationDirectionCellArray{ss,rr}=(packetCellArray{ss,rr}.stimulus.metaData.modulationDirection);
        stimulusOrderAorBCellArray{ss,rr}=(packetCellArray{ss,rr}.stimulus.metaData.stimulusOrderAorB);
        end % the packet is not empty
    end % loop over runs
end % loop over subjects

modDirections={'LightFlux','L-M','S'};
stimOrders={'A','B'};

fprintf('>> Performing IAMP model fitting for average responses\n');

for ss=1:nSubjects
    figure
    for ii=1:length(modDirections)
        for jj=1:length(stimOrders)
            fprintf('\t* Subject <strong>%g</strong> , modDirection <strong>%g</strong>, stimOrder <strong>%g</strong>\n', ss, ii, jj);
            theCellIndices=find( (strcmp(modulationDirectionCellArray(ss,:),modDirections{ii})==1) & ...
                (strcmp(stimulusOrderAorBCellArray(ss,:),stimOrders{jj})==1) );
            tempPacket=packetCellArray{ss,theCellIndices(1)};
            responseArray(1,:)=tempPacket.response.values;
            for kk=2:length(theCellIndices)
                responseArray(2,:)=packetCellArray{ss,theCellIndices(2)}.response.values;
            end % loop over cell indicies
            
            tempPacket.response.values=mean(responseArray);
            tempPacket.response.sem=std(responseArray)/sqrt(length(theCellIndices));            
            [paramsFit,rSquared,modelResponseStruct]=mriBDFM_FitIAMPModelToPacket(tempPacket, hrfKernelStructCellArray{ss});
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.paramsFit=paramsFit;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.rSquared=rSquared;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.modelResponseStruct=modelResponseStruct;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.responseStruct=tempPacket.response;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.stimTypes=tempPacket.stimulus.metaData.stimTypes;
            fitResultsStructAvgResponseCellArray{ss,ii,jj}.stimLabels=tempPacket.stimulus.metaData.stimLabels;            
            subplot(length(modDirections),length(stimOrders),jj+(ii-1)*length(stimOrders));
            mriBDFM_PlotTimeSeriesFits(tempPacket.stimulus,tempPacket.response,modelResponseStruct)
            title([modDirections{ii} ' order ' stimOrders{jj}]);
        end % loop over modulation directions
    end % loop over stimulus orders
end % loop over subjects
