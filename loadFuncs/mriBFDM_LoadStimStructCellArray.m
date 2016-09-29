function [mergedPackets] = mriBFDM_LoadStimStructCellArray(userName)
% function [stimStructCellAray] = mriBFDM_LoadStimStructCellArray()
%
%


% Set Dropbox path used to load the stimulus specification files
dropboxDataDir = fullfile('/Users', userName, '/Dropbox (Aguirre-Brainard Lab)/MELA_data');

% Define the stimulus file session directories
stimulusSessDirs = {...
    'HCLV_Photo_7T/HERO_asb1/041416' ...
    'HCLV_Photo_7T/HERO_asb1/041516' ...
    'HCLV_Photo_7T/HERO_gka1/041416' ...
    'HCLV_Photo_7T/HERO_gka1/041516' ...
    };

% Define which sessions we'd like to merge
whichSessionsToMerge = {[1 2], [3 4]};

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
    nRuns = length(listdir(fullfile(runParams.stimulusDir, 'MatFiles', '*.mat'), 'files'));
    
    % Iterate over runs
    for ii = 1:nRuns;
        fprintf('\t* Run <strong>%g</strong> / <strong>%g</strong>\n', ii, nRuns);
        % Set up some parameters
        runParams.runNum           = ii;
        runParams.stimulusFile     = fullfile(runParams.stimulusDir, 'MatFiles', [runParams.sessionObserver '-' runParams.sessionType '-' num2str(ii, '%02.f') '.mat']);
%        runParams.responseStructFile     = fullfile(runParams.responseDir, 'MatFiles', [runParams.sessionObserver '-' runParams.sessionType '-' num2str(ii, '%02.f') '.mat']);

        % Get the stimulus structure
        [runParams.stimValues,runParams.stimTimeBase,runParams.stimMetaData] = mriBFDM_MakeStimStruct(runParams);
        
        % Get the response structure
%        [runParams.responseValues,runParams.responseTimeBase,runParams.responseMetaData] = mriBlockFrequencyDirectionMLoadResponseStruct(runParams);

        thePackets{ss, ii} = thePackets{ss,
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