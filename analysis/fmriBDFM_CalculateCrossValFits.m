function [ xValFitStructureCellArray ] = fmriBDFM_CalculateCrossValFits(packetCellArray, hrfKernelStructCellArray, varargin)
% function [packetCellArray] = fmriBDFM_CalculateCrossValFits(thePacket, hrfKernelStructCellArray)
%

%% Parse vargin for options passed here
%
% Setting 'KeepUmatched' to true means that we can pass the varargin{:})
% along from a calling routine without an error here, if the key/value
% pairs recognized by the calling routine are not needed here.
p = inputParser; p.KeepUnmatched = true;
p.addRequired('packetCellArray',@iscell);
p.addRequired('hrfKernelStructCellArray',@iscell);
p.addParameter('carryCovars',false,@islogical);
p.parse(packetCellArray,hrfKernelStructCellArray,varargin{:});

% Announce our intentions
fprintf('>> Calculating cross-validated parameters\n');

% Construct the model object
tfeHandle = tfeIAMP('verbosity','none');

% How many partitions will we test in the cross validation?
maxPartitions=100;

fprintf(['\t Will examine ' strtrim(num2str(maxPartitions)) ' parititions for each subject / direction.\n']);

%% Prepare the packetCellArray for fitting
% Loop through the packets and
%  - prepare the HRF kernel
%  - downsample the stimulus array for speed
%  - create a carry-over aware set of stim types
%  - build an array to identify the stimulus type in each packet

fprintf('\t Preparing the HRFs and stimulus vectors\n');

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);
modDirections={'LightFlux','L-M','S'};
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
            
            % create carry-over stimLabels and stimTypes
            if p.Results.carryCovars
                if ischar(thePacket.stimulus.metaData.stimLabels{1})
                    uniqueStimLabels=unique(thePacket.stimulus.metaData.stimLabels);
                end
                if isnumeric(thePacket.stimulus.metaData.stimLabels{1})
                    uniqueStimLabels=unique(cell2mat(thePacket.stimulus.metaData.stimLabels));
                    uniqueStimLabels=cellfun(@num2str, num2cell(uniqueStimLabels), 'UniformOutput', false);
                end
                newStimLabels=cell(1);
                labelCounter=1;
                for uu=1:length(uniqueStimLabels) % prior stimulus
                    for vv=1:length(uniqueStimLabels) % current stimulus
                        newStimLabels{labelCounter}=[uniqueStimLabels{uu} '_x_' uniqueStimLabels{vv}];
                        labelCounter=labelCounter+1;
                    end
                end
                stimTypes=thePacket.stimulus.metaData.stimTypes;
                priorStimLabel=uniqueStimLabels{1};
                for ii=1:length(stimTypes)
                    currentStimLabel=uniqueStimLabels{stimTypes(ii)};
                    carryOverLabel=[priorStimLabel '_x_' currentStimLabel];
                    newStimTypes(ii)=find(strcmp(newStimLabels,carryOverLabel));
                    priorStimLabel=currentStimLabel;
                end
                thePacket.stimulus.metaData.stimLabels=newStimLabels;
                thePacket.stimulus.metaData.stimTypes=newStimTypes';
            end % create carry-over covariates
            
            % put the modified packet back into the cell arrray
            packetCellArray{ss,rr}=thePacket;
            
        end % the packet is not empty
    end % loop over runs
end % loop over subjects

fprintf('\t Looping over subjects and modulation directions\n');

for ss=1:nSubjects
    for ii=1:length(modDirections)
        
        fprintf('\t\t * Subject <strong>%g</strong> , modDirection <strong>%g</strong>\n', ss, ii);
        
        % Identify the set of packets with this modulation direction for
        % this subject
        theCellIndices=find( strcmp(modulationDirectionCellArray(ss,:),modDirections{ii})==1 );
        subPacketCellArray=packetCellArray(ss,theCellIndices);
        
        % Build a linked partition matrix for this set of packets
        partitionMatrix = fmriBDFM_CreateLinkedPartitionMatrix(subPacketCellArray);
        nPartitions=size(partitionMatrix,1);
        
        % Take a random subset of all available partitions
        ix=randperm(nPartitions);
        partitionMatrix=partitionMatrix(ix,:);
        partitionMatrix=partitionMatrix(1:maxPartitions,:);
        nPartitions=size(partitionMatrix,1);
        
        % Conduct the cross validation
        [ xValFitStructure, averageResponseStruct, modelResponseStruct ] = crossValidateFits( subPacketCellArray, tfeHandle, ...
            'partitionMatrix', partitionMatrix, ...
            'aggregateMethod', 'mean',...
            'verbosity', 'none',...
            'searchMethod', 'linearRegression', ...
            'errorType', '1-r2');
        
        xValFitStructureCellArray{ss,ii}=xValFitStructure;
        
        % Plot the fit to the data
        
        figure
        plot(averageResponseStruct.timebase,averageResponseStruct.values)
        hold on
        plot(modelResponseStruct.timebase,modelResponseStruct.values)
        hold off
    end % loop over modulation directions
end % loop over subjects

end % main function



