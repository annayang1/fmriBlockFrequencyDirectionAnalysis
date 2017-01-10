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
responseCacheBehavior='skip';
packetCacheBehavior='skip';
kernelCacheBehavior='skip';
resultCacheBehavior='make';

% Set the list of hashes that uniquely identify caches to load

stimStructCellArrayHash = '033020e56f4e86a857cb0513b76742cf';

responseStructCellArrayHash = {'ebb22378d90476a01fd795ecf3fff856',...
    '4d00efe8d9edc0699d723a7c9096b282',...
    'f9f113ba12633f77b6bdf9afaaa249fe',...
    '3f786a011e4e93a19f9431c6f9e09151',...
    '687c82e7490066f2c3809c935ceb7840',...
    'e3bf1d12875f4084e6f8d8b882367c19',...
    'e238c3098f83267b512fe8d0ae251860',...
    '7ba187d70a3bbdc67924c13c7d5b6641',...
    '20a0c254243c54da00d3feeb13370dad',...
    '17313e33506d8a56a7e5563b61f8f037',...
    '6e984ddb78f02f31133201603c5a08e2',...
    '94cb03f991ad3854d6cc7cb53e61d4db',...
    '93cfffd396113ca6e58e3e0dd543f3a2',...
    '7fddf5f28a707e99675015193bc03ada',...
    '34668f8faa9a5d37de21ef5df06eaa7d'};

packetCellArrayHash = {'5d1e397ca29f5e91aaa6b7ca7d2babd4',...
    'fd99ca756f8dcd8ea5c79e48926f2dee',...
    'bb1f5d03f6a287ff861e9d21162465c3',...
    '51867c6137a61285be3e73fd67942b25',...
    '13bb35ab2004222de33db146ba9f9941',...
    '9354d9393ca0d34b45d4d0dbd475bc21',...
    'cedc3dfd2f51de9c522bafb53d954883',...
    '27354a8d380c1714c64c4af23d576fa9',...
    'fa0de7991e5536d89471637e57661d60',...
    'a9dc4b9c6beefc9e117e040c0c7f2a62',...
    '7d2eaf6a307e5322b0f522570ec39d62',...
    'adaf7160ae4a7e1b7fb4f3b19442080a',...
    '6ccc69c6d8aeba6425b8151f6399cdd6',...
    '5ac25e35104256b5dc563a091247ad76',...
    '1d5c00e39aea6a5bc6b4be80b13b8357'};

kernelStructCellArrayHash = '80a196a75e57858a9b4873e8ece4e4da';

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
regionTags={'V1_Full' 'V1_1' 'V1_2' 'V1_3' 'V1_4' 'V1_5' 'V1_6'};
%    'V23_Full' 'V23_1' 'V23_2' 'V23_3' 'V23_4' 'V23_5' 'V23_6' ...
%    'LGN_x' };

kernelRegion='MaxMelKernels';
xValRegion='V1_Full';

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


%% Make the responseStructCellArrays, if requested
if strcmp (responseCacheBehavior,'make');
    for tt = 1:length(regionTags)
        % inform the user
        fprintf(['>> Creating response structures for the region >' regionTags{tt} '<\n']);
        clear responseStructCellArray % minimizing memory footprint across loops
        
        % obtain the response structures for all sessions and runs
        [responseStructCellArray] = fmriBFDM_LoadResponseStructCellArray(regionTags{tt}, responseDataDir);
        
        % calculate the hex MD5 hash for the responseCellArray
        responseStructCellArrayHash{tt} = DataHash(responseStructCellArray);
        
        % Set path to the responseStructCache and save it using the MD5 hash name
        responseStructCacheFileName=fullfile(responseDataDir, responseStructCacheDir, [regionTags{tt} '_' responseStructCellArrayHash{tt} '.mat']);
        save(responseStructCacheFileName,'responseStructCellArray','-v7.3');
        fprintf(['Saved the responseStruct with hash ID ' responseStructCellArrayHash{tt} '\n']);
    end % loop over regions
    
    % Dump the hash list to the console so it can be copied into the code
    fprintf('\n');
    fprintf('responseStruct hash block\n');
    fprintf('********************************\n');
    for tt=1:length(regionTags)
        fprintf([responseStructCellArrayHash{tt} '\n']);
    end
    fprintf('********************************\n');
    fprintf('\n');
    
end % check if we are to make responseStructs


