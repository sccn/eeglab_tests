eeglab
tmpdata = rand(10,1000);
eeglab_execmenu('From ASCII/float file or MATLAB array', 'pop_importdata', { 'dataformat','array','nbchan',0,'data','tmpdata','srate',100 });
eeglab_execmenu('Save current dataset as', 'pop_saveset', { 'test.set' });

eeglabp = fileparts(which('eeglab'));
eeglab_execmenu('Load existing dataset', 'pop_loadset', { fullfile(eeglabp, 'sample_data', 'eeglab_data.set') });
eeglab_execmenu('Resave current dataset(s)', 'pop_saveset', { });
eeglab_execmenu('Change sampling rate', 'pop_resample', { 64 });

SAVEDCOM = ALLCOM;
for iCommand = length(SAVEDCOM):-1:1
    evalin('base', SAVEDCOM{iCommand});
end
