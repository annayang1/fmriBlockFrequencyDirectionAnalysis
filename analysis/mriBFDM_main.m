% mriBlockFrequencyDirectionAnalysis.
%
% Code to analyze data collected at Mt. Sinai using 12-second blocked
%  stimulus presentations of uniform field flicker between 2 and 64 Hz,
%  with different modulation directions (Light flux, L-M, and S) in
%  separate runs.

% Housekeeping
clearvars; close all; clc;
warning on;

% Discover user name
[~, userName] = system('whoami');
userName = strtrim(userName);

% Define packetCacheBehavior. Options include:
%    'make' - load and process stim/response files, save the packets
%    'load' - load the packets from the passed hash name

packetCacheBehavior='load';
packetCellArrayMD5Hash='c9280c61bcc3a366c0f8ddf8eaae29e4';
dropboxAnalysisDir = fullfile('/Users', userName, '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/mriBlockFrequencyDirectionAnalysis/packetCache');

%% Create or load the packetCellArray

switch packetCacheBehavior
    
    case 'make'  % If we are not to load the packetCellArray, then we must generate it
        
        % obtain the stimulus structures for all sessions and runs
        [stimStructCellArray] = mriBFDM_LoadStimStructCellArray(userName);
        
        % obtain the response structures for all sessions and runs
        [responseStructCellArray] = mriBFDM_LoadResponseStructCellArray(userName);
        
        % assemble the stimulus and response structures into packets
        [packetCellArray] = mriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray );
        
        % calculate the hex MD5 for the packetCellArray
        packetCellArrayMD5Hash = DataHash(packetCellArray);
        
        % Set path to the packetCache and save it using the MD5 hash name
        packetCacheFileName=fullfile(dropboxAnalysisDir, [packetCellArrayMD5Hash '.mat']);
        save(packetCacheFileName,'packetCellArray');
        
    case 'load'  % load a cached packetCellArray
        
        fprintf('>> Loading cached packetCellArray\n');
        packetCacheFileName=fullfile(dropboxAnalysisDir, [packetCellArrayMD5Hash '.mat']);
        load(packetCacheFileName);
        
    otherwise
        
        error('Please define a legal packetCacheBehavior');
end

% Derive the HRF from the attention events for each packet, and store it in
% packetCellArray{}.response.metaData.fourierFitToAttentionEvents.[values,timebase]

[packetCellArray] = mriBDFM_DeriveHRFsForPacketCellArray(packetCellArray);

% Create an average HRF for each subject across all runs

[hrfKernelStructCellArray] = mriBDFN_CreateSubjectAverageHRFs(packetCellArray);

% Plot the average HRF for each subject

plot(hrfKernelStructCellArray{1}.timebase,hrfKernelStructCellArray{1}.values);

% Model and remove the attention events from the responses in each packet

[packetCellArray] = mriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray);

% Fit the time-series data from each packet

[packetCellArray] = mriBDFM_FitModelToPacketCellArray(packetCellArray, hrfKernelStructCellArray);