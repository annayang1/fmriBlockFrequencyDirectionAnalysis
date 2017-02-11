function [concatPacketCellArray] = fmriBDFM_ConcatenateABPairs(packetCellArray)
%
% This routine concatenates pairs of
% packets that are of the A and B stimulus order type
%

% Instantiate a model (any will do) to allow access to the top level concat
% method
tfeHandle = tfeIAMP('verbosity','none');

% Obtain the stimulus orders for the packetCellArray
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

% Loop through the pairs and produce the concatPacketCellArray
nPairs=length(theOrderACellIndices);
concatPacketCellArray=cell(1);
for jj=1:nPairs
    indexVals=[ theOrderACellIndices(jj), theOrderBCellIndices(jj) ];
    concatPacketCellArray{jj}=tfeHandle.concatenatePackets(packetCellArray(indexVals));
end

% Clear the model object. We are done with it.
delete(tfeHandle);
end % function
