%%
eeglab
eeglabp = fileparts(which('eeglab'));
tmpdata = rand(10,1000);
eeglab_execmenu('From ASCII/float file or MATLAB array', 'pop_importdata', { 'dataformat','array','nbchan',0,'data','tmpdata','srate',100 });
eeglab_execmenu('Save current dataset as', 'pop_saveset', { 'test.set' });
eeglab_execmenu('Dataset info', 'pop_editset', { 'subject', 'test2' });
eeglab_execmenu('Resave current dataset(s)', 'pop_saveset', { 'savemode' 'resave' });
eeglab_execmenu('Load existing dataset', 'pop_loadset', { fullfile(eeglabp, 'sample_data', 'eeglab_data.set') });
eeglab_execmenu('Event values', 'pop_editeventvals', { 'changefield',{1,'position',3} });
eeglab_execmenu('About this dataset', 'pop_comments', { strvcat('EEGLAB Tutorial Dataset','test') });
eeglab_execmenu('Channel locations', 'pop_chanedit', { 'lookup', fullfile(eeglabp, 'plugins', 'dipfit', 'standard_BEM', 'elec', 'standard_1005.elc') });
eeglab_execmenu('Change sampling rate', 'pop_resample', { 64 });

SAVEDCOM = ALLCOM;
for iCommand = length(SAVEDCOM):-1:1
    evalin('base', SAVEDCOM{iCommand});
end
