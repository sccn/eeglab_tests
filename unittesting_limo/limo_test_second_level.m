function limotest = limo_test_second_level(preparationFile)
% Rerun second level integration cases from validated first level results.
prepared = load(preparationFile);
STUDY = prepared.STUDY;
Model1_files = prepared.Model1_files;
Model2_files = prepared.Model2_files;
list1 = prepared.list1;
list2 = prepared.list2;
limotest = prepared.limotest;
failures = prepared.failures;
oldFolder = pwd;
oldRandom = rng;
cleanup = onCleanup(@() restoreState(oldFolder, oldRandom)); %#ok<NASGU>
rng(0);
tic;

%% 2nd level analyses
% Every rerun gets fresh outputs, including its bootstrap files.
root = tempname(fileparts(preparationFile));
mkdir(root);
fprintf('Second level outputs retained in %s\n', root);
cd(root); mkdir('2nd_level_tests'); cd('2nd_level_tests');
channel_vector = [];
if ~isempty(list2)
    channel_vector = limo_best_electrodes(list2.mat);
    save('virtual_electrode','channel_vector');
elseif ~isempty(list1)
    channel_vector = limo_best_electrodes(list1.mat);
    save('virtual_electrode','channel_vector');
end

% ---------------------------------------------------------------------
% one sample t-test
try
    requireModels(list2);
    % one sample t-test whole brain with a cell array of con files as input
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('one_sample'); cd('one_sample')
    LIMOPath = limo_random_select('one sample t-test',STUDY.limo.chanloc,...
        'LIMOfiles',Model2_files.con,...
        'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1);

    % one sample t-test channel 50 file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('one_sample50'); cd('one_sample50')
    LIMOPath = limo_random_select('one sample t-test',STUDY.limo.chanloc,...
        'LIMOfiles',list2.con{1},...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','nboot',101,'tfce',1);

    % one sample t-test virtual channel - array of Betas
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('one_sampleOPT'); cd('one_sampleOPT')
    LIMOPath = limo_random_select('one sample t-test',STUDY.limo.chanloc,...
        'LIMOfiles',Model2_files.Beta, 'analysis_type','1 channel/component only', 'Channel',channel_vector, ...
        'type','Channels','parameter',{[1  3 7]},'nboot',101,'tfce',1);
    limotest{3} = 'one sample t-tests successful';
catch err
    failures{3} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{3} = sprintf('one sample t-tests failed \n%s',err.message);
end

% ---------------------------------------------------------------------
% regression
try
    requireModels(list2);
    % regression (calls similar routines as one sample)
    % regression whole brain with an array of con files as input and a matrix as regressor
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('regression'); cd('regression')
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,...
        'LIMOfiles',Model2_files.con,'regressor_file',randi(length(Model2_files.con),length(Model2_files.con),2),...
        'analysis_type','Full scalp analysis', 'type','Channels','zscore','yes','skip design check','yes','nboot',101,'tfce',1);

    % regression channel 50 file list of con files as input and a file as regressor
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('regression50'); cd('regression50')
    randomreg = randn(length(Model2_files.con),1); save('reg.mat','randomreg');
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,'regressor_file',[pwd filesep 'reg.mat'],...
        'LIMOfiles',list2.con{1},...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','zscore','yes','skip design check','yes','nboot',101,'tfce',1);

    % regression virtual channel - list of Betas files, select a parameter, load optimized channel file
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('regressionOPT'); cd('regressionOPT')
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,...
        'LIMOfiles',list2.beta, ...
        'parameter',3, 'regressor_file',randi(length(Model2_files.con),length(Model2_files.con),2), ...
        'analysis_type','1 channel/component only', 'type','Channels', ...
        'Channel',fullfile(root,['2nd_level_tests' filesep 'virtual_electrode.mat']), ...
        'zscore','yes','skip design check','yes','nboot',101,'tfce',1);
    limotest{4} = 'regressions successful';
catch err
    failures{4} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{4} = sprintf('regressions failed \n%s',err.message);
end

