function plotHandles = fmriBDFM_PlotAmpFreqByEccen( peakFreqCellArray,peakAmpCellArray )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

nROIs=length(peakFreqCellArray);
nSubjects=size(peakFreqCellArray{1},1);
nDirections=size(peakFreqCellArray{1},2);

ROILabels={'All','0-1.25','1.25-5','5-11.4','11.4-20.4','20.4-32','32-46'};
modDirections={'LightFlux','L-M','S'};

% Get the data out of the cell array into a useful form


for ss=1:nSubjects
figure
for rr=1:nROIs
       peakFreqArray=peakFreqCellArray{rr};
       for dd=1:nDirections
           peakFreq(rr,dd)=peakFreqArray(ss,dd);
       end % loop over directions
    end
plot(3:1:7,peakFreq(3:end,1),'k');
hold on
plot(3:1:7,peakFreq(3:end,2),'r');
plot(3:1:7,peakFreq(3:end,3),'b');

end % loop over subjects



for ss=1:nSubjects
figure
for rr=1:nROIs
       peakAmpArray=peakAmpCellArray{rr};
       for dd=1:nDirections
           peakAmp(rr,dd)=peakAmpArray(ss,dd);
       end % loop over directions
    end
plot(3:1:7,peakAmp(3:end,1),'k');
hold on
plot(3:1:7,peakAmp(3:end,2),'r');
plot(3:1:7,peakAmp(3:end,3),'b');

end % loop over subjects


end

