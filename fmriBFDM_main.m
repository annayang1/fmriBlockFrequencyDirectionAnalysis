% fmriBlockFrequencyDirectionAnalysis.
%
% Code to analyze data collected at Mount Sinai using 12-second blocked
%  stimulus presentations of uniform field flicker between 2 and 64 Hz,
%  with different modulation directions (Light flux, L-M, and S) in
%  separate runs.

%% Housekeeping
clearvars; close all; clc;
warning on;

%% Hardcoded parameters of analysis

% Define data cache behavior
stimulusCacheBehavior='skip';
responseCacheBehavior='load';
packetCacheBehavior='load';
kernelCacheBehavior='load';
resultCacheBehavior='make';

% Set the list of hashes that uniquely identify caches to load

stimStructCellArrayHash = '033020e56f4e86a857cb0513b76742cf';

responseStructCellArrayHash = {'c2ef0b07d862edfbb503352f66ebf3db',...
    '9d26651449df3650da8fd782f5a80b50',...
    'b7a8755b84b5fa9aaf512dd3e9fc5576',...
    '8b36cc768142b18f7a3fd811d7a334a5',...
    'd7b07264a4fb0526751334ef380509b2',...
    '96ad3facc2fb22f9586d05b1a224ef10'};

packetCellArrayHash = {'80ede36bd74ce86f61026bfc8610f5bb',...
'22250bd49971b59a6c0ec6d83854e590',...
'90567c08f18023e7b2c523e09eecfbdc',...
'a79545a43392fee9ada03e0cb3c3ecab',...
'b9bb1e3b5004213d465999d5f134ac26',...
'bbbbb589a04ea18e7451fb1c8333919f'};

kernelStructCellArrayHash = '4d49d67800895e0bf7d33f010a9f2bdf';

% Discover user name and find the Dropbox directory
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/fmriBlockFrequencyDirectionAnalysis/');

% Set responseDataDir path used to make or load the response data files
switch responseCacheBehavior
    case 'make'
        responseDataDir = '/data/jag/MELA'; % running on the cluster
        %responseDataDir = fullfile('/Users', userName, 'ccnCluster/MELA'); % When cross-mounted
        responseStructCacheDir = 'MOUNT_SINAI/responseStructCache';
    case 'load'
        responseDataDir = dropboxAnalysisDir;
        responseStructCacheDir='responseStructCache';
end

% Establish basic directory names
packetCacheDir='packetCache';
stimulusStructCacheDir='stimulusStructCache';
kernelStructCacheDir='kernelStructCache';
resultsStructCacheDir='resultsStructCache';

% Define the regions of interest to be studied
regionTags={'V1_0-30' 'V1_0-2' 'V1_2-8' 'V1_8-17' 'V1_17-30' 'LGN' };

kernelRegion='V1_0-30';

%% Make or load the stimStructure
switch stimulusCacheBehavior
    case 'make'
        % inform the user
        fprintf('>> Creating stimulius structures for this experiment\n');
        
        % obtain the stimulus structures for all sessions and runs
        [stimStructCellArray] = fmriBFDM_LoadStimStructCellArray(userName);
        
        % calculate the hex MD5 hash for the responseCellArray
        stimStructCellArrayHash = DataHash(stimStructCellArray);
        
        % Set path to the stimStructCache and save it using the MD5 hash name
        stimStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, stimulusStructCacheDir, [stimStructCellArrayHash '.mat']);
        save(stimStructCacheFileName,'stimStructCellArray','-v7.3');
        fprintf(['Saved the stimStructCellArray with hash ID ' stimStructCellArrayHash '\n']);
    case 'load'
        fprintf('>> Loading cached stimulusStruct\n');
        stimStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, stimulusStructCacheDir, [stimStructCellArrayHash '.mat']);
        load(stimStructCacheFileName);
    case 'skip'
        fprintf('>> Skipping the stimStructCellArray\n');
    otherwise
        error('Please define a legal packetCacheBehavior');
end

