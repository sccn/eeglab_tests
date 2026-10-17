function tests = t_eegplot_event_duration
% Regression tests for shading event durations in the scroll plot (sccn/eeglab issue 941).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'eeglab');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'functions'), 'IncludingSubfolders', true));
EEG = eeg_emptyset;
EEG.nbchan = 2;
EEG.trials = 1;
EEG.srate = 500;
EEG.pnts = EEG.srate*120;
EEG.xmin = 0;
EEG.xmax = (EEG.pnts-1)/EEG.srate;
EEG.data = zeros(2, EEG.pnts, 'single');
EEG.event = struct('type', 'long', 'latency', 20*EEG.srate+1, 'duration', 10*EEG.srate); % 20 s to 30 s
testCase.TestData.EEG = eeg_checkset(EEG, 'eventconsistency');
end

function setup(testCase)
testCase.TestData.figures = findall(groot, 'Type', 'figure');
testCase.TestData.visibility = get(groot, 'DefaultFigureVisible');
set(groot, 'DefaultFigureVisible', 'off');
end

function teardown(testCase)
delete(setdiff(findall(groot, 'Type', 'figure'), testCase.TestData.figures));
set(groot, 'DefaultFigureVisible', testCase.TestData.visibility);
end

function testCurrentImplementation(testCase)
checkShading(testCase, @eegplot);
end

function testLegacyImplementation(testCase)
checkShading(testCase, @eegplotlegacy);
end

function checkShading(testCase, plotter)
EEG = testCase.TestData.EEG;
plotter(EEG.data, 'srate', EEG.srate, 'events', EEG.event, 'ploteventdur', 'on', 'winlength', 5);
fig = gcf;
verifyEqual(testCase, countPatches(fig), 0, 'window 0-5 s contains no event');
verifyEqual(testCase, countPatchesAt(plotter, fig, 18), 1, 'window 18-23 s contains the event onset');
verifyEqual(testCase, countPatchesAt(plotter, fig, 22), 1, 'window 22-27 s lies inside the event');
end

function n = countPatchesAt(plotter, fig, seconds)
set(findobj(fig, 'tag', 'EPosition'), 'string', num2str(seconds));
set(groot, 'CurrentFigure', fig);
plotter('drawp', 0);
n = countPatches(fig);
end

function n = countPatches(fig)
n = numel(findobj(findobj(fig, 'tag', 'backeeg'), 'type', 'patch'));
end
