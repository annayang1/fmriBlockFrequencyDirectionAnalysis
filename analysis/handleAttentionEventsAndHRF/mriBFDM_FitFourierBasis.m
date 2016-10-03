function [kernelStruct] = mriBFDM_FitFourierBasis( thePacket, msecsToModel, numFourierComponents )
% function [kernelStruct] = mriBFDM_FitFourierBasis( thePacket, msecsToModel, frequenciesToModel )
%
% Fits a Fourier basis set to the attention events specified in thePacket,
% and returns a kernelStruct that has an estimate of the average evoked
% response to the events.
%
% Arguments in:
%  - thePacket - the packet to be analyzed. In addition to the usual packet
%    stuff, must have the field thePacket.stimulus.metaData.eventTimesArray
%    defined.
%  - msecsToModel - the duration (in msecs) of the window over which the
%    Fourier basis set should model events.
%  - numFourierComponents - The number of Fourier components to have in the
%    model fit. This includes the zeroeth (DC) frequency component.
%
% Arguments out:
%  - kernelStruct - a structure that contains the timebase and values of
%    the mean evoked response estimated using the Fourier basis set.
%

% Create the stimulusStructure that contains the Fourier components
[stimulusStruct, fourierSetStructure] = ...
    makeFourierStimStruct( thePacket.stimulus.timebase, ...
    thePacket.stimulus.metaData.eventTimesArray, ...
    msecsToModel, numFourierComponents );

% build the attentionEventPacket for fitting
attentionEventPacket.stimulus=stimulusStruct;
attentionEventPacket.response.timebase=thePacket.response.timebase;
attentionEventPacket.response.values=thePacket.response.values;
attentionEventPacket.kernel=[];
attentionEventPacket.metaData=[];

% instantiate a model object that will be used for fitting
temporalFit = tfeIAMP('verbosity','none');

% set up the default properties of the fit
paramLockMatrix = []; % unused
defaultParamsInfo.nInstances = numFourierComponents;

% Derive the Fourier set fit
[paramsFit,~,~] = ...
    temporalFit.fitResponse(attentionEventPacket,...
    'defaultParamsInfo', defaultParamsInfo, ...
    'paramLockMatrix',paramLockMatrix, ...
    'searchMethod','linearRegression');

% Recover the modeled response and place into a kernel struct.
kernelStruct.timebase=fourierSetStructure.timebase;

% Multiply the amplitude values of the parameter fit by the elements of the
% Fourier Set
kernelStruct.values=(fourierSetStructure.values'*paramsFit.paramMainMatrix)';

% close the temporalFit object
clear temporalFit
end
