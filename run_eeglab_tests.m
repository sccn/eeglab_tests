function results = run_eeglab_tests(varargin)
% Run installed EEGLAB tests locally, with a manifest and persistent results.
% run_eeglab_tests('OutputDirectory', folder, 'IncludeLimo', false)
% run_eeglab_tests('DiscoverOnly', true)
% Legacy tests write data in this checkout. Use a disposable copy if needed.
parser = inputParser;
parser.addParameter('OutputDirectory', '', @(x) ischar(x) || isstring(x));
parser.addParameter('IncludeLimo', true, @(x) islogical(x) && isscalar(x));
parser.addParameter('DiscoverOnly', false, @(x) islogical(x) && isscalar(x));
parser.addParameter('Name', '*', @(x) ischar(x) || isstring(x));
parser.parse(varargin{:});
options = parser.Results;
root = fileparts(mfilename('fullpath'));
output = char(options.OutputDirectory);
if isempty(output)
    output = fullfile(root, 'test-results', char(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS')));
end
if ~isfolder(output)
    mkdir(output);
end
% Convert relative paths before legacy tests change the working directory.
[ok, attributes] = fileattrib(output);
assert(ok, 'Cannot resolve output directory.');
output = attributes.Name;
assert(~isfile(fullfile(output, 'manifest.csv')), 'Choose a new output directory to preserve previous results.');
oldPath = path;
oldFolder = pwd;
oldVisibility = get(groot, 'DefaultFigureVisible');
cleanup = onCleanup(@() restoreRunner(oldPath, oldFolder, oldVisibility)); %#ok<NASGU>
cd(root);
addpath(root, fullfile(root, 'eeglab'), fullfile(root, 'regression_tests'));
addpath(genpath(fullfile(root, 'unittesting_common')));
set(groot, 'DefaultFigureVisible', 'off');
eeglab;
preferences = eeglab_test_preferences; %#ok<NASGU>
suite = eeglab_test_suite(root, options.IncludeLimo);
pattern = ['^' regexptranslate('wildcard', char(options.Name)) '$'];
suite = suite.selectIf(matlab.unittest.selectors.HasName(matlab.unittest.constraints.Matches(pattern)));
assert(~isempty(suite), 'EEGLAB:NoTests', 'No tests matched the requested selection.');
manifest = table(string({suite.Name})', string({suite.BaseFolder})', ...
    'VariableNames', {'Name', 'BaseFolder'});
writetable(manifest, fullfile(output, 'manifest.csv'));
environment = struct('matlab', version, 'architecture', computer, ...
    'eeglab', which('eeglab'), 'version', eeg_getversion, 'path', path);
save(fullfile(output, 'suite.mat'), 'suite', 'environment');
fprintf('Discovered %d unique tests. Results: %s\n', numel(suite), output);
results = matlab.unittest.TestResult.empty;
if options.DiscoverOnly
    return
end
runner = matlab.unittest.TestRunner.withTextOutput;
runner.addPlugin(matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(fullfile(output, 'results.xml')));
runner.addPlugin(matlab.unittest.plugins.DiagnosticsRecordingPlugin);
runner.addPlugin(EeglabTestProgressPlugin(output));
started = datetime('now');
results = runner.run(suite);
finished = datetime('now');
save(fullfile(output, 'results.mat'), 'results', 'started', 'finished', 'environment');
summary = table(results);
writetable(summary(:, {'Name', 'Passed', 'Failed', 'Incomplete', 'Duration'}), fullfile(output, 'results.csv'));
fprintf('Completed %d tests: %d passed, %d failed, %d incomplete.\n', ...
    numel(results), nnz([results.Passed]), nnz([results.Failed]), nnz([results.Incomplete]));
end

function restoreRunner(oldPath, oldFolder, oldVisibility)
cd(oldFolder);
path(oldPath);
set(groot, 'DefaultFigureVisible', oldVisibility);
end
