function [responseStructCellAray] = mriBFDM_LoadResponseStructCellArray(userName)
% function [responseStructCellAray] = mriBFDM_LoadResponseStructCellArray(userName)
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

% Define the name of the response and areas file to load
responseFileName='wdrf.tf.nii.gz';
areasFileName='mh.areas.func.vol.nii.gz';
areasIndex=1; % This indexes area V1

for ss = 1:length(responseSessDirs)
    
    % Extract some information about this session and put it into the
    % params variable that will be passed to MakeStrimStruct
    tmp = strsplit(responseSessDirs{ss}, '/');
    makeResponseStructParams.sessionType = tmp{1};
    makeResponseStructParams.sessionObserver = tmp{2};
    makeResponseStructParams.sessionDate = tmp{3};
    makeResponseStructParams.packetType       = 'fMRI';
    makeResponseStructParams.responseDir       = fullfile(clusterDataDir, responseSessDirs{ss});
    
    runDirectoryList=listdir(fullfile(makeResponseStructParams.responseDir, 'Series*'), 'dirs');
    nRuns=length(runDirectoryList);
        
    % Display some useful information
    fprintf('>> Processing <strong>%s</strong> | <strong>%s</strong> | <strong>%s</strong>\n', makeResponseStructParams.sessionType, makeResponseStructParams.sessionObserver, makeResponseStructParams.sessionDate);

    nRuns=2;
    
    % Iterate over runs
    for ii = 1:nRuns;
        fprintf('\t* Run <strong>%g</strong> / <strong>%g</strong>\n', ii, nRuns);
        % Further define the params
        makeResponseStructParams.runNum           = ii;
        makeResponseStructParams.responseFile = fullfile(makeResponseStructParams.responseDir, runDirectoryList(ii), responseFileName);
        makeResponseStructParams.areasFile    = fullfile(makeResponseStructParams.responseDir, runDirectoryList(ii), areasFileName);

        % Convert the file names from cell arrays to strings
        makeResponseStructParams.responseFile=makeResponseStructParams.responseFile{1};
        makeResponseStructParams.areasFile=makeResponseStructParams.areasFile{1};
        makeResponseStructParams.areasIndex=1;
        
        % Make the response structure
        [preMergeResponseStructCellArray{ss, ii}.values, ...
         preMergeResponseStructCellArray{ss, ii}.timebase, ...
         preMergeResponseStructCellArray{ss, ii}.metaData] = mriBFDM_MakeResponseStruct(makeResponseStructParams);
        
    end
    fprintf('\n');
end

%% Merge sessions
NSessionsMerged = length(whichSessionsToMerge);
for mm = 1:NSessionsMerged
    mergeIdx = whichSessionsToMerge{mm};
    tempMerge = {preMergeResponseStructCellArray{mergeIdx, :}};
    tempMerge = tempMerge(~cellfun('isempty', tempMerge));
    responseStructCellAray{mm} = tempMerge;
end