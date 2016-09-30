function [stimStructCellAray] = mriBFDM_LoadResponseStructCellArray(userName)
% function [stimStructCellAray] = mriBFDM_LoadResponseStructCellArray()
%
%

% Set Cluster path used to load the response data files
clusterDataDir=fullfile('/Users', userName, 'ccnClusterPseudo/MELA/');

% Define the response file session directories
responseSessDirs = {...
    'MOUNT_SINAI/HERO_asb1/041416' ...
    'MOUNT_SINAI/HERO_asb1/041516' ...
    'MOUNT_SINAI/HERO_gka1/041416' ...
    'MOUNT_SINAI/HERO_gka1/041516' ...
    };

responseSessDirs = {'MOUNT_SINAI/HERO_asb1/041416'};

% Define which sessions we'd like to merge
whichSessionsToMerge = {[1 2], [3 4]};
whichSessionsToMerge = {[1]};

for ss = 1:length(stimulusSessDirs)
    
    % Extract some information about this session
    tmp = strsplit(stimulusSessDirs{ss}, '/');
    runParams.sessionType = tmp{1};
    runParams.sessionObserver = tmp{2};
    runParams.sessionDate = tmp{3};
    
    % Display some useful information
    fprintf('>> Processing <strong>%s</strong> | <strong>%s</strong> | <strong>%s</strong>\n', runParams.sessionType, runParams.sessionObserver, runParams.sessionDate);
        
    % Make the packets
    runParams.packetType       = 'fMRI';
    runParams.stimulusDir       = fullfile(dropboxDataDir, stimulusSessDirs{ss});
    runParams.responseDir       = fullfile(dropboxAnalysisDir, stimulusSessDirs{ss});
    nRuns = length(listdir(fullfile(runParams.stimulusDir, 'session*', 'wdrf.tf.nii.gz'), 'files'));
    
    % Iterate over runs
    for ii = 1:nRuns;
        fprintf('\t* Run <strong>%g</strong> / <strong>%g</strong>\n', ii, nRuns);
        % Set up some parameters
        runParams.runNum           = ii;
        runParams.stimulusFile     = fullfile(runParams.stimulusDir, 'MatFiles', [runParams.sessionObserver '-' runParams.sessionType '-' num2str(ii, '%02.f') '.mat']);
        runParams.responseStructFile     = fullfile(runParams.responseDir, 'MatFiles', [runParams.sessionObserver '-' runParams.sessionType '-' num2str(ii, '%02.f') '.mat']);

        % Get the stimulus structure
        [runParams.stimValues,runParams.stimTimeBase,runParams.stimMetaData] = mriBlockFrequencyDirectionMakeStimStruct(runParams);
        
        % Get the response structure
%        [runParams.responseValues,runParams.responseTimeBase,runParams.responseMetaData] = mriBlockFrequencyDirectionMLoadResponseStruct(runParams);

        runPackets{ss, ii} = makePacket(runParams);
    end
    fprintf('\n');
end

%% Merge sessions
NSessionsMerged = length(whichSessionsToMerge);
for mm = 1:NSessionsMerged
    mergeIdx = whichSessionsToMerge{mm};
    mergedPacket = {runPackets{mergeIdx, :}};
    mergedPacket = mergedPacket(~cellfun('isempty', mergedPacket));
    mergedPackets{mm} = mergedPacket;
end