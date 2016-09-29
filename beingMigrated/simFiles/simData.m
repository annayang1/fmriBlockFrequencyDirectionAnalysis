function [timeSeries,eventTimes,hrf] = simData(HRFdur,sampT,numTRs,numEvents,offTR,overlapTR,irrTR)

% Makes a simulated time-series of BOLD responses to events defined by the
% various inputs
%
%   Usage:
%   [timeSeries,eventTimes,hrf] = simData(HRFdur,sampT,numTRs,numEvents,offTR,overlapTR,irrTR)
%
%   Inputs:
%   HRFdur      = duration of the HRF window (msec) [default = 32000]
%   sampT       = TR (msec) [default = 1000]
%   numTRs      = number of TRs in the time-series [default = 1000]
%   numEvents   = number of stimulus events [default = 10]
%   offTR       = if = 1, shifts events to the middle of the TR [default = 0];
%   overlapTR   = if = N, duplicates the events, spaced apart by N TRs
%   irrTR       = if = 1, creates irregular event times, i.e. not evenly spaced [default = 0];
%
%   Written by Andrew S Bock Jul 2016

%% set defaults
if ~exist('HRFdur','var') || isempty(HRFdur)
    HRFdur = 32000; % HRF duration (seconds)
end
if ~exist('sampT','var') || isempty(sampT)
    sampT = 1000; % TR (msec)
end
if ~exist('numTRs','var') || isempty(numTRs)
    numTRs = 1000;
end
if ~exist('numEvents','var') || isempty(numEvents)
    numEvents = 10;
end
if ~exist('offTR','var') || isempty(offTR)
    offTR = 0; % offTR = 1 puts the events in the middle of the TR
end
if ~exist('overlapTR','var') || isempty(overlapTR)
    overlapTR = 0; % overlap = N duplicates the events, spaced apart by N TRs
end
if ~exist('irrTR','var') || isempty(irrTR)
    irrTR = 0; % irregular event times (i.e. not evenly spaced)
end
%% Create evenly spaced event times, starting on a TR
tcDur = sampT * numTRs; % total time-series duration (msec)
trTimes = 0:sampT:tcDur-sampT; % TR start times (msec)
eventSpace = size(trTimes,2)/numEvents; % even event spacing
eventTimes = trTimes( (eventSpace:eventSpace:size(trTimes,2)) - (eventSpace-1));
%% Adjust the event times based on various conditions
% shift events to middle of the TR
if offTR
    eventTimes = eventTimes +  sampT/2;
end
% Make the spacing 'irregular', i.e. not evenly spaced
if irrTR
    for i = 1:length(eventTimes)-1
        switch mod(i,4)
            case 0
                eventTimes(i) = eventTimes(i) + sampT*(eventSpace/(10));
            case 1
                eventTimes(i) = eventTimes(i) + sampT*(eventSpace/(5));
            case 2
                eventTimes(i) = eventTimes(i) + sampT*(eventSpace/(5/2));
            case 3
                eventTimes(i) = eventTimes(i) + sampT*(eventSpace/(5/4));
        end
    end
end
% create events that overlap within the HRF window (will double the number of events)
if overlapTR
    eventTimes = sort([eventTimes,eventTimes + overlapTR*sampT]);
end
%% Make the simulated time-series
hrf                     = doubleGammaHrf(1/sampT,[6 10],[1 1],1/6,HRFdur/sampT); % HRF TRs
tmpTC                   = zeros(tcDur,1);
tmpTC(eventTimes+1)     = 1; % add one for indexing
upTC                    = filter(hrf,1,tmpTC);
timeSeries              = resample(upTC,1,sampT);