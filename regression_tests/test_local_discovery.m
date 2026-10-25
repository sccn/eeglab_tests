function tests = test_local_discovery
tests = functiontests(localfunctions);
end

function testNoInstallersOrNestedRunners(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
suite = eeglab_test_suite(root, false);
names = string({suite.Name});
verifyEqual(testCase, numel(unique(names)), numel(names));
verifyFalse(testCase, any(contains(names, {'test_add_plugins', 'example_local_test', 'runtest/'})));
verifyTrue(testCase, any(names == "adminfunc_eeglab_execmenu_wrapperTest/test_i_pass_general"));
verifyFalse(testCase, any(startsWith(names, "test_eeglab_execmenu/")));
verifyTrue(testCase, any(startsWith(names, "test_workspace_fixture/")));
end

function testLimoWrappersAreDiscoverable(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
suite = matlab.unittest.TestSuite.fromFile(fullfile(root, 'unittesting_limo', 'limo_wrapperTest.m'));
verifyEqual(testCase, sort(string({suite.Name})), sort(["limo_wrapperTest/test_preprocessing", "limo_wrapperTest/test_integration"]));
end