%% Make the packetCellArray, if requested
if strcmp (packetCacheBehavior,'make');
    for tt = 1:length(regionTags)
        
        %% Create or load the responseStructCellArrays
        switch responseCacheBehavior
            case 'make'
                % inform the user
                fprintf(['>> Creating response structures for the region >' regionTags{tt} '<\n']);
                clear responseStructCellArray % minimizing memory footprint across loops
                
                % obtain the response structures for all sessions and runs
                [responseStructCellArray] = fmriBFDM_LoadResponseStructCellArray(regionTags{tt}, responseDataDir);
                
                % calculate the hex MD5 hash for the responseCellArray
                responseStructCellArrayHash = DataHash(responseStructCellArray);
                
                % Set path to the packetCache and save it using the MD5 hash name
                responseStructCacheFileName=fullfile(responseDataDir, packetCacheDir, responseStructCacheDir, [regionTags{tt} '_' responseStructCellArrayHash '.mat']);
                save(responseStructCacheFileName,'responseStructCellArray','-v7.3');
                fprintf(['Saved the responseStruct with hash ID ' responseStructCellArrayHash '\n']);
            case 'load'
                fprintf('>> Loading cached responseStruct\n');
                responseStructCacheFileName=fullfile(responseDataDir, packetCacheDir, responseStructCacheDir, [regionTags{tt} '_' responseStructCellArrayHash{tt} '.mat']);
                load(responseStructCacheFileName);
            otherwise
                error('Please define a legal packetCacheBehavior');
        end
        
        % assemble the stimulus and response structures into packets
        [packetCellArray] = fmriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray );
        
        % Remove any packets with attention task hit rate below 60%
        [packetCellArray] = fmriBDFM_FilterPacketCellArrayByPerformance(packetCellArray,0.6);
        
        % Derive the HRF from the attention events for each packet, and store it in
        % packetCellArray{}.response.metaData.fourierFitToAttentionEvents.[values,timebase]
        [packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray);
        
        % calculate the hex MD5 hash for the packetCellArray
        packetCellArrayHash = DataHash(packetCellArray);
        
        % Set path to the packetCache and save it using the MD5 hash name
        packetCacheFileName=fullfile(responseDataDir, packetCacheDir, [regionTags{tt} '_' packetCellArrayHash '.mat']);
        save(packetCacheFileName,'packetCellArray','-v7.3');
        fprintf(['Saved the packetCellArray with hash ID ' packetCellArrayHash '\n']);
        
    end % loop over regions
end % check if we are to make packets


%% Make the kernelStruct for each subject, if requested
if strcmp (kernelCacheBehavior,'make');
    fprintf('>> Making the kernelStruct for each subject\n');
    
    % identify which packetCellArrayHash corresponds to the kernelRegion
    hashIDX=find(strcmp(regionTags,kernelRegion));
    
    % load the packetCellArray to be used for kernel definition
    packetCacheFileName=fullfile(responseDataDir, packetCacheDir,  [kernelRegion '_' packetCellArrayHash{hashIDX} '.mat']);
    load(packetCacheFileName);
    
    % Create an average HRF for each subject across all runs
    [hrfKernelStructCellArray] = fmriBDFN_CreateSubjectAverageHRFs(packetCellArray);
    
    % calculate the hex MD5 hash for the hrfKernelStructCellArray
    kernelStructCellArrayHash = DataHash(hrfKernelStructCellArray);
    
    % Set path to the packetCache and save it using the MD5 hash name
    kernelStructCacheFileName=fullfile(responseDataDir, packetCacheDir, kernelStructCacheDir, [kernelRegion '_' kernelStructCellArrayHash '.mat']);
    save(kernelStructCacheFileName,'hrfKernelStructCellArray','-v7.3');
    fprintf(['Saved the kerneStructCellArray with hash ID ' kernelStructCellArrayHash '\n']);
    
end % Check if kernelStruct generation is requested


%% Perform the analysis, if requested
if strcmp (resultCacheBehavior,'make');
    % Load the kernelStruct
    kernelStructCacheFileName=fullfile(responseDataDir, packetCacheDir, kernelStructCacheDir, [kernelRegion '_' kernelStructCellArrayHash '.mat']);
    load(kernelStructCacheFileName);
    
    % Loop over regions to be analyzed
    for tt = 1:length(regionTags)
        fprintf(['>> Analyzing region >' regionTags{tt} '<\n']);

        % Load the packet for this region
        packetCacheFileName=fullfile(responseDataDir, packetCacheDir, [regionTags{tt} '_' packetCellArrayHash{tt} '.mat']);
        load(packetCacheFileName);
        
        % Model and remove the attention events from the responses in each packet
        [packetCellArray] = fmriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray);
        
        % Perform cross-validated model comparison
        %            fmriBDFM_CalculateCrossValFits(packetCellArray, hrfKernelStructCellArray);
        
        % Fit the IAMP model to the average responses for each subject, modulation
        % direction, and stimulus order
        [fitResultsStructAvgResponseCellArray] = fmriBDFM_FitAverageResponsePackets(packetCellArray, hrfKernelStructCellArray);
        
        % Plot the TTFs
        fmriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray);
        
        % Plot the carry-over matrices
        fmriBDFM_AnalyzeCarryOverEffects(fitResultsStructAvgResponseCellArray);
    end % loop over regions
end % Check if analysis is requested



