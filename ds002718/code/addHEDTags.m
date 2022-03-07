%% Script to add HED tags to the datsets
%% Author: Dung Truong

% path to data folder
path2data = '/data/projects/BIDSfiles/wakeman-henson-data/ds117forbids';
% path to field map that map event fields to their prepared HED tags (see
% wakeman-henson-tags.tsv for a human-readable version
fMap = '/data/projects/BIDSfiles/wakeman-henson-data/matlab/wh_eeglabcodes/fMap.mat';

if ~exist('pop_tageeg','file'), error('You must install the HEDTools plugin'); end

for isubj=2:19
    if isubj < 10
        subjfilename  = ['ds000117_sub00', num2str(isubj), '.set'];
        foldfername = ['sub00', num2str(isubj)];
    else
        subjfilename  = ['ds000117_sub0', num2str(isubj), '.set'];
        foldfername = ['sub0', num2str(isubj)];
    end
    path2set = fullfile(path2data, foldfername,'SET', subjfilename);
    EEG = pop_loadset('filepath', path2set, 'loadmode', 'info');
    EEG = pop_tageeg(EEG, 'baseMap', fMap, 'UseGui', false, 'EventFieldsToIgnore', {'face_type','event_type','event_order','time_dist','trial_dist','value'});
    pop_saveset(EEG, 'filename', subjfilename, 'filepath', fullfile(path2data, foldfername, 'SET'));     
end
