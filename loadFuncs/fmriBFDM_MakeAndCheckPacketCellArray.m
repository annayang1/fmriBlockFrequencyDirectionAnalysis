function [ packetCellArray ] = fmriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray )
% function [ packetCellArray ] = fmriBFDM_MakeAndCheckPacketCellArray( stimStructCellArray, responseStructCellArray )
%
% Receives the stimulus and response structs and assembles them into
% packets


% Check that the dimensions of the stim and response structs are dimension
% compatible
if ~isequal(size(stimStructCellArray),size(responseStructCellArray))
    error('The stim and response structs do not have the same dimensions.');
end

% Pre-allocate the packetCellArray
packetCellArray=cell(size(stimStructCellArray));

% Assemble the stim and response structs into a packet cell array. As we
% loop, check to see if the metaData is compatible in the stim and
% response.
for ss=1:size(stimStructCellArray,2)
    for rr=1:size(stimStructCellArray{1,ss},2)
        % Get the stim and response struct for this session and run
        stimStruct=stimStructCellArray{1,ss}{rr};
        responseStruct=responseStructCellArray{1,ss}{rr};
        
        % error if the stim or response struct are not both empty or both
        % filled
        if ~isequal(isempty(stimStruct),isempty(responseStruct))
            errorString=['A response or stim struct is missing for ss ' strtrim(num2str(ss)) ', run ' strtrim(num2str(rr))];
            error(errorString);
        end % check for compatibility of empty/notempty of stim and response
        
        % if the stim/response structs are empty, make the packet empty
        % too, otherwise proceed
        if isempty(stimStruct)
            packetCellArray{ss,rr}=[];
        else
            % Check for compatibility of stimulus / response metaData
            if ~(isequal(stimStruct.metaData.sessionObserver,responseStruct.metaData.sessionObserver) && ...
                    isequal(stimStruct.metaData.sessionDate,responseStruct.metaData.sessionDate) && ...
                    isequal(stimStruct.metaData.stimulusOrderAorB,responseStruct.metaData.stimulusOrderAorB) && ...
                    isequal(stimStruct.metaData.modulationDirection,responseStruct.metaData.modulationDirection))
                errorString=['Stim/response metaData incompatible for ss ' strtrim(num2str(ss)) ', run ' strtrim(num2str(rr))];
                error(errorString);
            end % check for metaData compatibility
            packetCellArray{ss,rr}.stimulus=stimStruct;
            packetCellArray{ss,rr}.response=responseStruct;
            packetCellArray{ss,rr}.metaData=[];
            packetCellArray{ss,rr}.kernel=[];
        end % empty / not empty structs
    end % Loop over runs
end % Loop over subjects / sessions


end