% ---------------------------------------------------------------------
% paired t-test
try
    requireModels(list1);
    % paired t-test whole brain with a cell array of con files as input
    clear data
    for N=length(STUDY.subject):-1:1
        data{1,N} = Model1_files.con{N}(1);
        data{2,N} = Model1_files.con{N}(2);
    end
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('paired_t-test'); cd('paired_t-test')
    LIMOPath = limo_random_select('paired t-test',STUDY.limo.chanloc,...
        'LIMOfiles',data,'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1);

    % paired t-test channel 50 with file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('paired_t-test50'); cd('paired_t-test50')
    datafiles = {list1.con{1}, ...
        list1.con{2}};
    LIMOPath = limo_random_select('paired t-test',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
         'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','nboot',101,'tfce',1);

    % paired t-test virtual channel with file list of Betas
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('paired_t-testOPT'); cd('paired_t-testOPT')
    LIMOPath = limo_random_select('paired t-test',STUDY.limo.chanloc,...
        'LIMOfiles',list1.beta, ...
        'analysis_type','1 channel/component only', 'Channel',channel_vector, ...
        'type','Channels','parameter',[1 4],'nboot',101,'tfce',1);
    limotest{5} = 'paired t-test successful';
catch err
    failures{5} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{5} = sprintf('paired t-test failed \n%s',err.message);
end

% ---------------------------------------------------------------------
% two samples t-test
try
    requireModels(list1, list2);
    data = cell(2, numel(Model1_files.con));
    for subject = 1:numel(Model1_files.con)
        data{1,subject} = Model1_files.con{subject}(1);
        data{2,subject} = Model1_files.con{subject}(2);
    end
    datafiles = list1.con(1:2);
    % two-samples t-test whole brain with a cell array of con files as input
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('two-samples_t-test'); cd('two-samples_t-test')
    LIMOPath = limo_random_select('two-samples t-test',STUDY.limo.chanloc,...
        'LIMOfiles',data,'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1);

    % two-samples t-test channel 50 with file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('two-samples_t-test50'); cd('two-samples_t-test50')
    LIMOPath = limo_random_select('two-samples t-test',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
         'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','nboot',101,'tfce',1);

    % two-samples t-test virtual channel with file list of Betas
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('two-samples_t-testOPT'); cd('two-samples_t-testOPT'); clear Bfiles
    Bfiles{1} = list1.beta;
    Bfiles{2} = list2.beta;
    LIMOPath = limo_random_select('two-samples t-test',STUDY.limo.chanloc,...
        'LIMOfiles',Bfiles, 'analysis_type','1 channel/component only', 'Channel',repmat(channel_vector,[2,1]),...
        'type','Channels','parameter',[1 4],'nboot',101,'tfce',1);
    limotest{6} = 'two samples t-test successful';
catch err
    failures{6} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{6} = sprintf('two samples t-test failed \n%s',err.message);
end

% ---------------------------------------------------------------------
% 1-way ANOVA + contrast
try
    requireModels(list1);
    % N-Ways ANOVA whole brain with a cell array of con files as input with empty cells
    clear data
    index = find(arrayfun(@(x) contains(x.group,'1'), STUDY.datasetinfo));
    for s=1:length(index); data{1,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'2'), STUDY.datasetinfo));
    for s=1:length(index); data{2,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'3'), STUDY.datasetinfo));
    for s=1:length(index); data{3,s} = Model1_files.con{index(s)}(1); end
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('N-Ways ANOVA'); cd('N-Ways ANOVA')
    LIMOPath = limo_random_select('N-Ways ANOVA',STUDY.limo.chanloc,'LIMOfiles',data',...
        'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1,'skip design check','yes','zscore','yes');

    % N-Ways ANOVA channel 50 with file list of con files
    % con per group files already exist split according to STUDY
    datafiles = {list1.group_con{1,1}, ...
        list1.group_con{2,1},...
        list1.group_con{3,1}};
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('N-Ways ANOVA50'); cd('N-Ways ANOVA50')
    LIMOPath = limo_random_select('N-Ways ANOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels',...
        'nboot',101,'tfce',1,'skip design check','yes','zscore','yes');

    % N-Ways ANOVA  virtual channel with file list of Betas and input parameters
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('N-Ways ANOVAOPT'); cd('N-Ways ANOVAOPT')
    for g=3:-1:1
        Bfiles{g} = list1.group_beta{g};
    end
    LIMOPath = limo_random_select('N-Ways ANOVA',STUDY.limo.chanloc,...
        'LIMOfiles',Bfiles, 'analysis_type','1 channel/component only', ...
        'Channel',fullfile(root,['2nd_level_tests' filesep 'virtual_electrode.mat']), ...
        'type','Channels','parameter',[1 1 1],'nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limotest{7} = '1-way ANOVA successful';
catch err
    failures{7} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{7} = sprintf('1-way ANOVA failed \n%s',err.message);
end

% ---------------------------------------------------------------------
% 1-way ANCOVA + contrast
try
    requireModels(list1);
    datafiles = list1.group_con(:,1)';
    Bfiles = list1.group_beta;
    % N-Ways ANCOVA whole brain with a cell array of con files as input with empty cells
    clear data
    index = find(arrayfun(@(x) contains(x.group,'1'), STUDY.datasetinfo));
    for s=1:length(index); data{1,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'2'), STUDY.datasetinfo));
    for s=1:length(index); data{2,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'3'), STUDY.datasetinfo));
    for s=1:length(index); data{3,s} = Model1_files.con{index(s)}(1); end
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('ANCOVA'); cd('ANCOVA')
    LIMOPath = limo_random_select('ANCOVA',STUDY.limo.chanloc,'LIMOfiles',data,... % transpose data = wrong but let limo fix it
        'analysis_type','Full scalp analysis', 'type','Channels',...
        'regressor_file', randn(18,2), 'nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'Betas.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',1,[0 0 0 1 -1 0]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'H0' filesep 'Betas_desc-H0.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',2,[0 0 0 1 -1 0]); % boostrap / tfce

    % N-Ways ANCOVA channel 50 with file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('ANCOVA50'); cd('ANCOVA50')
    LIMOPath = limo_random_select('ANCOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles(1:2),...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels',...
        'regressor_file', randn(13,2),'nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'Betas.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',1,[0 0 1 -1 0]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'H0' filesep 'Betas_desc-H0.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',2,[0 0 1 -1 0]); % boostrap / tfce

    % N-Ways ANCOVA  virtual channel with file list of Betas and input parameters
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('ANCOVAOPT'); cd('ANCOVAOPT')
    LIMOPath = limo_random_select('ANCOVA',STUDY.limo.chanloc,...
        'LIMOfiles',Bfiles, 'analysis_type','1 channel/component only', 'Channel',channel_vector,...
        'regressor_file', randn(18,2),'type','Channels','parameter',[1 4 1],'nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limotest{8} = 'ANCOVA + contrast successful';
catch err
    failures{8} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{8} = sprintf('1-way ANCOVA + contrast failed \n%s',err.message);
end

% ---------------------------------------------------------------------
% Repeated measures ANOVA + contrast
try
    requireModels(list1, list2);
    % whole brain with Beta files as input
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('Rep-ANOVA'); cd('Rep-ANOVA')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',...
        {list1.beta},...
        'analysis_type','Full scalp analysis','parameters',{[1 2 3],[4 5 6],[7 8 9]},...
        'factor names',{'face','repetition'},'type','Channels','nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        3,[1 1 1 -2 -2 -2 1 1 1]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        4,[1 1 1 -2 -2 -2 1 1 1]); % boostrap / tfce

    % whole brain with Beta files as input split by groups
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('GpRep-ANOVA'); cd('GpRep-ANOVA')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',...
        {list2.group_beta{1};
        list2.group_beta{2};
        list2.group_beta{3}},...
        'analysis_type','Full scalp analysis','parameters',{[1 2 3]},... % in theory {[1 2 3];[1 2 3];[1 2 3]} but it's taken care of
        'factor names',{'face'},'type','Channels','nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        3,[1 -2 1]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        4,[1 -2 1]); % boostrap / tfce

    % channel 50 with con files as input
    cd(fullfile(root,'2nd_level_tests'));
    clear datafiles % spurious design but we need enough subjects to run
    datafiles{1,1} = list1.con{1};
    datafiles{1,2} = list2.con{1};
    datafiles{1,3} = list1.con{2};
    mkdir('Rep-ANOVA50'); cd('Rep-ANOVA50')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
        'analysis_type','1 channel/component only', 'Channel',50, 'factor names',{'face'},...
        'parameters',{[1 1 1]},'type','Channels','nboot',101,'tfce',1,'skip design check','yes','zscore','yes');

    % also use gp + con files + optimized channel
    cd(fullfile(root,'2nd_level_tests'));
    clear datafiles; datafiles = cell(3,2);
    datafiles{1,1} = list1.group_con{1,1};
    datafiles{1,2} = list1.group_con{1,2};
    datafiles{2,1} = list1.group_con{2,1};
    datafiles{2,2} = list1.group_con{2,2};
    datafiles{3,1} = list1.group_con{3,1};
    datafiles{3,2} = list1.group_con{3,2};
    mkdir('GpRep-ANOVAOPT'); cd('GpRep-ANOVAOPT')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
        'analysis_type','1 channel/component only', 'Channel',channel_vector, 'factor names',{'face'},...
        'parameters',{[1 1];[1 1];[1 1]},'type','Channels','nboot',101,'tfce',1,'skip design check','yes','zscore','yes');
    limotest{9} = 'Repeated measures ANOVA + contrast successful';
catch err
    failures{9} = err;
    fprintf('%s\n',getReport(err, 'extended', 'hyperlinks', 'off'))
    limotest{9} = sprintf('Repeated measures ANOVA + contrast failed \n%s',err.message);
end

% ---------------------------------------------------------------------
cd(root);toc
limotest'
save(fullfile(root, 'integration_results.mat'), 'limotest', 'failures');
if ~all(contains(limotest,'successful'))
    failure = MException('EEGLAB:LimoIntegrationFailed', 'LIMO integration failed. Outputs: %s', root);
    for index = 1:numel(failures)
        if ~isempty(failures{index}), failure = addCause(failure, failures{index}); end
    end
    throw(failure);
end
end

function requireModels(varargin)
assert(all(~cellfun(@isempty, varargin)), 'EEGLAB:LimoPrerequisiteFailed', ...
    'Second level analysis requires successful first level models and contrasts. See the original failure stacks.');
end


function restoreState(folder, random)
cd(folder);
rng(random);
end
