function [ packetCellArrayOut ] = mriBFDM_DeriveFourierHRF( packetCellArrayIn, secondsToModel, harmonicsToModel )
% function [ packetCellArrayOut ] = mriBFDM_DeriveFourierHRF( packetCellArrayIn )
%
%

% Get the number of sessions

nSessions=size(packetCellArrayIn,1);
nRuns=size(packetCellArrayIn,2);

for ss=1:nSessions
    
    for rr=1:nRuns
        thePacket=packetCellArrayIn{ss,rr};
        if ~isempty(thePacket)
attentionEventPacket.stimulus.timebase=thePacket.stimulus.timebase;
attentionEventPacket.response.timebase=thePacket.response.timebase;
attentionEventPacket.response.values=thePacket.stimulus.timebase;
attentionEventPacket.kernel=[];
attentionEventPacket.metaData=[];

impulseAttentionEvents=zeros(1,length(thePacket.stimulus.timebase));
impulseAttentionEvents(thePacket.stimulus.metaData.eventTimesArray)=1;


attentionEventStruct.timebase=thePacket.stimulus.timebase;
        end % thePacket is not empty        
    end % loop over runs
    
end % loop over sessions

end

