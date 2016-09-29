function tempFreq = BDCMfilenameReader(BDCMfilename)

% function tempFreq = BDCMfilenameReader(BDCMfilename)
% 
% reads in a data file name string for the BDCM study, and extracts the
% temporal frequency of the stimulus corresponding to that file name

% find the location of 'Hz' in the file name
HzLoc = strfind(BDCMfilename,'Hz');

% get the three letters before that
tempFreqLoc = [HzLoc-3 HzLoc-2 HzLoc-1];
tempFreqChars = BDCMfilename(tempFreqLoc);

% grab all characters that are digits
tempFreqStr = '';

for i = 1:length(tempFreqChars)
   if ismember(tempFreqChars(i),'0123456789')
      tempFreqStr(length(tempFreqStr)+1) = tempFreqChars(i);
   end
end

% convert to double
tempFreq = str2num(tempFreqStr);

end