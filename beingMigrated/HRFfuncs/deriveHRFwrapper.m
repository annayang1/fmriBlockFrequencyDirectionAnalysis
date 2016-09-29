function [HRF, cleanedData, SEHRF] = deriveHRFwrapper(timeSeries,attnStartTimes,lengthAttnHRF,type)

% function HRF = fitHRF_FIR(timeSeries,attnStartTimes)
%
% derives HRF across multiple runs

% call the HRF generator for each run, then average across runs
for i = 1:size(timeSeries,1)
   if strcmp(type,'Fourier')
       [hrf,~,~,~,~,timeSeriesNoAttn] ...
       = deriveHRF(timeSeries(i,:)', round(attnStartTimes(i,attnStartTimes(i,:)~=-1).*1000), ...
                                1000,lengthAttnHRF.*1000,lengthAttnHRF,type) ;       
   elseif strcmp(type,'FIR')
       [hrf,~,~,~,~,timeSeriesNoAttn] ...
       = deriveHRF(timeSeries(i,:)', round(attnStartTimes(i,attnStartTimes(i,:)~=-1).*1000), ...
                                1000,lengthAttnHRF.*1000,lengthAttnHRF,type) ;
   else
       error('fitHRF: SPECIFY VALID MODEL');
   end
   hrfStore(i,:) = hrf ;    
   cleanedData(i,:) = timeSeriesNoAttn;
end

HRF = mean(hrfStore);
SEHRF = std(hrfStore)./sqrt(size(hrfStore,1));

gribble = 1;