function tests = limo_wrapperTest
tests = functiontests(localfunctions);

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'unittesting_common')));

function test_preprocessing(~)
eeglab_test_workspace('limo_preproc_stats_hw;');

function test_integration(~)
eeglab_test_workspace('limo_test_integration;');
