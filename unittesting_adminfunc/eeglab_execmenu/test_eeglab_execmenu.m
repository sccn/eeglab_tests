function test_eeglab_execmenu
% Menu callbacks execute in the base workspace, including history replay.
folder = fileparts(mfilename('fullpath'));
eeglab_test_workspace(fileread(fullfile(folder, 'eeglab_execmenu_commands.m')));
end
