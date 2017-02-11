function [packetCellArray] = fmriBDFM_FilterPacketCellArrayByPerformance(packetCellArray, threshold)
% function [packetCellArray] = fmriBDFM_FilterPacketCellArrayByPerformance(packetCellArray, threshold)
%
% Remove packets with below-threshold performance

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

fprintf('>> Filtering packets with poor attention task performance\n');

for ss=1:nSubjects
    for rr=1:nRuns
        if ~isempty(packetCellArray{ss,rr})
            thisHitRate=packetCellArray{ss,rr}.stimulus.metaData.hitRate;
            if thisHitRate < threshold
                packetCellArray{ss,rr}=[];
                fprintf(['Below threshold packet: ss ' strtrim(num2str(ss)) ', run ' strtrim(num2str(rr)) '\n']);
            end % below thresh hitRate
        end % not an empty packet
    end % loop over runs
end % loop over subjects
