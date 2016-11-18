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
stimulusStructCacheDir='stimulusStructCache';

% Set Cluster path used to load the response data files
clusterDataDir=fullfile('/Users', userName, 'ccnCluster/MELA');
clusterDataDir='/data/jag/MELA';
responseStructCacheDir='responseStructCache';

% Define the regions of interest to be studied
regionTags={'V1_0-30' 'V1_0-2' 'V1_2-8' 'V1_8-17' 'V1_17-30' 'LGN'};

% Define packetCacheBehavior. Options include:
%    'make' - load and process stim/response files, save the packets
%    'load' - load the packets from the passed hash name
%    'skip'
stimulusCacheBehavior='skip';
responseCacheBehavior='make';
resultCacheBehavior='skip';

switch stimulusCacheBehavior
    case 'make'
        % inform the user
        fprintf(['>> Creating response structures for the region >' regionTags{tt} '<\n']);

        % obtain the stimulus structures for all sessions and runs
        [stimStructCellArray] = fmriBFDM_LoadStimStructCellArray(userName);
        
        % calculate the hex MD5 hash for the responseCellArray
        stimStructCellArrayHash = DataHash(stimStructCellArray);
        
        % Set path to the stimStructCache and save it using the MD5 hash name
        stimStructCacheFileName=fullfile(dropboxAnalysisDir, stimulusStructCacheDir, [stimStructCellArrayHash '.mat']);
        save(stimStructCacheFileName,'stimStructCellArrayHash','-v7.3');
        fprintf(['Saved the stimStructCellArray with hash ID ' stimStructCellArrayHash '\n']);
    case 'load'
        stimStructCacheFileName=fullfile(dropboxAnalysisDir, stimulusStructCacheDir, [stimStructCellArrayHash '.mat']);
        load(stimStructCacheFileName);
    case 'skip'
        warning('Proceeding without making or loading the stimStructCellArray');
    otherwise
        error('Please define a legal packetCacheBehavior');
end

%% Loop over the regions to be analyzed

for tt = 1:length(regionTags)
    
    %% Create or load the responseStructCellArrays
    switch responseCacheBehavior
        case 'make'
            % obtain the response structures for all sessions and runs
            [responseStructCellArray] = fmriBFDM_LoadResponseStructCellArray(regionTags{tt}, clusterDataDir);
            
            % calculate the hex MD5 hash for the responseCellArray
            responseStructCellArrayHash = DataHash(responseStructCellArray);
            
            % Set path to the packetCache and save it using the MD5 hash name
            responseStructCacheFileName=fullfile(responseStructCacheDir, [regionTags{tt} '_' responseStructCellArrayHash '.mat']);
            save(responseStructCacheFileName,'responseStructCellArray','-v7.3');
            fprintf(['Saved the packetCellArray with hash ID ' responseStructCellArrayHash '\n']);
        case 'load'
            fprintf('>> Loading cached responseStruct\n');
            responseStructCacheFileName=fullfile(responseStructCacheDir, [regionTags{tt} '_' responseStructCellArrayHash '.mat']);
            load(responseStructCacheFileName);
        otherwise
            error('Please define a legal packetCacheBehavior');
    end
    
    %% Make, load, or skip the analysis
    
    switch resultCacheBehavior
        case 'make'
            % assemble the stimulus and response structures into packets
            [packetCellArray] = fmriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray );
            
            % Remove any packets with attention task hit rate below 60%
            [packetCellArray] = fmriBDFM_FilterPacketCellArrayByPerformance(packetCellArray,0.6);
            
            % Derive the HRF from the attention events for each packet, and store it in
            % packetCellArray{}.response.metaData.fourierFitToAttentionEvents.[values,timebase]
            [packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray);
            
            % Create an average HRF for each subject across all runs
            [hrfKernelStructCellArray] = fmriBDFN_CreateSubjectAverageHRFs(packetCellArray);
            
            % Model and remove the attention events from the responses in each packet
            [packetCellArray] = fmriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray);
            
            % Perform cross-validated model comparison
            fmriBDFM_CalculateCrossValFits(packetCellArray, hrfKernelStructCellArray);
            
            % Fit the IAMP model to the average responses for each subject, modulation
            % direction, and stimulus order
            [fitResultsStructAvgResponseCellArray] = fmriBDFM_FitAverageResponsePackets(packetCellArray, hrfKernelStructCellArray);
            
            % Plot the TTFs
            fmriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray);
            
            % Plot the carry-over matrices
            fmriBDFM_AnalyzeCarryOverEffects(fitResultsStructAvgResponseCellArray);
        case 'skip'
            warning('Proceeding  without making or loading the results');
    end
    
end % loop over regions