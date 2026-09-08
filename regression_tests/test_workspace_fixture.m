function tests = test_workspace_fixture
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'unittesting_common')));
end

function testRestoresStateOnSuccess(testCase)
checkRestore(testCase, false);
end

function testRestoresStateOnError(testCase)
checkRestore(testCase, true);
end

function testPreservesExistingEeglabWindow(testCase)
original = figure('Visible', 'off', 'Tag', 'EEGLAB', 'UserData', 42);
cleanup = onCleanup(@() delete(original(isgraphics(original)))); %#ok<NASGU>
eeglab_test_workspace('delete(findall(groot, ''Type'', ''figure'', ''Tag'', ''EEGLAB'')); figure(''Tag'', ''EEGLAB'');');
verifyTrue(testCase, isgraphics(original));
verifyEqual(testCase, get(original, 'Tag'), 'EEGLAB');
verifyEqual(testCase, get(original, 'UserData'), 42);
end

function checkRestore(testCase, shouldError)
name = 'EEGLAB_FIXTURE_SENTINEL';
previous = evalin('base', 'whos(''EEGLAB_FIXTURE_SENTINEL'')');
if ~isempty(previous), oldValue = evalin('base', name); else, oldValue = []; end
cleanup = onCleanup(@() restoreSentinel(previous, oldValue)); %#ok<NASGU>
assignin('base', name, 42);
oldFolder = pwd;
oldRandom = rng;
oldFigures = findall(groot, 'Type', 'figure');
commands = 'EEGLAB_FIXTURE_SENTINEL = 99; rng(71); figure; fid=fopen(''fixture.txt'',''w''); fclose(fid);';
if shouldError
    verifyError(testCase, @() eeglab_test_workspace([commands ' error(''EEGLAB:testFailure'',''expected'');']), 'EEGLAB:testFailure');
else
    eeglab_test_workspace(commands);
end
verifyEqual(testCase, evalin('base', name), 42);
verifyEqual(testCase, pwd, oldFolder);
verifyEqual(testCase, rng, oldRandom);
verifyEqual(testCase, findall(groot, 'Type', 'figure'), oldFigures);
end

function restoreSentinel(previous, value)
evalin('base', 'clear EEGLAB_FIXTURE_SENTINEL');
if ~isempty(previous)
    if previous.global, evalin('base', 'global EEGLAB_FIXTURE_SENTINEL'); end
    assignin('base', 'EEGLAB_FIXTURE_SENTINEL', value);
end
end
