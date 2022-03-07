% Wakeman-Henson data EEG extraction from FIF files to be saved into BIDS
% format.
%
% Channel locatons are extracted and saved without modification. For use in EEGLAB is recomended to 
%  1) Rotate the nose direction to match the +Y axes. For this use: EEG = pop_chanedit(EEG,'nosedir','+Y');
%     This line is commented below
%  2) Recompute the center of the electrode coordinates
%     For this use: EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');
%     This line is commented below
%
% Authors: Ramon Martinez-Cancino, SCCN, 2019
%          Arnaud Delorme, SCCN, 2019
%          Dung Truong, SCCN, 2019
%
% Copyright (C) 2019  Ramon Martinez-Cancino,INC, SCCN
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
% script folder, this must be updated to the files on your enviroment.
clear;                                      % clearing all is recommended to avoid variable not being erased between calls
currentPath = fileparts( which('wh_extracteeg_BIDS') );
path2code = currentPath;

% path2data = fullfile(currentPath, 'ds117'); % Arno's path
path2data      = '/data/projects/WakemanHensonData/r00_rawdata/rawdata_unzip'; % Path to  the original unzipped data files

% path2stim = fullfile(currentPath, 'face_images');
path2stim      = '/data/projects/WakemanHensonData/r00_rawdata/ds117_R0.1.1_metadata/stimuli/meg';

% path2save = fullfile(currentPath, 'ds117forbids'); % Arno's path
path2save = fullfile(fileparts(fileparts(currentPath)), 'ds117forbids');

dInfo;                              % load dataset information (datInfo)
[ALLEEG, EEG, CURRENTSET] = eeglab; % start EEGLAB

if ~exist(path2data,'dir'), error('Data folder not found, edit script to indicate data location'); end
if ~exist(path2save,'dir'), mkdir(path2save); end % check if folders exist
if ~exist('ft_read_data','file'), error('You must install the File-IO plugin'); end