%% Make the packetCellArray, if requested
if strcmp (packetCacheBehavior,'make');
    for tt = 1:length(regionTags)
        
        % Load the responseStructs
        fprintf('>> Loading cached responseStruct\n');
        responseStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, responseStructCacheDir, [regionTags{tt} '_' responseStructCellArrayHash{tt} '.mat']);
        load(responseStructCacheFileName);
        
        % assemble the stimulus and response structures into packets
        [packetCellArray] = fmriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray );
        
        % Remove any packets with attention task hit rate below 60%
        [packetCellArray] = fmriBDFM_FilterPacketCellArrayByPerformance(packetCellArray,0.6);
        
        % Derive the HRF from the attention events for each packet, and store it in
        % packetCellArray{}.response.metaData.fourierFitToAttentionEvents.[values,timebase]
        [packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray);
        
        % calculate the hex MD5 hash for the packetCellArray
        packetCellArrayHash{tt} = DataHash(packetCellArray);
        
        % Set path to the packetCache and save it using the MD5 hash name
        packetCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, packetCacheDir, [regionTags{tt} '_' packetCellArrayHash{tt} '.mat']);
        save(packetCacheFileName,'packetCellArray','-v7.3');
        fprintf(['Saved the packetCellArray with hash ID ' packetCellArrayHash{tt} '\n']);
        
    end % loop over regions
    
    % Dump the hash list to the console so it can be copied into the code
    fprintf('\n');
    fprintf('packetCellArray hash block\n');
    fprintf('********************************\n');
    for tt=1:length(regionTags)
        fprintf([packetCellArrayHash{tt} '\n']);
    end
    fprintf('********************************\n');
    fprintf('\n');
    
end % check if we are to make packets


%% Make the kernelStruct for each subject, if requested
if strcmp (kernelCacheBehavior,'makeFrom7TData');
    fprintf('>> Making the kernelStruct for each subject\n');
    
    % identify which packetCellArrayHash corresponds to the kernelRegion
    hashIDX=find(strcmp(regionTags,kernelRegion));
    
    % load the packetCellArray to be used for kernel definition
    packetCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, packetCacheDir,  [kernelRegion '_' packetCellArrayHash{hashIDX} '.mat']);
    load(packetCacheFileName);
    
    % Create an average HRF for each subject across all runs
    [hrfKernelStructCellArray] = fmriBDFN_CreateSubjectAverageHRFs(packetCellArray);
    
    % calculate the hex MD5 hash for the hrfKernelStructCellArray
    kernelStructCellArrayHash = DataHash(hrfKernelStructCellArray);
    
    % Set path to the packetCache and save it using the MD5 hash name
    kernelStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, kernelStructCacheDir, [kernelRegion '_' kernelStructCellArrayHash '.mat']);
    save(kernelStructCacheFileName,'hrfKernelStructCellArray','-v7.3');
    fprintf(['Saved the kerneStructCellArray with hash ID ' kernelStructCellArrayHash '\n']);
    
end % Check if kernelStruct generation is requested

if strcmp (kernelCacheBehavior,'makeFromMaxMel');
    fprintf('>> Making the kernelStruct for each subject\n');
    
    subjectNames={'HERO_asb1','HERO_gka1'};
    kernelHash={'be80e5482dfcf5e173c8d732ea5193c6','8e7166a99929c0aedda505fd9f9b665c'};
    crossProtocolKernelDir=fullfile('/Users', userName, 'Dropbox-Aguirre-Brainard-Lab/Team Documents/Cross-Protocol Subjects/HERO_kernelStructCache');
    
    for ss=1:length(subjectNames)
        kernelStructFileName=fullfile(crossProtocolKernelDir,[subjectNames{ss} '_hrf_' kernelHash{ss} '.mat' ]);
        load(kernelStructFileName);
        hrfKernelStructCellArray{ss}=kernelStruct;
    end
    
    % calculate the hex MD5 hash for the hrfKernelStructCellArray
    kernelStructCellArrayHash = DataHash(hrfKernelStructCellArray);
    
    % Set path to the packetCache and save it using the MD5 hash name
    kernelStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, kernelStructCacheDir, ['MaxMelKernels_' kernelStructCellArrayHash '.mat']);
    save(kernelStructCacheFileName,'hrfKernelStructCellArray','-v7.3');
    fprintf(['Saved the kerneStructCellArray with hash ID ' kernelStructCellArrayHash '\n']);
    
end % Check if kernelStruct generation is requested


