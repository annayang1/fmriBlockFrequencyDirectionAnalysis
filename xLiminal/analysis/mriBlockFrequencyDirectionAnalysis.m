%% mriBlockFrequencyDirectionAnalysis.m
%
% Program to run data analysis on functional MRI data collected in blocks
% of stimulation. Configured to operate upon the Mt. Sinai 7T dataset.

%% Code below here copied from Manuel's pupil analysis

% Housekeeping
clearvars; close all;

% Discover user name and set Dropbox path
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxDir = fullfile('/Users', userName, '/Dropbox (Aguirre-Brainard Lab)/MELA_data');
saveDir = fullfile('/Users', userName, '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis');

% Define the session directories
sessDirs = {...
    'MelanopsinMRMaxLMSCRF/HERO_asb1/060816'...
    'MelanopsinMRMaxLMSCRF/HERO_aso1/060116' ...
    'MelanopsinMRMaxLMSCRF/HERO_gka1/060616' ...
    'MelanopsinMRMaxLMSCRF/HERO_mxs1/062416' ...
    'MelanopsinMRMaxLMSCRF/HERO_mxs1/062816' ...
    'MelanopsinMRMaxMelCRF/HERO_asb1/060716' ...
    'MelanopsinMRMaxMelCRF/HERO_aso1/053116' ...
    'MelanopsinMRMaxMelCRF/HERO_gka1/060216' ...
    'MelanopsinMRMaxMelCRF/HERO_mxs1/060916' ...
    'MelanopsinMRMaxMelCRF/HERO_mxs1/061016'
    };

% Define which sessions we'd like to merge
whichSessionsToMerge = {[1], [2], [3], [4 5], [6], [7], [8], [9 10]};

% Set some parameters we need
normalizationTimeSecs = 0.1;
normalizationDurInd = normalizationTimeSecs*1000-1;
extractionTimeSecs = 13;
extractionDurInd = extractionTimeSecs*1000-1;

for ss = 1:length(sessDirs)
    % Clear some information
    Data_Per_Segment = [];
    uniqueCombos = [];
    allDataTmp = [];
    allIndicesTmp = [];
    
    % Extract some information about this session
    tmp = strsplit(sessDirs{ss}, '/');
    params.sessionType = tmp{1};
    params.sessionObserver = tmp{2};
    params.sessionDate = tmp{3};    
    
    % Display some useful information
    fprintf('>> Processing <strong>%s</strong> | <strong>%s</strong> | <strong>%s</strong>\n', params.sessionType, params.sessionObserver, params.sessionDate);
    
    % Determine some parameters
    switch params.sessionDate
        case {'053116' '060116' '060216'}
            params.acquisitionFreq      = 30;
        otherwise
            params.acquisitionFreq      = 60;
    end
    params.LiveTrackSamplingRate        = 60; % Hz
    params.ResamplingFineFreq           = 1000; % 1 msec
    params.BlinkWindowSample            = -50:50; % Samples surrounding the blink event
    params.TRDurSecs                    = 0.8;

    % Make the packets
    params.packetType       = 'pupil';
    params.sessionDir       = fullfile(dropboxDir, sessDirs{ss});
    NRuns = length(listdir(fullfile(params.sessionDir, 'MatFiles', '*.mat'), 'files'));
    
    % Iterate over runs
    for ii = 1:NRuns;
        fprintf('\t* Run <strong>%g</strong> / <strong>%g</strong>\n', ii, NRuns);
        % Set up some parameters
        params.runNum           = ii;
        params.stimulusFile     = fullfile(params.sessionDir, 'MatFiles', [params.sessionObserver '-' params.sessionType '-' num2str(ii, '%02.f') '.mat']);
        params.responseFile     = fullfile(params.sessionDir, 'EyeTrackingFiles', [params.sessionObserver '-' params.sessionType '-' num2str(ii, '%02.f') '.mat']);  
        [params.respValues params.respTimeBase] = loadPupilDataForPackets(params);
        [params.stimValues params.stimTimeBase params.stimMetaData] = makeStimStruct(params);
        packets{ss, ii} = makePacket(params);
     
        % Find the stimulus onsets so that we can align the data to it. We
        % do that by finding a [0 1] edge from a difference operator.
        tmp = sum(packets{ss, ii}.stimulus.values);
        tmp2 = diff(tmp);
        tmp2(tmp2 < 0) = 0;
        tmp2(tmp2 > 0) = 1;
        stimOnsets = strfind(tmp2, [0 1]);
        
        % Get the number of segments from the stimulus onsets
        NSegments = length(stimOnsets);
        t = (0:extractionDurInd)/1000;
        for jj = 1:length(stimOnsets)
            if (stimOnsets(jj)+extractionDurInd) <= length(packets{ss, ii}.response.values)
                Data_Per_Segment(:, jj) = (packets{ss, ii}.response.values(stimOnsets(jj):(stimOnsets(jj)+extractionDurInd)));
            else
                Data_Per_Segment(:, jj) = (packets{ss, ii}.response.values(stimOnsets(jj):end));
            end
        end
        
        % Normalize by the dead time
        for jj  = 1:NSegments
            Data_Per_Segment(:, jj) = (Data_Per_Segment(:, jj) - nanmean(Data_Per_Segment(1:normalizationDurInd, jj)))./nanmean(Data_Per_Segment(1:normalizationDurInd, jj));
        end
        allDataTmp = [allDataTmp Data_Per_Segment];
        
        % Extract information about the stimulus label
        % old line [uniqueCombos{ii}, ~, idx] = unique([packets{ss, ii}.stimulus.metaData.params.theDirections' packets{ss, ii}.stimulus.metaData.params.theContrastRelMaxIndices'], 'rows');
        % load the .mat file containing the stimulus information
        stimfile = matfile(fullfile(params.sessionDir, 'MatFiles', [params.sessionObserver '-' params.sessionType '-' num2str(ii, '%02.f') '.mat']));
        % had to create new variable to allow indexing into stimfileParams
        stimfileParams = stimfile.params
        % unchanged from before
        [uniqueCombos{ii}, ~, idx] = unique([stimfileParams.theDirections' stimfileParams.theContrastRelMaxIndices'], 'rows');
        allIndicesTmp = [allIndicesTmp idx];
    end
    
    % Make sure sure that in every run we have the same conditions
    for ii = 1:NRuns
        logTest(ii) = all(all(uniqueCombos{ii} == uniqueCombos{1}));
    end
    if all(logTest)
        uniqueCombos1 = uniqueCombos{1};
    else
        error('This session is heterogenous');
    end
    
    % Save out the data from this loop.
    allData{ss} = allDataTmp;
    allIndices{ss} = allIndicesTmp;
    fprintf('\n');
