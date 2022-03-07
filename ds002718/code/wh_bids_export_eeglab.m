% Script to import Wakeman-Henson data to BIDS
% Authors: Ramon Martinez-Cancino SCCN 2020
%          Dung Truong, SCCN 2020
%          Arnaud Delorme, 2020
%
%% Raw data files path
% -----------------------------------------------------|
clear
currentPath = fileparts( which('wh_extracteeg_BIDS') );
path2code = currentPath;

% path2data = fullfile(currentPath, 'ds117forbids'); % Arno's path
path2data = fullfile(fileparts(fileparts(currentPath)), 'ds117forbids');

% path2bids = fullfile(currentPath, 'bids_export'); % Arno's path
path2bids      = fullfile(fileparts(fileparts(currentPath)), 'bids_export_05202020');

% path2stimfiles = fullfile(currentPath, 'faces_images'); % Arno's path
path2stimfiles = fullfile(fileparts(fileparts(currentPath)), 'faces_images');

subjindx  = 2:19; % range of subject to export
for isubj=1:length(subjindx)
    subjfilename  = sprintf('sub%3.3d/SET/ds000117_sub%3.3d.set', subjindx(isubj), subjindx(isubj));
    
    subject(isubj).file = {fullfile(path2data, subjfilename)};
    subject(isubj).session = 1;
    subject(isubj).run     = 1;
    subject(isubj).anat    = fullfile(path2data, sprintf('sub%3.3d/anat/anat_sub%3.3d.nii.gz', subjindx(isubj), subjindx(isubj)));
end

% Anatomical MRI files
anattype     = 'T1w';
defacedflag  = 'on';

% Creating array of stimulus files
tmpfiles = dir(path2stimfiles);
stimfiles = [{tmpfiles(3:end).folder}' {tmpfiles(3:end).name}'];

%% Code Files used to preprocess and import to BIDS
% -----------------------------------------------------|
codefiles = { fullfile(path2code, 'wh_extracteeg_BIDS.m') ...
              fullfile(path2code, 'wh_bids_export_eeglab.m') ...
              fullfile(path2code, 'dInfo.m') ...
              fullfile(path2code, 'addHEDTags.m') ...
              fullfile(path2code, 'wakeman-henson-tags.tsv') ...             
              fullfile(path2code, 'fMap.mat')};
         
%% General information for dataset_description.json file
% -----------------------------------------------------|
generalInfo.Name = 'Face processing EEG dataset for EEGLAB';
generalInfo.BIDSVersion = 'v1.2.0';
generalInfo.License = 'CC0';
generalInfo.Authors = {'Daniel G. Wakeman', 'Richard N Henson'};
generalInfo.ReferencesAndLinks = {'Wakeman, D., Henson, R. A multi-subject, multi-modal human neuroimaging dataset. Sci Data 2, 150001 (2015). https://doi.org/10.1038/sdata.2015.1'};
generalInfo.Funding = {'This work was supported by the UK Medical Research Council (MC_A060_5PR10) and Elekta Ltd.'};

%% Participant information for participants.tsv file
% -------------------------------------------------|   
%% Subjects missing information in WH BIDS 1.0.0: [4 6 7 13 19]
pInfo = {'participant_id'    'age'  'gender';...
         'sub-002'            31    'M';
         'sub-003'            25    'M';
         'sub-004'            'n/a' 'n/a'   
         'sub-005'            30    'M';
         'sub-006'            'n/a' 'n/a' 
         'sub-007'            'n/a' 'n/a' 
         'sub-008'            23    'F';
         'sub-009'            26    'M';
         'sub-010'            31    'F';
         'sub-011'            26    'M';
         'sub-012'            29    'M';
         'sub-013'            'n/a' 'n/a' 
         'sub-014'            26    'F';
         'sub-015'            23    'M';
         'sub-016'            24    'F';
         'sub-017'            24    'F';
         'sub-018'            25    'F';
         'sub-019'            'n/a' 'n/a' };
     
pInfo = pInfo([1 subjindx], :);
     
%% Participant column description for participants.json file
% ---------------------------------------------------------|
% participant_id
pInfoDesc.participant_id.LongName    = 'Participant identifier';
pInfoDesc.participant_id.Description = 'Unique subject identifier';

% sex
pInfoDesc.gender.Description = 'Sex of the subject';
pInfoDesc.gender.Levels.M    = 'male';
pInfoDesc.gender.Levels.F    = 'female';

