function [ packetCellArray ] = fmriBDFM_CreateCarryOverStimTypes( packetCellArray )
% function [ packetCellArray ] = fmriBDFM_CreateCarryOverStimTypes( packetCellArray )

nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

for ss=1:nSubjects
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            
            % Handle the stimLabels being either strings or numbers
            if ischar(thePacket.stimulus.metaData.stimLabels{1})
                uniqueStimLabels=unique(thePacket.stimulus.metaData.stimLabels);
            end
            if isnumeric(thePacket.stimulus.metaData.stimLabels{1})
                uniqueStimLabels=unique(cell2mat(thePacket.stimulus.metaData.stimLabels));
                uniqueStimLabels=cellfun(@num2str, num2cell(uniqueStimLabels), 'UniformOutput', false);
            end
            
            % Generate the carry-over stimLabels
            newStimLabels=cell(1);
            labelCounter=1;
            for uu=1:length(uniqueStimLabels) % prior stimulus
                for vv=1:length(uniqueStimLabels) % current stimulus
                    newStimLabels{labelCounter}=[uniqueStimLabels{uu} '_x_' uniqueStimLabels{vv}];
                    labelCounter=labelCounter+1;
                end
            end
            
            % Generate the carry-over stimTypes
            stimTypes=thePacket.stimulus.metaData.stimTypes;
            priorStimLabel=uniqueStimLabels{1};
            for ii=1:length(stimTypes)
                currentStimLabel=uniqueStimLabels{stimTypes(ii)};
                carryOverLabel=[priorStimLabel '_x_' currentStimLabel];
                newStimTypes(ii)=find(strcmp(newStimLabels,carryOverLabel));
                priorStimLabel=currentStimLabel;
            end
            
            % Put the new labels and types into thePacket
            thePacket.stimulus.metaData.stimLabels=newStimLabels;
            thePacket.stimulus.metaData.stimTypes=newStimTypes';
            
            % put the modified packet back into the cell arrray
            packetCellArray{ss,rr}=thePacket;
            
        end % the packet is not empty
    end % loop over runs
end % loop over subjects

end % function