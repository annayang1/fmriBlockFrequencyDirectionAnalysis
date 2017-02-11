function fmriBlockFrequencyDirectionAnalysisLocalHook
%
% For use with the ToolboxToolbox.  Copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "Template" from the filename
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('* Running fmriBlockFrequencyDirectionAnalysisLocalHook...');

%% Set preferences

% Find the project directory, add it to the path, save this as a
%  pref, and then make this the current directory
projectDir = fullfile(tbLocateProject('fmriBlockFrequencyDirectionAnalysis'));
addpath(genpath(projectDir));
setpref('fmriBlockFrequencyDirectionAnalysis', 'projectDir', projectDir);
cd(projectDir);


% Mount the cluster
%  use sshfs to mount the cluster to a defined mount point.
%  Sometimes a spontaneous sshfs disconnection causes the mount point
%  to become inaccessible from the file system and causes the system to
%  hang. These steps are designed to reset the ssfhfs system to resolve
%  this problem prior to connecting. IT WILL NUKE ALL RUNNING SSHFS JOBS.

%system('pkill -9 sshfs');
%system('umount -f ~/ccnCluster');
%system('sshfs -p 22 aguirre@chead:/data/jag/ ~/ccnCluster -oauto_cache,reconnect,defer_permissions,noappledouble,negative_vncache,volname=ccnCluster');