% age
pInfoDesc.age.Description = 'Age of the subject';
pInfoDesc.age.Units       = 'years';

     
%% Event column description for xxx-events.json file
% ---------------------------------------------------
eInfo = {'HED'         'usertags'; 
         'onset'       'latency';
         'trial_type'  'type';
         'stim_file'   'stim_file';
         'face_type'   'face_type';
         'value'       'value';
         'event_type'  'event_type';
         'event_order' 'event_order';
         'trial_dist'  'trial_dist';
         'time_dist'   'time_dist'};
     
 
% HED Tags
eInfoDesc.HED.Description = 'Hierarchical Event Descriptor';

% Event Onset     
eInfoDesc.onset.Description = 'Event onset';
eInfoDesc.onset.Units       = 'miliseconds';

% Stim Files
eInfoDesc.stim_file.Description = 'File of image presented. For button pressing events no info is provided (designated by [])';

% Trial type
eInfoDesc.trial_type.Description                       = 'Comprenhesive information of stimulus and responses corresponding to each event';
eInfoDesc.trial_type.Levels.famous_new                 = 'Initial presentation of famous face';
eInfoDesc.trial_type.Levels.famous_second_early        = 'Immediate repeated  presentation of famous face';
eInfoDesc.trial_type.Levels.famous_second_late          = 'Delayed repeated  presentation of famous face';

eInfoDesc.trial_type.Levels.scrambled_new              = 'Initial presentation of scrambled face';
eInfoDesc.trial_type.Levels.scrambled_second_early     = 'Immediate repeated  presentation of scrambled face';
eInfoDesc.trial_type.Levels.scrambled_second_late      = 'Delayed repeated  presentation of scrambled face';

eInfoDesc.trial_type.Levels.unfamiliar_new             = 'Initial presentation of unfamiliar face';
eInfoDesc.trial_type.Levels.unfamiliar_second_early    = 'Immediate repeated  presentation of unfamiliar face';
eInfoDesc.trial_type.Levels.unfamiliar_second_late     = 'Delayed repeated  presentation of unfamiliar face';

eInfoDesc.trial_type.Levels.right_nonsym               = 'Right button press to indicated less symmetric face';
eInfoDesc.trial_type.Levels.left_sym                   = 'Left button press to indicated more symmetric face';
eInfoDesc.trial_type.Levels.left_nonsym                = 'Left button press to indicated less symmetric face';
eInfoDesc.trial_type.Levels.right_sym                  = 'Right button press to indicated more symmetric face';
eInfoDesc.trial_type.Levels.boundary                   = 'The boundary mark of each run as the run data was merged';


% Event types
eInfoDesc.event_type.Description            = 'Represent the two more general types events in the experiment';
eInfoDesc.event_type.Levels.button_press    = 'Button pressing indicating level of symmetry of face presented'; 
eInfoDesc.event_type.Levels.faces           = 'Face image presentation';

% Face Type
eInfoDesc.face_type.Description         = 'Type of face presented';
eInfoDesc.trial_type.Levels.famous      = 'Famous or fami;iar face';
eInfoDesc.trial_type.Levels.unfamiliar  = 'Unfamiliar face';
eInfoDesc.trial_type.Levels.scrambled   = 'Scrambled face';

% Event values
eInfoDesc.value.Description = 'Numerical event marker';
eInfoDesc.value.Levels.x5   = 'Initial presentation of famous face';
eInfoDesc.value.Levels.x6   = 'Immediate repeated  presentation of famous face';
eInfoDesc.value.Levels.x7   = 'Delayed repeated  presentation of famous face';

eInfoDesc.value.Levels.x13   = 'Initial presentation of unfamiliar face';
eInfoDesc.value.Levels.x14   = 'Immediate repeated  presentation of unfamiliar face';
eInfoDesc.value.Levels.x15   = 'Delayed repeated  presentation of unfamiliar face';

eInfoDesc.value.Levels.x17   = 'Initial presentation of scrambled face';
eInfoDesc.value.Levels.x18   = 'Immediate repeated  presentation of scrambled face';
eInfoDesc.value.Levels.x19   = 'Delayed repeated  presentation of scrambled face';

eInfoDesc.value.Levels.x256    = 'Left button press';
eInfoDesc.value.Levels.x4096   = 'Right button press';

% Event Order     
eInfoDesc.event_order.Description = 'Each image is presented twice. This index represent the order of presentation of each image';
eInfoDesc.event_order.Levels.x0   = 'Not an image. This may be a button press or a boundary';
eInfoDesc.event_order.Levels.x1   = 'First presentation of the image';
eInfoDesc.event_order.Levels.x2   = 'Second presentation of the image'; 

