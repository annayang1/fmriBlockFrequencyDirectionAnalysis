function [values,TimeVectorFine] = loadFmriDataForPackets(params)
% [values,TimeVectorFine] = loadFmriDataForPackets(params)
%
% loads time series data



%% STIMULUS VALUES
Data_Stimulus = load(params.stimulusFile);

% Extract how many runs are needed
NTRsExpected = sum(Data_Stimulus.params.trialDuration)/params.TRDurSecs;

TimeVectorFine = 0:1:sum(Data_Stimulus.params.trialDuration)*1000-1;





% Path to local Dropbox
localDropboxDir = ['/Users/',strtrim(user_name),'/Dropbox-Aguirre-Brainard-Lab/'] ;

% Define a path to Time Series data
dirPathTimeSeries = [localDropboxDir 'MELA_analysis/HCLV_Photo_7T/mriTemporalFitting_data/' ...
                      subj_name '/' 'TimeSeries/'] ;

% load list of runs in order
tsFileNames = timeSeriesFileNamesGenerator(subj_name,session);

% Get Contents of Time Series Folder
timeSeriesDir = dir(dirPathTimeSeries);

% Get Cell containing names(only) by looping over
timeSeriesDirNames = {};

for i = 1:length(timeSeriesDir)
   tsFileName = timeSeriesDir(i).name ;
   if length(tsFileName)>15
       timeSeriesDirNames{length(timeSeriesDirNames)+1} = tsFileName ;
   end
end

% Initialize Matrices for Storing Times Series
avgTimeSeries = [] ;
avgTimeSeriesPrc = [];

% Note Stimulus type for future indexing
stimTypeArr = [] ;
runOrder = '' ;

for i = 1:length(tsFileNames)
    
    currentTSfileName = char(tsFileNames(i)) ;  % Current Time Series folder
    % Find Simulus type & store their positiong 
    if strfind(currentTSfileName,'LightFlux')
        stimTypeArr(length(stimTypeArr)+1) = 1 ;
    elseif strfind(currentTSfileName,'L_minus_M')
        stimTypeArr(length(stimTypeArr)+1) = 2 ;
    elseif strfind(currentTSfileName,'_S_')
        stimTypeArr(length(stimTypeArr)+1) = 3; 
    else
       stimType = [] ; 
    end
    
    % Find Run Order A -or- B & store their position
    if strfind(currentTSfileName,'_A_')
        runOrder(length(runOrder)+1) = 'A' ;
    elseif strfind(currentTSfileName,'_B_')
        runOrder(length(runOrder)+1) = 'B' ;
    else
       runOrderJunk = [] ; 
    end
    
    % Find all files containing file name wanted (As determined in the READ
    % ME file) -- Get their locations in the folder
    tsFilesLHRH = strfind(timeSeriesDirNames,currentTSfileName) ;
    locationsInTSfolder = find(~cellfun(@isempty,tsFilesLHRH)) ;    
%    display(num2str(length(locationsInTSfolder)));

    % Load Left Hemisphere Data, then Right Hemisphere Data
    LHtsStruct = load([dirPathTimeSeries char(timeSeriesDirNames(locationsInTSfolder(1)))]) ;
    RHtsStruct = load([dirPathTimeSeries char(timeSeriesDirNames(locationsInTSfolder(2)))]) ;
    LHts = LHtsStruct.avgTC ;
    RHts = RHtsStruct.avgTC ;
    
    % Mean of Left & Right Hemispheres
    avgTimeSeries(i,:) = (LHts+RHts)./2 ;
    avgTimeSeriesPrc(size(avgTimeSeriesPrc,1)+1,:) = ((avgTimeSeries(i,:) - mean(avgTimeSeries(i,:)))./mean(avgTimeSeries(i,:))).*100 ;
end
                  
gribble = 1;