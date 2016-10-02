function [kernelStruct] = mriBFDM_FitFourierBasis( thePacket, msecsToModel, deltaTmsecsToModel, frequenciesToModel )
% function [ packetCellArrayOut ] = mriBFDM_DeriveFourierHRF( packetCellArrayIn )
%
%  frequenciesToModel - The number of Fourier components to have in the
%    model fit. This includes the zeroeth (DC) frequency component.
%
%

% create the fourier set matrix
fourierSetStructure.timebase = ...
    linspace(0,msecsToModel-deltaTmsecsToModel,msecsToModel);
componentIndex = 1;
fourierSetStructure.values(1,:) = ...
    fourierSetStructure.timebase*0+1; % Create DC component
componentIndex = componentIndex+1;

% loop through the requested harmonics (frequencies / 2)
for i = 1:ceil(frequenciesToModel/2)
    % Create sine for the harmonic
    fourierSetStructure.values(componentIndex,:) = ...
        sin(fourierSetStructure.timebase/msecsToModel*2*pi*i);
    componentIndex = componentIndex+1;
    % Create cosine for the harmonic
    fourierSetStructure.values(componentIndex,:) = ...
        cos(fourierSetStructure.timebase/msecsToModel*2*pi*i);
    componentIndex = componentIndex+1;
end

% trim the set down to the requested number of frequencies
fourierSetStructure.values=fourierSetStructure.values(1:frequenciesToModel,:);

% build the attentionEventPacket for fitting
attentionEventPacket.response.timebase=thePacket.response.timebase;
attentionEventPacket.response.values=thePacket.response.values;
attentionEventPacket.kernel=[];
attentionEventPacket.metaData=[];

% the stimulus values are built first as the vector of attention events
attentionEventPacket.stimulus.timebase=thePacket.stimulus.timebase;
impulseAttentionEvents=zeros(1,length(thePacket.stimulus.timebase));
impulseAttentionEvents(thePacket.stimulus.metaData.eventTimesArray)=1;
attentionEventPacket.stimulus.values = ...
    repmat(impulseAttentionEvents,frequenciesToModel,1);

% convolve the rows of the attentionEventPacket.stimulus.values by each of
% the rows of the fourierSet
for ii=1:frequenciesToModel
    % convolve
    valuesRowConv = conv(attentionEventPacket.stimulus.values(ii,:), ...
        fourierSetStructure.values(ii,:),'full');
    % cut off extra conv values
    attentionEventPacket.stimulus.values(ii,:) = ...
        valuesRowConv(1:length(attentionEventPacket.stimulus.timebase));  
end % loop through rows of the Fourier Set

% mean center the component that models the zeroeth frequency events.
attentionEventPacket.stimulus.values(1,:) = ...
    attentionEventPacket.stimulus.values(1,:) - ...
    mean(attentionEventPacket.stimulus.values(1,:));

% instantiate a model object that will be used for fitting
temporalFit = tfeIAMP('verbosity','none');

% set up the default properties of the fit
paramLockMatrix = []; % unused
defaultParamsInfo.nInstances = frequenciesToModel;

% VALIDATION
% copy and downsample one of the Fourier components into the
%  values field. See if it can recover it.

% attentionEventPacket.response.values=rand(1,336)*0;
% resampledTimeSeries = ...
%     resample(timeseries(attentionEventPacket.stimulus.values(2,:),attentionEventPacket.stimulus.timebase),...
%     attentionEventPacket.response.timebase);
% attentionEventPacket.response.values=attentionEventPacket.response.values+...
% squeeze(resampledTimeSeries.Data)';
% resampledTimeSeries = ...
%     resample(timeseries(attentionEventPacket.stimulus.values(1,:),attentionEventPacket.stimulus.timebase),...
%     attentionEventPacket.response.timebase);
% attentionEventPacket.response.values=attentionEventPacket.response.values+...
% squeeze(resampledTimeSeries.Data)'*.5;
% attentionEventPacket.response.values=attentionEventPacket.response.values-...
%     mean(attentionEventPacket.response.values);

% Derive the Fourier set fit
[paramsFit,~,~] = ...
            temporalFit.fitResponse(attentionEventPacket,...
            'defaultParamsInfo', defaultParamsInfo, ...
            'paramLockMatrix',paramLockMatrix, ...
            'searchMethod','linearRegression');

% Recover the modeled response and place into a kernel struct.
kernelStruct.timebase = ...
    linspace(0,msecsToModel-deltaTmsecsToModel,msecsToModel/deltaTmsecsToModel);

% Resample the fourierSetStructure to the timebase of the kernelStruct
resampledFourierSetStructure = ...
    temporalFit.resampleTimebase(fourierSetStructure,kernelStruct.timebase);

% Multiply the amplitude values of the parameter fit by the elements of the
% resampled Fourier Set
kernelStruct.values=resampledFourierSetStructure.values'*paramsFit.paramMainMatrix;

% close the temporalFit object
clear temporalFit
end