% Trial distance    
eInfoDesc.trial_dist.Description = 'Distance in trial units since the previous presentation of the same image';
eInfoDesc.trial_dist.Units       = 'Trials';

% Time distance     
eInfoDesc.time_dist.Description = 'Time since the previous presentation of the same image';
eInfoDesc.time_dist.Units       = 'seconds';

%% Content for README file
% ------------------------
README = [ 'Multi-subject, multi-modal (sMRI+EEG) neuroimaging dataset' 10 ...
           'on face processing. Original data described at https://www.nature.com/articles/sdata20151' 10 ...
           'This is repackaged version of the EEG data in EEGLAB format. The data has gone through' 10 ...
           'minimal preprocessing including (see wh_extracteeg_BIDS.m):' 10 ...
           '- Ignoring fMRI and MEG data (sMRI preserved for EEG source localization)' 10 ...
           '- Extracting EEG channels out of the MEG/EEG fif data' 10 ...
           '- Adding fiducials' 10 ...
           '- Renaming EOG and EKG channels' 10 ...
           '- Extracting events from event channel' 10 ...
           '- Removing spurious events 5, 6, 7, 13, 14, 15, 17, 18 and 19' 10 ...
           '- Removing spurious event 24 for subject 3 run 4' 10 ...
           '- Renaming events taking into account button assigned to each subject' 10 ...
           '- Correcting event latencies (events have a shift of 34 ms)' 10 ...
           '- Resampling data to 250 Hz (this is a step that is done because' 10 ...
           '  this dataset is used as tutorial for EEGLAB and need to be lightweight' 10 ...
           '- Merging run 1 to 6' 10 ...
           '- Removing event fields urevent and duration ' 10 ...
           '- Filling up empty fields for events boundary and stim_file.' 10 ...
           '- Saving as EEGLAB .set format' 10 10  ...
           'Ramon Martinez, Dung Truong, Scott Makeig, Arnaud Delorme (UCSD, La Jolla, CA, USA)' 10 ...
           ];

%% Content for CHANGES file
% ------------------------
CHANGES = sprintf([ 'Revision history for Face Recognition experiment by Wakeman-Henson\n\n' ...
                    'version 1.0 beta - March 2020\n' ...
                    ' - Initial release of EEG data in this experiment for EEGLAB education purposes \n' ...
                    '\n' ...
                    ]);

% Task information for xxxx-eeg.json file
% ---------------------------------------|
tInfo.TaskName = 'FaceRecognition';
tInfo.TaskDescription = sprintf(['Subjects viewed stimuli on a screen during six, 7.5 minute runs. The stimuli were photographs ' ...
                                 'of either a famous face (known to most of British or a scrambled face, and appeared for a random duration between 800 and 1,000 ms. ' ...
                                 'Subjects were instructed to fixate centrally throughout the experiment. To ensure attention to each ' ...
                                 'stimulus, participants were asked to press one of two keys with either their left or right index ' ...
                                 'finger (assignment counter-balanced across participants). Their key-press was based on how symmetric ' ...
                                 'they regarded each image: pressing one or the other key depending whether they thought the image was ' ...
                                 '''more'' or ''less symmetric'' than average.']);
tInfo.InstitutionAddress = '15 Chaucer Road, Cambridge, UK';
tInfo.InstitutionName = 'MRC Cognition & Brain Sciences Unit';

% EEG-specific fields
% ---------------------------------------|
tInfo.EEGReference = 'nose';
tInfo.EEGGround = 'left collar bone';
tInfo.SamplingFrequency = 1100;
tInfo.PowerLineFrequency = 50; 
tInfo.SoftwareFilters = struct('LowPassFilter', struct ('cutoff', '350 (Hz)'));
tInfo.EEGPlacementScheme = 'extended 10-10% system';
tInfo.CapManufacturer = 'Easycap';
tInfo.EEGChannelCount = 70; 
tInfo.EOGChannelCount = 2; 
tInfo.RecordingType = 'continuous';

% call to the export function
% ---------------------------
bids_export(subject, 'targetdir', path2bids, 'eInfo', eInfo, 'taskName', tInfo.TaskName, 'gInfo', generalInfo, 'pInfo', pInfo, 'pInfoDesc', pInfoDesc, 'eInfoDesc', eInfoDesc, 'README', README, 'CHANGES', CHANGES,'tInfo', tInfo,'codefiles',codefiles,'defaced', defacedflag,'anattype', anattype, 'copydata', 1);
copyfile(path2stimfiles, fullfile(path2bids, 'stimuli'));
