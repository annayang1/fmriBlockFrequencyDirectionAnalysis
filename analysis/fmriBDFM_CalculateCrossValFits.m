function [ xValFitStructureCellArray ] = fmriBDFM_CalculateCrossValFits(packetCellArray, hrfKernelStructCellArray)
% function [packetCellArray] = fmriBDFM_CalculateCrossValFits(thePacket, hrfKernelStructCellArray)
%

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
        [ xValFitStructure ] = crossValidateFits( subPacketCellArray, tfeHandle, ...
            'partitionMatrix', partitionMatrix, ...
            'aggregateMethod', 'mean',...
            'verbosity', 'none',...
            'searchMethod','linearRegression', ...
            'errorType','1-r2');
        
        xValFitStructureCellArray{ss,ii}=xValFitStructure;
        
    end % loop over modulation directions
end % loop over subjects

end % main function





function [partitionMatrix] = fmriBDFM_CreateLinkedPartitionMatrix(packetCellArray)
%
% This routine creates a custom partition matrix that links pairs of
% packets that are of the A and B stimulus order type
%

% Obtain the stimulus orders for this packetCellArray
stimOrders={'A','B'};
nRuns=length(packetCellArray);
for rr=1:nRuns
    if isempty(packetCellArray{rr})
        error('This sub-routine should not receive empty packets');
    else
        stimulusOrderAorBCellArray{rr}=(packetCellArray{rr}.stimulus.metaData.stimulusOrderAorB);
    end % the packet is not empty
end % loop over runs

% Identify which packets are type A or B. Make sure there are equal numbers
theOrderACellIndices=find( strcmp(stimulusOrderAorBCellArray,stimOrders{1} )==1 );
theOrderBCellIndices=find( strcmp(stimulusOrderAorBCellArray,stimOrders{2} )==1 );
if length(theOrderACellIndices)~=length(theOrderBCellIndices)
    error('Routine expects the same number of A and B stimulus orders');
end

nPairs=length(theOrderACellIndices);

% Create permuted pairings of A and B packets
basePermMatrix=speye(nPairs);
idxPermMatrix=perms(1:1:nPairs);
basePartitionMatrix=zeros(size(idxPermMatrix,1),nRuns);
for ii=1:size(idxPermMatrix,1)
    thisPermMatrix=basePermMatrix(idxPermMatrix(ii,:),:);
    [aIndices,bIndices]=find(thisPermMatrix);
    for jj=1:nPairs
        basePartitionMatrix(ii,theOrderACellIndices(aIndices(jj)))=jj;
        basePartitionMatrix(ii,theOrderBCellIndices(bIndices(jj)))=jj;
    end
end
nBasePartitions=size(idxPermMatrix,1);

% Each row of the partition matrix is now expanded to include all
% possible partitions of the pairs into train and test sets
splitPartitionsCellArray=partitions(1:1:nPairs,2);
nSplits=length(splitPartitionsCellArray);

partitionCounter=1;
nTargetTrain=ceil(nPairs*0.66);
for ii=1:nSplits
    % Filter to include only partitions with a 66/33 train/test ratio
    if length(splitPartitionsCellArray{ii}{1})==nTargetTrain
        for jj=1:nBasePartitions
            partitionRow=basePartitionMatrix(jj,:);
            for kk=1:length(splitPartitionsCellArray{ii}{2})
                idx=find(partitionRow==splitPartitionsCellArray{ii}{2}(kk));
                partitionRow(idx)=partitionRow(idx)*(-1);
            end % test packet pairs
            partitionMatrix(partitionCounter,:)=partitionRow;
            partitionCounter=partitionCounter+1;
        end % loop over base partitions
    end % this is a usable partition
    
    if length(splitPartitionsCellArray{ii}{2})==nTargetTrain
        for jj=1:nBasePartitions
            partitionRow=basePartitionMatrix(jj,:);
            for kk=1:length(splitPartitionsCellArray{ii}{1})
                idx=find(partitionRow==splitPartitionsCellArray{ii}{1}(kk));
                partitionRow(idx)=partitionRow(idx)*(-1);
            end % test packet pairs
            partitionMatrix(partitionCounter,:)=partitionRow;
            partitionCounter=partitionCounter+1;
        end % loop over base partitions
    end
end % loop over available splits

nPartitions=size(partitionMatrix,1);

% Double check the partition matrix
for ii=1:nPartitions
    partitionRow=partitionMatrix(ii,:);
    % Check that there are 8 positive and 4 negative values in the row
    if sum(partitionRow>0)~=8 || sum(partitionRow<0)~=4
        error('This row does not have the right number of train and test');
    end
    uniqueVals=unique(partitionRow);
    % Check that each unique value is associated with two packets, and that
    % they have different stimulus orderings
    for uu=1:length(uniqueVals)
        idx=find(partitionRow==uniqueVals(uu));
        if length(idx)~=2
            error('This value in this row of the partition matrix is not assigned to two packets');
        end
        if isequal(stimulusOrderAorBCellArray{idx(1)},stimulusOrderAorBCellArray{idx(2)})
            error('This value in this row of the partition matrix is not assigned to different stimulus orders');
        end
    end
    % Check that there is no row duplication
    %     for jj=1:nPartitions
    %         if isequal(partitionMatrix(ii,:),partitionMatrix(jj,:)) && ii~=jj
    %             error('Two rows of the partition matrix are the same');
    %         end
    %     end
end

end % sub-function
