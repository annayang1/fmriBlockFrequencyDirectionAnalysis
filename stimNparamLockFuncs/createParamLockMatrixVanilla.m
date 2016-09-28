function paramLockMatrix = createParamLockMatrixVanilla(uniqueStimValues,stimValuesInOrder,numParamTypes)

% function paramLockMatrix = createParamLockMatrixVanilla(uniqueStimValues,stimValuesInOrder)
%
% creates parameter locking matrix for the special (and frequently-used)
% case in which all runs with the same stimulus value get the same set of
% parameters
%
% inputs
% uniqueStimValues : all unique stimulus values (in this case, temporal
%                   frequency)
% stimValuesInOrder: order in which stimuli were presented
% numParamTypes    : number of unique parameter types (amplitude, tau2, etc.) 

% initialize the matrices
paramLockMatrixSubForCons1 = [];
paramLockMatrix = [];

% loop over unique stimulus values
for i = 1:length(uniqueStimValues)
    % for each value, find its positions
   stimToBeChained = find(stimValuesInOrder == uniqueStimValues(i)); 
   % loop over positions and daisy-chain linear equations
   for j = 1:length(stimToBeChained)-1
         constraintVec = zeros([1 length(stimValuesInOrder)]);
         constraintVec(stimToBeChained(j)) = 1;
         constraintVec(stimToBeChained(j+1)) = -1;
         paramLockMatrixSubForCons1(size(paramLockMatrixSubForCons1,1)+1,:) = constraintVec;         
    end
end

% if there are multiple unique parameter types, create an 'identity
% matrix'
paramLockMatrix = kron(eye(numParamTypes),paramLockMatrixSubForCons1);

gribble = 1;