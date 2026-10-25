function tests = t_eeg_getdatact_precision
% Regression tests for reading binary data in the requested precision (sccn/eeglab issue 953).
% The single-precision option is toggled through pop_editoptions; the user's option
% file is backed up in setupOnce and restored afterwards.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'eeglab');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(root));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'functions'), 'IncludingSubfolders', true));
testCase.TestData.sample = fullfile(root, 'sample_data');
file = optionFile;
backup = '';
if isfile(file)
    backup = [tempname '.m'];
    copyfile(file, backup);
end
testCase.addTeardown(@restoreOptions, file, backup);
end

function testSinglePrecisionRead(testCase)
setSinglePrecision(testCase, 1);
[EEG, reference] = loadWithReference(testCase);
verifyClass(testCase, EEG.data, 'single');
verifyEqual(testCase, EEG.data, single(reference));
info = pop_loadset('filename', 'eeglab_data_epochs_ica.set', 'filepath', testCase.TestData.sample, 'loadmode', 'info');
subset = eeg_getdatact(info, 'channel', [3 7]);
verifyClass(testCase, subset, 'single');
verifyEqual(testCase, subset, single(reference([3 7], :, :)));
end

function testDoublePrecisionRead(testCase)
setSinglePrecision(testCase, 0);
[EEG, reference] = loadWithReference(testCase);
verifyClass(testCase, EEG.data, 'double');
verifyEqual(testCase, EEG.data, reference);
end

function [EEG, reference] = loadWithReference(testCase)
EEG = pop_loadset('filename', 'eeglab_data_epochs_ica.set', 'filepath', testCase.TestData.sample);
fid = fopen(fullfile(testCase.TestData.sample, 'eeglab_data_epochs_ica.fdt'), 'r', 'ieee-le');
reference = fread(fid, [EEG.nbchan Inf], 'float32');
fclose(fid);
reference = reshape(reference, EEG.nbchan, EEG.pnts, EEG.trials);
end

function setSinglePrecision(testCase, value)
pop_editoptions('option_single', value);
clear eeg_options
eeglab_options;
assertEqual(testCase, option_single, value, 'the single-precision option could not be changed');
end

function file = optionFile
% Same location rule as eeglab_options and pop_editoptions.
icadefs;
if exist('EEGOPTION_PATH', 'var') && ~isempty(EEGOPTION_PATH)
    folder = EEGOPTION_PATH;
elseif ispc
    folder = getenv('USERPROFILE');
else
    folder = getenv('HOME');
end
file = fullfile(folder, 'eeg_options.m');
end

function restoreOptions(file, backup)
if ~isempty(backup)
    copyfile(backup, file);
    delete(backup);
elseif isfile(file)
    delete(file);
end
clear eeg_options
end
