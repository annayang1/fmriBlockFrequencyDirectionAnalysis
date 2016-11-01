function [partitionMatrix] = fmriBDFM_CreateLinkedBootstrapMatrix(packetCellArray)
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
        
        % We add 0.1 to the order A cells and 0.2 to the order B cells.
        % This is used later to force the ordering of concatenation.
        basePartitionMatrix(ii,theOrderACellIndices(aIndices(jj)))=jj+0.1;
        basePartitionMatrix(ii,theOrderBCellIndices(bIndices(jj)))=jj+0.2;
    end
end
nBasePartitions=size(idxPermMatrix,1);

% We now repmat the basePartitionMatrix to create the full partitionMatrix.
% When used for a bootstrap analysis, a different bootstrap sampling of
% each row will be performed. We set up the matrix to support 100
% bootstraps.

nRepsNeeded = ceil(100 / nBasePartitions);
partitionMatrix=repmat(basePartitionMatrix,nRepsNeeded,1);

end % function
