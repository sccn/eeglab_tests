function limotest = limo_test_integration(studypath, outputdir)

% Integration test for 1st level and 2nd level analyses
% depends upon Wakeman and Henson dataset https://openneuro.org/datasets/ds002718/versions/1.0.2
% run the 'statndar' preprocessing pipeline then test 1st level integration
% between STUDY and LIMO, followed by 2nd level analyses from 1st level
% outputs
% 
% OUTPUT limotest is a cell array listing the (set of) tests performed as succesfull or failed
%
% tests std_limo with two different models (categorical only or categorical
%                and continuous variables)
%       limo_glm related functions: pop_limo call --> runs models using OLS (cat) 
%                                   and WLS (cat and cont) & compute 1st level contrasts
%       limo random effect related functions: runs 1 sample, 2 samples, and paired t-tests
%                                             regression, 1 way ANOVA, 1 way ANCOVA, 
%                                             Rep. measures ANOVA and contrasts
%                          + test different inputs betas/cons as array or file
%                          + test whole brain, channel 50 & vitual channel (a vector of different channels)
%       boostraps and tfce computed (101 iterations only)
%
% untested 1st level boostrap and tfce
%          1st level factorial
%          basic stats
%          plotting

if nargin < 1
    studypath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'ds002718');
end
if nargin < 2, outputdir = ''; end
[studypath, outputdir, cleanup] = limo_test_output(studypath, outputdir); %#ok<ASGLU>
failures = cell(1,9);
Model1_files = []; Model2_files = [];
list1 = []; list2 = [];
oldRandom = rng;
randomCleanup = onCleanup(@() rng(oldRandom)); %#ok<NASGU>
rng(0);
% start EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

% call BIDS tool BIDS
studyName = 'Face_detection';

[STUDY, ALLEEG] = pop_importbids(studypath,'bidsevent','on','bidschanloc','on',...
                  'studyName',studyName,'outputdir', outputdir, ...
                  'eventtype', 'trial_type');
ALLEEG          = pop_select( ALLEEG, 'nochannel',{'EEG061','EEG062','EEG063','EEG064'});
CURRENTSTUDY    = 1;
EEG             = ALLEEG;
CURRENTSET      = 1:length(EEG);
root            = fullfile(studypath, 'derivatives');

