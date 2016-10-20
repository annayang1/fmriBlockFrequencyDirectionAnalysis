function fmriBlockFrequencyDirectionAnalysisLocalHookTemplate
% fmriBlockFrequencyDirectionAnalysisLocalHookTemplate
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUse({'fmriBlockFrequencyDirectionAnalysis'}) to set up for
% this project.  You then edit your local copy to match your local machine.
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running fmriBlockFrequencyDirectionAnalysis local hook\n');

%% Set preferences

% Obtain the Dropbox path
[~, userID] = system('whoami');
userID = strtrim(userID);
switch userID
    case {'melanopsin' 'pupillab'}
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
    case 'connectome'
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/TOME_data/'];
    otherwise
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
end

addpath(genpath(['/Users/' userID '/Documents/MATLAB/Analysis/fmriBlockFrequencyDirectionAnalysis']));

% Mount the cluster
%  use sshfs to mount the cluster to a defined mount point.
%  Sometimes a spontaneous sshfs disconnection causes the mount point
%  to become inaccessible from the file system and causes the system to
%  hang. These steps are designed to reset the ssfhfs system to resolve
%  this problem prior to connecting. IT WILL NUKE ALL RUNNING SSHFS JOBS.

system('pkill -9 sshfs');
system('umount -f ~/ccnCluster');
system('sshfs -p 22 aguirre@chead:/data/jag/ ~/ccnCluster -oauto_cache,reconnect,defer_permissions,noappledouble,negative_vncache,volname=ccnCluster');
