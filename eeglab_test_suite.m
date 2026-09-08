function suite = eeglab_test_suite(root, includeLimo)
% Discover local tests explicitly, without opening the MATLAB project.
% Project startup installs plugins. The local runner must use installed code.
if nargin < 1
    root = fileparts(mfilename('fullpath'));
end
if nargin < 2
    includeLimo = true;
end
suite = matlab.unittest.TestSuite.fromFile(fullfile(root, 'eeglab_tests_wrapperTest.m'));
folders = dir(fullfile(root, 'unittesting_*'));
for index = 1:numel(folders)
    name = folders(index).name;
    if ~folders(index).isdir || strcmp(name, 'unittesting_common') || ...
            (~includeLimo && strcmp(name, 'unittesting_limo'))
        continue
    end
    suite = [suite matlab.unittest.TestSuite.fromFolder(fullfile(root, name), ...
        'IncludingSubfolders', true)]; %#ok<AGROW>
end
suite = [suite matlab.unittest.TestSuite.fromFolder(fullfile(root, 'regression_tests'), ...
    'IncludingSubfolders', true)];
keys = string({suite.Name}) + "|" + string({suite.BaseFolder});
[~, index] = unique(keys, 'stable');
suite = suite(index);
end
