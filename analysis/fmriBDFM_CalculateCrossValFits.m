function [ ] = fmriBDFM_CalculateCrossValFits(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = fmriBDFM_CalculateCrossValFits(thePacket, hrfKernelStructCellArray)
%

% Announce our intentions
fprintf('>> Conducting sequential model fits to the data\n');

%% Prepare the packetCellArray for fitting
% Loop through the packets and
%  - prepare the HRF kernel
%  - downsample the stimulus array for speed
%  - build an array to identify the stimulus type in each packet

fprintf('\t Preparing the HRFs and stimulus vectors\n');

% Construct the model object to be used for resampling
tfeHandle = tfeIAMP('verbosity','none');

modDirections={'LightFlux','L-M','S'};
nSubjects=size(packetCellArray,1);
nDirections=size(modDirections,2);
nRuns=size(packetCellArray,2);
for ss=1:nSubjects
    
    % Grab the average hrf and prepare it as a kernel
    % Assume the deltaT of the response timebase is the same
    % across packets for this subject
    theHRFKernelStruct=hrfKernelStructCellArray{ss};
    check = diff(packetCellArray{ss,1}.response.timebase);
    responseDeltaT = check(1);
    nSamples = ceil((theHRFKernelStruct.timebase(end)-theHRFKernelStruct.timebase(1))/responseDeltaT);
    newKernelTimebase = theHRFKernelStruct.timebase(1):responseDeltaT:(theHRFKernelStruct.timebase(1)+nSamples*responseDeltaT);
    theHRFKernelStruct = tfeHandle.resampleTimebase(theHRFKernelStruct,newKernelTimebase);
    theHRFKernelStruct = prepareHRFKernel(theHRFKernelStruct);
    
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            % Build the list of modulationDirections
            modulationDirectionCellArray{ss,rr}=(thePacket.stimulus.metaData.modulationDirection);
            
            % Place the kernel struct in the packet
            thePacket.kernel = theHRFKernelStruct;
            
            % downsample the stimulus values to 100 ms deltaT to speed things up
            totalResponseDuration=thePacket.response.metaData.TRmsecs * ...
                length(thePacket.response.values);
            newStimulusTimebase=linspace(0,totalResponseDuration-100,totalResponseDuration/100);
            thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newStimulusTimebase);
            
            % put the modified packet back into the cell arrray
            packetCellArray{ss,rr}=thePacket;
            
        end % the packet is not empty
    end % loop over runs
end % loop over subjects
delete(tfeHandle);

%% Obtain cross-validated variance explained for the IAMP model

fprintf('\t Obtain cross-validated variance explained for the IAMP model\n');
figure

% Construct the model object to be used for resampling
tfeHandle = tfeIAMP('verbosity','none');

for ss=1:nSubjects
    for ii=1:nDirections
        
        fprintf('\t\t * Subject <strong>%g</strong> , modDirection <strong>%g</strong>\n', ss, ii);
        
        % Identify the set of packets with this modulation direction for
        % this subject
        theCellIndices=find( strcmp(modulationDirectionCellArray(ss,:),modDirections{ii})==1 );
        subPacketCellArray=packetCellArray(ss,theCellIndices);
        
        % Concatenate the A and B stimulus order pairs
        subPacketCellArray=fmriBDFM_ConcatenateABPairs(subPacketCellArray);
        
        % Conduct the cross validation
        [ xValFitStructure, averageResponseStruct, modelResponseStruct ] = crossValidateFits( subPacketCellArray, tfeHandle, ...
            'partitionMethod','twentyPercent', ...
            'maxPartitions',20, ...
            'aggregateMethod', 'mean',...
            'verbosity', 'none',...
            'searchMethod', 'linearRegression', ...
            'errorType', '1-r2');
        
        xValFitStructureCellArray_IAMP{ss,ii}=xValFitStructure;
        
        % Plot the fit to the data
        subplot(nSubjects,nDirections,ii+(ss-1)*nDirections);
        plot(averageResponseStruct.timebase,averageResponseStruct.values)
        hold on
        plot(modelResponseStruct.timebase,modelResponseStruct.values)
        title(modDirections(ii))
        xlabel('time [msecs]');
        ylabel('response [%]'); set(gca,'FontSize',15); colorbar;
        hold off
        
        % Report the train and test fvals
        fprintf('\t\t\t R-squared train: %g , test: %g \n', 1-mean(xValFitStructure.trainfVals), 1-mean(xValFitStructure.testfVals));
        
    end % loop over modulation directions
