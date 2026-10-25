function tests = t_pop_chanedit_dipfit
% Regression tests for channel location lookup with and without DIPFIT (sccn/eeglab issue 933).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'eeglab');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'functions'), 'IncludingSubfolders', true));
testCase.TestData.root = root;
testCase.TestData.dipfit = fullfile(root, 'plugins', 'dipfit');
testCase.TestData.EEG = pop_loadset('filename', 'eeglab_data.set', 'filepath', fullfile(root, 'sample_data'));
end

function setup(testCase)
testCase.TestData.path = path;
end

function teardown(testCase)
path(testCase.TestData.path);
end

function testAliasWithoutDipfitGivesClearError(testCase)
removeDipfit();
verifyEqual(testCase, exist('dipfitdefs', 'file'), 0);
message = '';
try
    pop_chanedit(testCase.TestData.EEG, 'lookup', 'standard-10-5-cap385.elp');
catch err
    message = err.message;
end
verifySubstring(testCase, message, 'requires the DIPFIT plugin');
end

function testShippedTemplateWithoutDipfit(testCase)
removeDipfit();
file = fullfile(testCase.TestData.root, 'functions', 'supportfiles', 'Standard-10-5-Cap385_witheog.elp');
EEG = pop_chanedit(testCase.TestData.EEG, 'lookup', file);
verifyNotEmpty(testCase, EEG.chanlocs(1).X);
end

function testAliasWithDipfit(testCase)
assumeTrue(testCase, isfile(fullfile(testCase.TestData.dipfit, 'dipfitdefs.m')), 'DIPFIT plugin not installed');
addpath(genpath(testCase.TestData.dipfit)); % the plugin startup adds its subfolders too
EEG = pop_chanedit(testCase.TestData.EEG, 'lookup', 'standard-10-5-cap385.elp');
verifyNotEmpty(testCase, EEG.chanlocs(1).X);
end

function removeDipfit
% Take every folder providing dipfitdefs off the path (restored by teardown).
found = which('dipfitdefs');
while ~isempty(found)
    rmpath(fileparts(found));
    found = which('dipfitdefs');
end
end
