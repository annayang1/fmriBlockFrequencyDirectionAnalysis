function [outMat,outCovs] = indMat(inMat)

% Output a linearly independet matrix using Matlab's 'rank' function
%
%   Usage:
%   [outMat,goodCovs] = indMat(inMat)
%
%   Output:
%   outMat - only those elements of the input matrix that are linearly
%   independent
%   outCovs - index into the input matrix of the linearly independent
%   elements
%
%   Written by Andrew S Bock Jul 2016

%%
outMat = [];
outCovs = [];
ct = 0;
for i = 1:size(inMat,2)
    tmpMat = [outMat,inMat(:,i)];
    if rank(tmpMat) > ct
        ct = ct + 1;
        outMat = tmpMat;
        outCovs = [outCovs,i];
    end   
end