end % loop over subjects
delete(tfeHandle);


%% Obtain cross-validated variance explained for the IAMP model with carry-over

fprintf('\t Obtain cross-validated variance explained for the IAMP model with carry over\n');
figure

% Construct the model object to be used for resampling
tfeHandle = tfeIAMP('verbosity','none');

for ss=1:nSubjects
    for ii=1:nDirections
        
        fprintf('\t\t * Subject <strong>%g</strong> , modDirection <strong>%g</strong>\n', ss, ii);
        
        % Identify the set of packets with this modulation direction for
        % this subject
        theCellIndices=find( strcmp(modulationDirectionCellArray(ss,:),modDirections{ii})==1 );
        subPacketCellArray=packetCellArray(ss,theCellIndices);
        
        % Convert the stimLabels and stimTypes to carry-over format
        subPacketCellArray = fmriBDFM_CreateCarryOverStimTypes(subPacketCellArray);
        
        % Concatenate the A and B stimulus order pairs
        subPacketCellArray=fmriBDFM_ConcatenateABPairs(subPacketCellArray);
        
        % Conduct the cross validation
        [ xValFitStructure, averageResponseStruct, modelResponseStruct ] = crossValidateFits( subPacketCellArray, tfeHandle, ...
            'partitionMethod','twentyPercent', ...
            'maxPartitions',20, ...
            'aggregateMethod', 'mean',...
            'verbosity', 'none',...
            'searchMethod', 'linearRegression', ...
            'errorType', '1-r2');
        
        xValFitStructureCellArray_carryIAMP{ss,ii}=xValFitStructure;
        
        % Plot the fit to the data
        subplot(nSubjects,nDirections,ii+(ss-1)*nDirections);
        plot(averageResponseStruct.timebase,averageResponseStruct.values)
        hold on
        plot(modelResponseStruct.timebase,modelResponseStruct.values)
        title(modDirections(ii))
        xlabel('time [msecs]');
        ylabel('response [%]'); set(gca,'FontSize',15); colorbar;
        hold off
        
        % Report the train and test fvals
        fprintf('\t\t\t R-squared train: %g , test: %g \n', 1-mean(xValFitStructure.trainfVals), 1-mean(xValFitStructure.testfVals));
        
    end % loop over modulation directions
end % loop over subjects
delete(tfeHandle);


%% Obtain cross-validated variance explained for the BTRM model

fprintf('\t Obtain cross-validated variance explained for the BTRM model\n');
figure

% Construct the model object to be used for resampling
tfeBTRMHandle = tfeBTRM('verbosity','none');

for ss=1:nSubjects
    for ii=1:nDirections
        
        fprintf('\t\t * Subject <strong>%g</strong> , modDirection <strong>%g</strong>\n', ss, ii);
        
        % Identify the set of packets with this modulation direction for
        % this subject
        theCellIndices=find( strcmp(modulationDirectionCellArray(ss,:),modDirections{ii})==1 );
        subPacketCellArray=packetCellArray(ss,theCellIndices);

        % Convert the stimLabels and stimTypes to carry-over format
        subPacketCellArray = fmriBDFM_CreateCarryOverStimTypes(subPacketCellArray);
        
        % Concatenate the A and B stimulus order pairs
        subPacketCellArray=fmriBDFM_ConcatenateABPairs(subPacketCellArray);
        
        % Conduct the cross validation
        [ xValFitStructure, averageResponseStruct, modelResponseStruct ] = crossValidateFits( subPacketCellArray, tfeBTRMHandle, ...
            'partitionMethod','twentyPercent', ...
            'maxPartitions',20, ...
            'aggregateMethod', 'mean',...
            'verbosity', 'full',...
            'errorType', '1-r2');
        
        xValFitStructureCellArray_BTRM{ss,ii}=xValFitStructure;
        
        % Plot the fit to the data
        subplot(nSubjects,nDirections,ii+(ss-1)*nDirections);
        plot(averageResponseStruct.timebase,averageResponseStruct.values)
        hold on
        plot(modelResponseStruct.timebase,modelResponseStruct.values)
        title(modDirections(ii))
        xlabel('time [msecs]');
        ylabel('response [%]'); set(gca,'FontSize',15); colorbar;
        hold off
        
        % Report the train and test fvals
        fprintf('\t\t\t R-squared train: %g , test: %g \n', 1-mean(xValFitStructure.trainfVals), 1-mean(xValFitStructure.testfVals));
        
    end % loop over modulation directions
end % loop over subjects
delete(tfeBTRMHandle);


end % main function