end

%% Fit model to the packets
% Insert code here. All packets from this analysis are now in packets{ss, ii}, 
% i.e. each session and run is one entry in that cell array. At this level,
% each packet is the entire time series, but we could plausibly also set it
% up differently.

%% Merge the sessions
NSessionsTotal = length(whichSessionsToMerge);
for mm = 1:NSessionsTotal
    thisIdx = whichSessionsToMerge{mm};
    % Merge data
    allDataMerged{mm} = [allData{thisIdx}];
    allIndicesMerged{mm} = [allIndices{thisIdx}];
    
    % Extract a label for the session
    strtmp = strsplit(sessDirs{thisIdx(1)}, '/');
    sessionLabels{mm} = [strtmp{1} '_' strtmp{2}];
    sessionType{mm} = strtmp{1};
    observerID{mm} = strtmp{2};
end

%% Plot the data
for mm = 1:NSessionsTotal
    NCombos = size(uniqueCombos1, 1);
    plotFig = figure;
    for jj = 1:NCombos
        subplot(1, NCombos, jj);
        data = allDataMerged{mm}(:, allIndicesMerged{mm} == jj);
        data_mean = nanmean(data, 2);
        data_sem = nanstd(data, [], 2)/sqrt(size(data, 2)); hold on;
        plot([t(1) t(end)], [0 0], '-k');
        shadedErrorBar(t, data_mean, data_sem);
        xlim([t(1) t(end)]);
        ylim([-0.5 0.5]);
        pbaspect([1 1 1]);
        xlabel('Time [s]');
        ylabel('Amplitude [%]');
        if uniqueCombos1(jj, 1) == 1
            title([num2str(100*packets{1}.stimulus.metaData.params.theContrastMax*packets{1}.stimulus.metaData.params.theContrastsPct(jj), '%g') '%'])
        else
            title('Attention task');
        end
    end
    adjustPlot(plotFig);
    
    % Save the plot. If the saving directory doesn't exist, create it.
    if ~exist(fullfile(saveDir, sessionType{mm}, observerID{mm}), 'dir')
       mkdir(fullfile(saveDir, sessionType{mm}, observerID{mm})); 
    end
    set(plotFig, 'PaperPosition', [0 0 13 3]);
    set(plotFig, 'PaperSize', [13 3]);
    saveas(plotFig, fullfile(saveDir, sessionType{mm}, observerID{mm}, [sessionLabels{mm} '.png']), 'png');
    close(plotFig);
end