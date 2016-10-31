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

end % function
