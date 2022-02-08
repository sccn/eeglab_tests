function results = runMUtests
import matlab.unittest.selectors.HasName

% manage restoring current path after running runMUtests
currentPath = path;
cleanupObj = onCleanup(@() path(currentPath));

% set paths
runtest_setenvironment

% find rootDir of tests based on path of this MATLAB function
testRootDir = fileparts(mfilename('fullpath'));

% create test suite from testRootDir
suite = matlab.unittest.TestSuite.fromFolder(testRootDir, 'IncludingSubfolders', true);

% runtest is a utility function from eeglab-testcases when NOT using MATLAB
% Unit Testing Framework. Since it follows naming conventions of MU, we
% need to exclude it here explicitly
suite = suite.selectIf(~HasName('runtest/runtest'));

% run test suite from test runner
runner = testrunner;
results = run(runner, suite);

% if function is called without output arguments, store results in base
% workspace to not loose them by accident
if nargout == 0
    assignin('base', 'results', results)
    % display result summary
    results %#ok<NOPRT> 
    clear results
end
