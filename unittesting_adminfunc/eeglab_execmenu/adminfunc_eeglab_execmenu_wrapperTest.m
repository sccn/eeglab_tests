function tests = adminfunc_eeglab_execmenu_wrapperTest
tests = functiontests(localfunctions);

function setupOnce(testCase)
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'unittesting_common')));

function test_i_pass_general(~)
test_eeglab_execmenu;
