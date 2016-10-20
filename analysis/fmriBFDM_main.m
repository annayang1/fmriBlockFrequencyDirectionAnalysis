% fmriBlockFrequencyDirectionAnalysis.
%
% Code to analyze data collected at Mount Sinai using 12-second blocked
%  stimulus presentations of uniform field flicker between 2 and 64 Hz,
%  with different modulation directions (Light flux, L-M, and S) in
%  separate runs.

% Housekeeping
clearvars; close all; clc;
warning on;

% Discover user name and find the Dropbox directory
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/fmriBlockFrequencyDirectionAnalysis/packetCache');

% Define packetCacheBehavior. Options include:
%    'make' - load and process stim/response files, save the packets
%    'load' - load the packets from the passed hash name
packetCacheBehavior='load';
packetCellArrayTag='V1_0-30degrees';
packetCellArrayHash='7cf491b9934d56bbfc7793fd25c928a9';

% Define resultCacheBehavior. Options include:
%    'make' - load and process stim/response files, save the packets
%    'load' - load the packets from the passed hash name
resultCacheBehavior='make';
resultCellArrayTag='V1_0-30degrees';
resultCellArrayHash='';

%% Create or load the packetCellArray
switch packetCacheBehavior
    
    case 'make'  % If we are not to load the packetCellArray, then we must generate it
        
        % obtain the stimulus structures for all sessions and runs
        [stimStructCellArray] = fmriBFDM_LoadStimStructCellArray(userName);
        
        % obtain the response structures for all sessions and runs
        [responseStructCellArray] = fmriBFDM_LoadResponseStructCellArray(userName);
        
        % assemble the stimulus and response structures into packets
        [packetCellArray] = fmriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray );
        
        % calculate the hex MD5 hash for the packetCellArray
        packetCellArrayHash = DataHash(packetCellArray);
        
        % Set path to the packetCache and save it using the MD5 hash name
        packetCacheFileName=fullfile(dropboxAnalysisDir, [packetCellArrayTag '_' packetCellArrayHash '.mat']);
        save(packetCacheFileName,'packetCellArray','-v7.3');
        fprintf(['Saved the packetCellArray with hash ID ' packetCellArrayHash '\n']);
        
    case 'load'  % load a cached packetCellArray
        
        fprintf('>> Loading cached packetCellArray\n');
        packetCacheFileName=fullfile(dropboxAnalysisDir, [packetCellArrayTag '_' packetCellArrayHash '.mat']);
        load(packetCacheFileName);
        
    otherwise
        
        error('Please define a legal packetCacheBehavior');
end

% Remove any packets with attention task hit rate below 60%
[packetCellArray] = fmriBDFM_FilterPacketCellArrayByPerformance(packetCellArray,0.6);

% Derive the HRF from the attention events for each packet, and store it in
% packetCellArray{}.response.metaData.fourierFitToAttentionEvents.[values,timebase]
[packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray);

% Create an average HRF for each subject across all runs
[hrfKernelStructCellArray] = fmriBDFN_CreateSubjectAverageHRFs(packetCellArray);

% Model and remove the attention events from the responses in each packet
[packetCellArray] = fmriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray);

% Fit the IAMP model to the average responses for each subject, modulation
% direction, and stimulus order
[fitResultsStructAvgResponseCellArray] = fmriBDFM_FitAverageResponsePackets(packetCellArray, hrfKernelStructCellArray);

% Plot the TTFs
fmriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray);

% Plot the carry-over matrices
fmriBDFM_AnalyzeCarryOverEffects(fitResultsStructAvgResponseCellArray);