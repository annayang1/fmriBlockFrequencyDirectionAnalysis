function [packetCellArray] = mriBDFM_DeriveHRFsForPacketCellArray(packetCellArray)
% function [packetCellArray] = mriBDFM_DeriveHRFsForPacketCellArray(packetCellArray)
%

% Set some parameters for the HRF derivation
msecsToModel=16000;
numFourierComponents=16;

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

fprintf('>> Deriving HRF by Fourier basis fitting\n');

for ss=1:nSubjects
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            fprintf('\t* Subject <strong>%g</strong> / <strong>%g</strong>, Run <strong>%g</strong> / <strong>%g</strong>\n', ss, nSubjects, rr, nRuns);
            [ kernelStruct ] = ...
                mriBFDM_FitFourierBasis(thePacket, msecsToModel, ...
                numFourierComponents);
            thePacket.response.metaData.fourierFitToAttentionEvents=kernelStruct;
            packetCellArray{ss,rr}=thePacket;
        end
    end
end