%% Perform the analysis, if requested
if strcmp (resultCacheBehavior,'make');
    % Load the kernelStruct
    kernelStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, kernelStructCacheDir, [kernelRegion '_' kernelStructCellArrayHash '.mat']);
    load(kernelStructCacheFileName);
    
    % Perform the cross-validation for the full xValRegion
    fprintf(['>> Performing model comparison \n']);
    hashIDX=find(strcmp(xValRegion,regionTags));
    packetCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, packetCacheDir, [xValRegion '_' packetCellArrayHash{hashIDX} '.mat']);
    load(packetCacheFileName);
    
    % Perform cross-validated model comparison
    fmriBDFM_CalculateCrossValFits(packetCellArray, hrfKernelStructCellArray);
    
    % Loop over regions to be analyzed
    for tt = 1:length(regionTags)
        fprintf(['>> Analyzing region >' regionTags{tt} '<\n']);
        
        % Load the packet for this region
        packetCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, packetCacheDir, [regionTags{tt} '_' packetCellArrayHash{tt} '.mat']);
        load(packetCacheFileName);
        
        % Model and remove the attention events from the responses in each packet
        [packetCellArray] = fmriBDFM_RegressAttentionEventsFromPacketCellArray(packetCellArray, hrfKernelStructCellArray);
        
        % Fit the IAMP model to the average responses for each subject, modulation
        % direction, and stimulus order
        [fitResultsStructAvgResponseCellArray, plotHandles] = fmriBDFM_FitAverageResponsePackets(packetCellArray, hrfKernelStructCellArray);        
        fullResults(:,:,:,tt)=fitResultsStructAvgResponseCellArray;
        
        % Plot and save the TimeSeries
        for ss=1:length(plotHandles)
            fmriBDFM_suptitle(plotHandles(ss),['TimeSeries for S' strtrim(num2str(ss)) ', ROI-' regionTags{tt}]);
            plotFileName=fullfile(dropboxAnalysisDir, packetCacheDir, resultsStructCacheDir, ['TimeSeries_S' strtrim(num2str(ss)) '_ROI-' regionTags{tt} '_' packetCellArrayHash{tt} '.pdf']);
            saveas(plotHandles(ss), plotFileName, 'pdf');
            close(plotHandles(ss));
        end
        
        % calculate the hex MD5 hash for the fitResultsStructAvgResponseCellArray
        resultsStructCellArrayHash = DataHash(fitResultsStructAvgResponseCellArray);
        
        % Save the fitResultsStructAvgResponseCellArray
        resultsStructCacheFileName=fullfile(dropboxAnalysisDir, packetCacheDir, resultsStructCacheDir, [regionTags{tt} '_' packetCellArrayHash{tt} '.mat']);
        save(resultsStructCacheFileName,'fitResultsStructAvgResponseCellArray','-v7.3');
        
        % Plot and save the TTFs
        plotHandles = fmriBDFM_PlotTTFs(fitResultsStructAvgResponseCellArray);
        for ss=1:length(plotHandles)
            fmriBDFM_suptitle(plotHandles(ss),['TTFs for S' strtrim(num2str(ss)) ', ROI-' regionTags{tt}]);
            plotFileName=fullfile(dropboxAnalysisDir, packetCacheDir, resultsStructCacheDir, ['TTFs_S' strtrim(num2str(ss)) '_ROI-' regionTags{tt} '_' packetCellArrayHash{tt} '.pdf']);
            saveas(plotHandles(ss), plotFileName, 'pdf');
            close(plotHandles(ss));
        end
        
        % Derive the peak frequency and amplitude by modulation
        % direction for this eccentricity
        [peakFreqArray,peakAmpArray]=fmriBDFM_DerivePeakAmpFreq(fitResultsStructAvgResponseCellArray);

        peakFreqCellArray{tt}=peakFreqArray;
        peakAmpCellArray{tt}=peakAmpArray;
                
        % Plot the carry-over matrices
        plotHandles = fmriBDFM_AnalyzeCarryOverEffects(fitResultsStructAvgResponseCellArray);
        for ss=1:length(plotHandles)
            fmriBDFM_suptitle(plotHandles(ss),['CarryOver for S' strtrim(num2str(ss)) ', ROI-' regionTags{tt}]);
            plotFileName=fullfile(dropboxAnalysisDir, packetCacheDir, resultsStructCacheDir, ['CarryOver_S' strtrim(num2str(ss)) '_ROI-' regionTags{tt} '_' packetCellArrayHash{tt} '.pdf']);
            saveas(plotHandles(ss), plotFileName, 'pdf');
            close(plotHandles(ss));
        end
        
    end % loop over regions
    
    % Plot the responses by eccentricity
    fmriBDFM_PlotAmpFreqByEccen(peakFreqCellArray,peakAmpCellArray);
    
end % Check if analysis is requested



