function [responseStructCellAray] = fmriBFDM_LoadResponseStructCellArray(regionTag, clusterDataDir)
% function [responseStructCellAray] = fmriBFDM_LoadResponseStructCellArray(userName)
%
%

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

switch regionTag
    case 'V1_0-30'
        areasFileName='mh.areas.func.vol.nii.gz';
        eccFileName='mh.ecc.func.vol.nii.gz';
        areasIndex=1; % This indexes area V1
        eccRange=[0 30];
    case 'V1_0-2'
        areasFileName='mh.areas.func.vol.nii.gz';
        eccFileName='mh.ecc.func.vol.nii.gz';
        areasIndex=1; % This indexes area V1
        eccRange=[0 2];
    case 'V1_2-8'
        areasFileName='mh.areas.func.vol.nii.gz';
        eccFileName='mh.ecc.func.vol.nii.gz';
        areasIndex=1; % This indexes area V1
        eccRange=[2 8];
    case 'V1_8-17'
        areasFileName='mh.areas.func.vol.nii.gz';
        eccFileName='mh.ecc.func.vol.nii.gz';
        areasIndex=1; % This indexes area V1
        eccRange=[8 17];
    case 'V1_17-30'
        areasFileName='mh.areas.func.vol.nii.gz';
        eccFileName='mh.ecc.func.vol.nii.gz';
        areasIndex=1; % This indexes area V1
        eccRange=[17 30];
    case 'LGN'
        areasFileName='mh.LGN.func.vol.nii.gz';
        eccFileName=[];
        areasIndex=1; % This indexes the LGN
        eccRange=[];
    otherwise
        error('That is not a regionTag that I know');
end

for ss = 1:length(responseSessDirs)
    
    % Extract some information about this session and put it into the
    % params variable that will be passed to MakeStrimStruct
    tmp = strsplit(responseSessDirs{ss}, '/');
    makeResponseStructParams.sessionObserver = tmp{2};
    makeResponseStructParams.sessionDate = tmp{3};
    makeResponseStructParams.packetType       = 'fMRI';
    makeResponseStructParams.responseDir       = fullfile(clusterDataDir, responseSessDirs{ss});
    makeResponseStructParams.regionTag = regionTag;
    
    runDirectoryList=listdir(fullfile(makeResponseStructParams.responseDir, 'Series*'), 'dirs');
    nRuns=length(runDirectoryList);
    
    % Display some useful information
    fprintf('>> Processing <strong>%s</strong> | <strong>%s</strong>\n', makeResponseStructParams.sessionObserver, makeResponseStructParams.sessionDate);
    
    % Iterate over runs
    for ii = 1:nRuns;
        fprintf('\t* Run <strong>%g</strong> / <strong>%g</strong>\n', ii, nRuns);
        % Further define the params
        makeResponseStructParams.runNum           = ii;
        makeResponseStructParams.responseFile = fullfile(makeResponseStructParams.responseDir, runDirectoryList(ii), responseFileName);
        makeResponseStructParams.areasFile    = fullfile(makeResponseStructParams.responseDir, runDirectoryList(ii), areasFileName);
        if ~isempty(eccFileName)
            makeResponseStructParams.eccFile    = fullfile(makeResponseStructParams.responseDir, runDirectoryList(ii), eccFileName);
        else
            makeResponseStructParams.eccFile    = [];
        end
        makeResponseStructParams.eccRange = eccRange;
        makeResponseStructParams.areaIndex = areasIndex;
        
        % Identify if this is stim order A or B from the runDirectory name
        tmp = strsplit(runDirectoryList{ii},'_');
        makeResponseStructParams.stimulusOrderAorB=tmp{end-1};
        
        % Grab some stimulus information from the file name
        tmp = strsplit(runDirectoryList{ii}, '_');
        makeResponseStructParams.scanNumber=char(tmp(2));
        makeResponseStructParams.modulationDirection=char(tmp(7));
        makeResponseStructParams.blockOrder=char(tmp(8));
        
        % Handle the idiosyncratic naming convention for the L-M modulation
        if strcmp(makeResponseStructParams.modulationDirection,'L')
            makeResponseStructParams.modulationDirection='L-M';
        end
        
        % Convert the file names from cell arrays to strings
        makeResponseStructParams.responseFile=makeResponseStructParams.responseFile{1};
        makeResponseStructParams.areasFile=makeResponseStructParams.areasFile{1};
        if ~isempty(eccFileName)
            makeResponseStructParams.eccFile=makeResponseStructParams.eccFile{1};
        else
            makeResponseStructParams.eccFile=[];
        end
        
        % Make the response structure
        [preMergeResponseStructCellArray{ss, ii}.values, ...
            preMergeResponseStructCellArray{ss, ii}.timebase, ...
            preMergeResponseStructCellArray{ss, ii}.metaData] = fmriBFDM_MakeResponseStruct(makeResponseStructParams);
        
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