% Remove bad channels
% EEG = pop_clean_rawdata( EEG,'FlatlineCriterion',5,'ChannelCriterion',0.8,...
%     'LineNoiseCriterion',4,'Highpass',[0.25 0.75] ,...
%     'BurstCriterion','off','WindowCriterion','off','BurstRejection','off',...
%     'Distance','Euclidian','WindowCriterionTolerances','off' );
% 
% % Rereference using average reference
% EEG = pop_reref( EEG,[],'interpchan',[]);
% 
% % Run ICA and flag artifactual components using IClabel
% for s=1:size(EEG,2)
%     EEG(s) = pop_runica(EEG(s), 'icatype','picard','concatcond','on','options',{'pca',EEG(s).nbchan-1});
%     EEG(s) = pop_iclabel(EEG(s),'default');
%     EEG(s) = pop_icflag(EEG(s),[NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
%     EEG(s) = pop_subcomp(EEG(s), find(EEG(s).reject.gcompreject), 0);
% end
% 
% % clear data using ASR - just the bad epochs
% EEG = pop_clean_rawdata( EEG,'FlatlineCriterion','off','ChannelCriterion','off',...
%     'LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,...
%     'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian',...
%     'WindowCriterionTolerances',[-Inf 7] );

% Extract data epochs (no baseline removed)
EEG    = pop_epoch( EEG,{'famous_new','famous_second_early','famous_second_late', ...
         'scrambled_new','scrambled_second_early','scrambled_second_late','unfamiliar_new', ...
         'unfamiliar_second_early','unfamiliar_second_late'},[-0.5 1] ,'epochinfo','yes');
EEG    = eeg_checkset(EEG);
EEG    = pop_saveset(EEG, 'savemode', 'resave');
ALLEEG = EEG;

% update study & compute single trials
STUDY        = std_checkset(STUDY, ALLEEG);
[STUDY, EEG] = std_precomp(STUDY, EEG, {}, 'savetrials','on','interp','on','recompute','on',...
    'erp','on','erpparams', {'rmbase' [-200 0]}, 'spec','off', 'ersp','off','itc','off');
eeglab redraw

% add 3 groups
[STUDY.datasetinfo(1:6).group]   = deal('1');
[STUDY.datasetinfo(7:13).group]  = deal('2');
[STUDY.datasetinfo(14:18).group] = deal('3');


%% test std_limo and 1st level GLM
studyfullname = fullfile(outputdir, [ studyName '.study' ]);

tic
if exist(studyfullname,'file')
    [root,std_name,ext]=fileparts(studyfullname);
    cd(root); EEG = eeglab;
    %% load STUDY
    [STUDY, ALLEEG] = pop_loadstudy('filename', [std_name ext], 'filepath', root);
    % update to have 3 groups if not present
    [STUDY.datasetinfo(1:6).group ]= deal('1');
    [STUDY.datasetinfo(7:13).group ]= deal('2');
    [STUDY.datasetinfo(14:18).group ]= deal('3');

else
    error('study file nout found')
end

% ------------------------------------------------------------
%       LIMO TESTING STARTS HERE
% ------------------------------------------------------------

%% test std_limo and 1st level GLM

try
    % make categorical design & estimate with OLS
    STUDY = std_makedesign(STUDY, ALLEEG, 1, 'name','FaceRepetition','delfiles','off','defaultdesign','off',...
        'variable1','type','values1',{'famous_new','famous_second_early','famous_second_late','scrambled_new','scrambled_second_early','scrambled_second_late','unfamiliar_new','unfamiliar_second_early','unfamiliar_second_late'},...
        'vartype1','categorical','subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');

    % compute 1st model with OLS
    [STUDY, ~, Model1_files] = pop_limo(STUDY, ALLEEG, 'method','OLS','measure','daterp','timelim',[-50 650],'erase','on','splitreg','off','interaction','off','verbose','noGUI');
    contrast.LIMO_files      = Model1_files.mat; 
    contrast.mat             = [1 1 1 -1 -1 -1 0 0 0 0 ; 0 0 0 1 1 1 -1 -1 -1 0];
    confiles                 = limo_batch('contrast only',[],contrast,STUDY); 
    Model1_files.con         = confiles.con;
    list1 = limo_test_lists(Model1_files, STUDY, fullfile(outputdir, 'model1_lists'));
    clear confiles
    limotest{1} = 'categorical design + contrasts with OLS estimates successful';
catch err
    failures{1} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{1} = sprintf('categorical design + contrasts with OLS estimates failed \n%s',err.message);
end

try
    % make categorical+continuous design & estimate with WLS
    STUDY = std_makedesign(STUDY, ALLEEG, 2, 'name','Face_time','delfiles','off','defaultdesign','off',...
        'variable1','face_type','values1',{'famous','scrambled','unfamiliar'},'vartype1','categorical',...
        'variable2','time_dist','values2',[],'vartype2','continuous',...
        'subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');

    % compute 1st model with WLS
    [STUDY, ~, Model2_files] = pop_limo(STUDY, ALLEEG, 'method','WLS','measure','daterp','timelim',[-50 650],'erase','on','splitreg','on','interaction','off','verbose','noGUI');
    contrast.LIMO_files      = Model2_files.mat; 
    contrast.mat             = [0 0 0 -1 0 1];
    confiles                 = limo_batch('contrast only',[],contrast); % do not pass STUDY argument, should still figure it out
    Model2_files.con         = confiles.con;
    list2 = limo_test_lists(Model2_files, STUDY, fullfile(outputdir, 'model2_lists'));
    clear confiles
    limotest{2} = 'mixed design with WLS estimates + contrast successful';
catch err
    failures{2} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{2} = sprintf('mixed design with WLS estimates + contrast failed \n%s',err.message);
end

% Keep first level results for independently rerunning the second level cases.
preparationFile = fullfile(outputdir, 'first_level_results.mat');
save(preparationFile, 'STUDY', 'Model1_files', 'Model2_files', 'list1', 'list2', 'limotest', 'failures');
limotest = limo_test_second_level(preparationFile);
end
