function [paramStruct,fval]= fitNeuralParams(stimMatrix,t,paramLockMatrix,data,paramStruct)
      
% set options      
options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','active-set');

% grab neural parameters
prmVec0 = paramStruct.paramMainMatrix;

f = @(prmVec)forwardModelObjectiveFunction(stimMatrix,t,data,prmVec,paramStruct);

% set bounds
vlb = paramStruct.vlb;

vub = paramStruct.vub;

% make parameter matrix into vector so can set equality constraints
prmVec0 = prmVec0(:);
vlb = vlb(:);
vub = vub(:);

Aeq = paramLockMatrix;
beq = zeros([size(paramLockMatrix,1) 1]);

% fit parameters will also come out in a vector
[paramVec, fval] = fmincon(f,prmVec0,[],[],Aeq,beq,vlb,vub,[],options);

% we are fitting amplitudes for now
paramVec = reshape(paramVec,[size(paramStruct.paramMainMatrix,1) length(paramVec)./size(paramStruct.paramMainMatrix,1)]);
paramStruct.paramMainMatrix = paramVec;

gribble = 1;