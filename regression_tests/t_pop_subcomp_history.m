function tests = t_pop_subcomp_history
% Regression tests for the command history written by pop_subcomp (sccn/eeglab issue 946).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'eeglab');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'functions'), 'IncludingSubfolders', true));
testCase.TestData.EEG = pop_loadset('filename', 'eeglab_data_epochs_ica.set', 'filepath', fullfile(root, 'sample_data'));
end

function testRetainHistoryReplays(testCase)
EEG = testCase.TestData.EEG;
[kept, com] = pop_subcomp(EEG, 2, 0, 1);
verifyEqual(testCase, size(kept.icaweights, 1), 1);
verifySubstring(testCase, com, '[2], 0, 1);');
replayed = replay(com, EEG);
verifyEqual(testCase, replayed.data, kept.data);
verifyEqual(testCase, replayed.icaweights, kept.icaweights);
end

function testRemoveHistoryReplays(testCase)
EEG = testCase.TestData.EEG;
[removed, com] = pop_subcomp(EEG, 2, 0);
verifyEqual(testCase, size(removed.icaweights, 1), size(EEG.icaweights, 1) - 1);
verifySubstring(testCase, com, '[2], 0, 0);');
replayed = replay(com, EEG);
verifyEqual(testCase, replayed.data, removed.data);
end

function EEG = replay(com, EEG) %#ok<INUSD> EEG is reassigned by the evaluated history command
eval(com);
end
