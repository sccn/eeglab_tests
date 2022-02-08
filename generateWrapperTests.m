function generateWrapperTests()
%GENERATEWRAPPERTESTS Generate function-based wrapper tests for EEGLAB
%   Generate a wrapper test function for each directory of EEGLAB testcases
%   in the style of MATLAB Unit Testing Framework.
%   This enables leveraging latest capabilities of MATLAB Unit Testing
%   without requiring to rewrite all old tests.

% the starting directory from which we detect all test files/functions
testRootDir = fileparts(mfilename('fullpath'));

% since we want to replicate running the existing tests, we should exclude
% the same files for our wrapper as in runtests.m
excludeFiles = { 'runtest.m' 'scanfoldersendemail.m' ...
    'ds002718' 'unittesting_tutorial' 'unittesting_common' 'unittesting_limo' ...
    'regression_tests'};

% in addition we want to exclude these files:

excludeFiles{end+1} = [mfilename '.m']; % this file
excludeFiles{end+1} = 'runMUtests.m';   % function for running MU tests

% and a new test function for running all tests with Unit Testing Framework

% and we want to exclude any previously generated wrapper Test functions or
% manually created Test files
containsName = {'Test.m'};

% all mFiles under the same root dir as this function
allMfiles = dir([testRootDir '/**/*.m']);

% exclude all mFiles that are in a folder that contains any of the names
% from excludeFiles
excludedFileFolders = contains({allMfiles.folder}, excludeFiles);
allMfiles(excludedFileFolders) = [];

% exclude all mFiles that have a name that is in the names of excludeFiles
excludedFileNames = matches({allMfiles.name}, excludeFiles);
allMfiles(excludedFileNames) = [];

% exclude previously generated wrapper Test functions
excludedTestFiles = contains({allMfiles.name}, containsName);
allMfiles(excludedTestFiles) = [];

allTestFolders = unique({allMfiles.folder});

for idx=1:length(allTestFolders)
    thisTestFolder = allTestFolders{idx};
    MfilesInFolder = allMfiles(strcmp({allMfiles.folder}, thisTestFolder));

    [~, testRelName] = fileparts(thisTestFolder);
    ut_idx = strfind(thisTestFolder, 'unittesting_');
    if isempty(ut_idx)
        testParentName = '';
    else
        parentFolder = fileparts(thisTestFolder);
        cut_idx = ut_idx + length('unittesting_');
        testParentName = [parentFolder(cut_idx:end) '_'];
    end
        
    testFunctionName = matlab.lang.makeValidName([testParentName testRelName '_wrapperTest']);

    testFileHeader = sprintf('function tests = %s\ntests = functiontests(localfunctions);\n\n', testFunctionName);
    testNames = {MfilesInFolder.name};
    testNames = replace(testNames, '.m', '');

    args = [testNames; testNames];
    testFileContents = [testFileHeader, sprintf('\nfunction test_%s(~)\n%s\n', args{:})];
    filewrite(fullfile(thisTestFolder, [testFunctionName '.m']), testFileContents);

end