% Copy stimulus file (This can be done with command 'dir' but there may be tons of hidden files, then we'll need more code to filter out this files)
files1 = dir(fullfile(path2stim,'f*.bmp'));
files2 = dir(fullfile(path2stim,'s*.bmp'));
files3 = dir(fullfile(path2stim,'u*.bmp'));
allstimfiles = [files1 ;files2 ;files3];
mkdir(fullfile(fileparts(fileparts(currentPath)), 'faces_images'));
for i = 1:length(allstimfiles)
    copyfile(fullfile(allstimfiles(i).folder, allstimfiles(i).name),fullfile(fileparts(fileparts(currentPath)), 'faces_images'));
end


% Extract EEG data from the FIF file and importing it to EEGLAB
for isubj = 2:length(datInfo)    % Loop accross subjects (Subject 0001 was taken out of the analysis)
    ALLEEG = []; CURRENTSET = 0; % Initializing/clearing variables for each subject in the loop
    
    for irun = 1:6            % Loop accross runs
        
        % Step 1: Importing data with FileIO
        EEG = pop_fileio(fullfile(path2data, datInfo(isubj).name,'MEG',['run_0' num2str(irun) '_raw.fif']));
        
        % Step 2: Selecting EEG data and event (STI101) channels
        % EEG channels 1-60 are EEG, as are 65-70, but channels 61-64 are actually HEOG, VEOG and two floating channels (EKG). 
        EEG = pop_select(EEG, 'channel', {'EEG001' 'EEG002' 'EEG003' 'EEG004' 'EEG005' 'EEG006' 'EEG007' 'EEG008' 'EEG009' 'EEG010' 'EEG011' 'EEG012' 'EEG013' 'EEG014' 'EEG015'...
                                          'EEG016' 'EEG017' 'EEG018' 'EEG019' 'EEG020' 'EEG021' 'EEG022' 'EEG023' 'EEG024' 'EEG025' 'EEG026' 'EEG027' 'EEG028' 'EEG029' 'EEG030'...
                                          'EEG031' 'EEG032' 'EEG033' 'EEG034' 'EEG035' 'EEG036' 'EEG037' 'EEG038' 'EEG039' 'EEG040' 'EEG041' 'EEG042' 'EEG043' 'EEG044' 'EEG045'...
                                          'EEG046' 'EEG047' 'EEG048' 'EEG049' 'EEG050' 'EEG051' 'EEG052' 'EEG053' 'EEG054' 'EEG055' 'EEG056' 'EEG057' 'EEG058' 'EEG059' 'EEG060'...
                                          'EEG061' 'EEG062' 'EEG063' 'EEG064' 'EEG065' 'EEG066' 'EEG067' 'EEG068' 'EEG069' 'EEG070' 'EEG071' 'EEG072' 'EEG073' 'EEG074' 'STI101'});
        % Correcting channel type to be EEG
       for ichan = 1:length(EEG.chanlocs)-1
           EEG = pop_chanedit(EEG,'changefield',{ichan  'type' 'EEG'});
       end
       
       % Correcting reference label
       EEG.ref = 'nose';
                                      
        % Step 3: Adding fiducials and rotating montage. Note:The channel location from this points were extracted from the FIF 
        % files (see below) and written in the dInfo file. The reason is that File-IO does not import these coordinates.
        EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'LPA' [] [] datInfo(isubj).fid(1,1) datInfo(isubj).fid(1,2) datInfo(isubj).fid(1,3) [] [] [] 'FID' '' [] 0 [] []});
        EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'Nz'  [] [] datInfo(isubj).fid(2,1) datInfo(isubj).fid(2,2) datInfo(isubj).fid(2,3) [] [] [] 'FID' '' [] 0 [] []});
        EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'RPA' [] [] datInfo(isubj).fid(3,1) datInfo(isubj).fid(3,2) datInfo(isubj).fid(3,3) [] [] [] 'FID' '' [] 0 [] []});
        %EEG = pop_chanedit(EEG,'nosedir','+Y'); % Not used here
        
        % Changing Channel types and removing channel locations for channels 61-64 (Raw data types are incorrect)
        EEG = pop_chanedit(EEG,'changefield',{61  'type' 'HEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
        EEG = pop_chanedit(EEG,'changefield',{62  'type' 'VEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});  
        EEG = pop_chanedit(EEG,'changefield',{63  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});  
        EEG = pop_chanedit(EEG,'changefield',{64  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});                                                   
                                                             
        % Recomputing head center  % Not used here
        % EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');
        
        % Step 4: Re-import events from STI101 channel (the original ones are incorect)
        EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen',datInfo(isubj).edgelenval,'delevent','on','delchan','off','oper','double(bitand(int32(X),31))'); % first 5 bits
        
        % Step 5: Cleaning artefactual events (keep only valid event codes)
        EEG = pop_selectevent( EEG, 'type',[5 6 7 13 14 15 17 18 19] ,'deleteevents','on'); 
        if isubj== 3 && irun == 4, EEG = pop_editeventvals(EEG, 'delete', 24); end
        
        % Step 6: Importing info from image presented into event structure
        EEG = pop_importevent(EEG, 'skipline', 1, 'fields', {'stimtype' 'nested' 'ignore' 'imgcode' 'imgfile' }, 'event', fullfile(path2data, datInfo(isubj).name,'MEG',[datInfo(isubj).name '_' num2str(irun) '.txt']));
 
        % Step 7:Importing  button press info
        EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen',datInfo(isubj).edgelenval, 'delevent','off','oper','double(bitand(int32(X),8160))'); % bits 5 to 13
        
        % Step 8: Event manipulation (not necessary in standard analysis)
        % Here fixing overlapped buttonpressing events
        event4352 = find([EEG.event.type]==4352); % overlapping of events 256 and 4096
        if ~isempty(event4352)
            for ievt =1: length(event4352)
                event4352_1 = find([EEG.event.type]==4352,1);
                if EEG.event(event4352_1 - 1).type == 256 || EEG.event(event4352_1 - 1).type == 4096
                    EEG = pop_editeventvals( EEG,'changefield', { event4352_1 'type'  4352-EEG.event(event4352_1 -1).type});
                else
                    EEG = pop_editeventvals( EEG, 'delete', event4352_1);
                end
            end
        end
        
        % Renaming, adding and removing event fields
        % EEG = pop_editeventfield( EEG, 'rename', 'imgcode->stim_file'); % Note: Code kept for further analysis. DO NOT USE
         EEG = pop_editeventfield( EEG, 'rename', 'imgfile->stim_file');
         EEG = pop_editeventfield( EEG,'rename', 'ignore->event_type');
         EEG = pop_editeventfield( EEG, 'nested', [], 'stimtype',[],'imgcode', [], 'value', [EEG.event.type]);
        
        % Renaming button press events in field event type 
        EEG = pop_selectevent( EEG, 'type',256, 'renametype',datInfo(isubj).event256 ,'deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',4096,'renametype',datInfo(isubj).event4096,'deleteevents','off');
        
        % Updating  field stimtype for the button press event
        indx1 = find(strncmpi({EEG.event.type}, 'right', 5));
        indx2 = find(strncmpi({EEG.event.type}, 'left', 4));
        allindx = sort([indx1, indx2]);
        
        for i = 1 :length(allindx)
            EEG = pop_editeventvals( EEG,'changefield', { allindx(i) 'event_type' 'button_press'});
        end
        
        % Rename face presentation events
        EEG = pop_selectevent( EEG, 'type',5,'renametype','famous_new','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',6,'renametype','famous_second_early','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',7,'renametype','famous_second_late','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',13,'renametype','unfamiliar_new','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',14,'renametype','unfamiliar_second_early','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',15,'renametype','unfamiliar_second_late','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',17,'renametype','scrambled_new','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',18,'renametype','scrambled_second_early','deleteevents','off');
        EEG = pop_selectevent( EEG, 'type',19,'renametype','scrambled_second_late','deleteevents','off');
        
        % Time and trial distance between face presentation events
        EEG = pop_editeventfield( EEG, 'trial_dist','0');
        EEG = pop_editeventfield( EEG, 'time_dist' ,'0');
        myevents   = [ 5 6 7 13 14 15 17 18 19];
        allevents  = [EEG.event.value]; % Retreiving events indices
        indx2insert = find(ismember(allevents, myevents));
        
        for ievents = 1 : length(indx2insert)
            if ~ismember(EEG.event(indx2insert(ievents)).value,[5 13 17]) && ievents ~= 1
                tmpeventlist =  indx2insert(1:ievents-1);
                tmpevent = EEG.event(indx2insert(ievents)).stim_file;
                allprev_event = find(~cellfun(@isempty,strfind({EEG.event(tmpeventlist).stim_file},tmpevent)));
                
                if ~isempty(allprev_event)
                    timedist  =  (EEG.event(indx2insert(ievents)).latency - EEG.event(tmpeventlist(allprev_event(end))).latency)/EEG.srate;
                    trialdist =   (length(tmpeventlist)-allprev_event(end)) + 1;
                    
                    EEG = pop_editeventvals(EEG,'changefield',{indx2insert(ievents) 'trial_dist' trialdist});
                    EEG = pop_editeventvals(EEG,'changefield',{indx2insert(ievents) 'time_dist'  timedist});
                end
            end
        end
        
        % Presentation order
        EEG = pop_editeventfield( EEG, 'event_order','0');
        uniquefaces = unique({EEG.event.stim_file});
        for ievents =1: length(uniquefaces)
            evtindx = find(~cellfun(@isempty,strfind({EEG.event.stim_file},uniquefaces(ievents))));
            if ~isempty(evtindx)
                for i=1:length(evtindx)
                EEG = pop_editeventvals(EEG,'changefield',{evtindx(i) 'event_order' i});
                end
            end
        end
        
        % Face type
        EEG = pop_editeventfield( EEG, 'face_type','n/a');
        for i=1:length(allevents)
            % Type of face
            if strncmpi(EEG.event(i).type, 'unfamiliar',10)
                evttmp = 'unfamiliar';
            elseif strncmpi(EEG.event(i).type, 'famous',6)
                evttmp = 'famous';
            elseif strncmpi(EEG.event(i).type, 'scrambled',9)
                evttmp = 'scrambled';    
            else
                evttmp = 'n/a';    
            end
                
            EEG = pop_editeventvals(EEG,'changefield',{i 'face_type' evttmp}); 
        end
        
        % Updating path to stimulus        
        for ievt =1: length(indx2insert)
            [path2stim,filename, fileext] = fileparts(EEG.event(indx2insert(ievt)).stim_file);
            EEG = pop_editeventvals(EEG,'changefield',{indx2insert(ievt) 'stim_file' fullfile('faces_images', [filename, fileext])});
        end
        
        % Step 9: Correcting event latencies (events have a shift of 34 ms)
        EEG = pop_adjustevents(EEG,'addms',34);
        
        % Step 10: Replacing original imported channels
        % Note: This is a very unusual step that should not be done lightly. The reason here is because
        %       of the original channels were wrongly labeled at the time of the experiment
        EEG = pop_chanedit(EEG, 'rplurchanloc',1);
        
        % Step 11: Resample the data to 250Hz
        EEG = pop_resample( EEG, 250);
        
        % Step 12: Creating subject folder if does not exist and save dataset
        if ~exist(fullfile(path2save,datInfo(isubj).name), 'dir'), mkdir(path2save,datInfo(isubj).name); end
        
        % Step 13: storing run into ALLEEG
        ALLEEG = eeg_store(ALLEEG, EEG);
    end
    
    % Concatenate the six runs
    EEG = pop_mergeset(ALLEEG, [1 2 3 4 5 6], 0);
        
    % Remove/rename event fields
    EEG = pop_editeventfield( EEG, 'urevent',[], 'duration', []);
    
    % Filling up empty fields for event 'boundary' (not necessary in standard analysis)
    boundindx = find(strcmp({EEG.event.type},'boundary'));
    fields2change = {'value','trial_dist', 'time_dist', 'event_order'};
    for ievt =1:length(boundindx)
        for ifield = 1: length(fields2change)
         EEG = pop_editeventvals(EEG,'changefield',{boundindx(ievt) fields2change{ifield} 0}); 
        end
        EEG = pop_editeventvals(EEG,'changefield',{boundindx(ievt) 'event_type' 'n/a'}); 
        EEG = pop_editeventvals(EEG,'changefield',{boundindx(ievt) 'face_type'  'n/a'}); 
    end
    
    % Filling up empty fields for event 'stim_file' (not necessary in standard analysis) 
    for iEvent = 1:length(EEG.event)
        if isempty(EEG.event(iEvent).stim_file)
            EEG.event(iEvent).stim_file = 'n/a';
        else
            EEG.event(iEvent).stim_file = EEG.event(iEvent).stim_file(14:end);
        end
    end
        
    % Saving data
    % Saving concatenated runs using.set format
    if ~exist(fullfile(path2save,datInfo(isubj).name, 'SET'),'dir'), mkdir(fullfile(path2save,datInfo(isubj).name), 'SET'); end
    pop_saveset(EEG, 'filename', ['ds000117_' datInfo(isubj).name '.set'], 'filepath', fullfile(path2save,datInfo(isubj).name, 'SET'));
    
    % Saving MRI anat
    if ~exist(fullfile(path2save,datInfo(isubj).name, 'anat'),'dir'), mkdir(fullfile(path2save,datInfo(isubj).name), 'anat'); end 
    copyfile(fullfile(path2data,datInfo(isubj).name, 'anatomy', 'highres001.nii.gz'),fullfile(path2save,datInfo(isubj).name, 'anat', ['anat_' datInfo(isubj).name '.nii.gz']),'f')
end
