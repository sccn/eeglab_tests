function tests = test_limo_test_helpers
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'unittesting_limo')));
end

function testRejectsExistingOutput(testCase)
folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture).Folder;
handle = fopen(fullfile(folder, 'participants.tsv'), 'w');
fprintf(handle, 'participant_id\n');
fclose(handle);
verifyError(testCase, @() limo_test_output(folder, folder), '');
verifyTrue(testCase, isfile(fullfile(folder, 'participants.tsv')));
end

function testRejectsMissingDataset(testCase)
folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture).Folder;
verifyError(testCase, @() limo_test_output(folder, fullfile(folder, 'output')), '');
verifyFalse(testCase, isfolder(fullfile(folder, 'output')));
end

function testListsFollowReturnedPathsAndGroupOrder(testCase)
folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture).Folder;
STUDY.datasetinfo = struct('group', {'B', 'A', 'B'});
files.mat = cell(3,1); files.Beta = cell(3,1); files.con = cell(3,1);
for subject = 1:3
    file = fullfile(folder, sprintf('arbitrary_subject_%d.mat', subject));
    save(file, 'subject');
    files.mat{subject} = file;
    files.Beta{subject} = file;
    files.con{subject} = {file};
end
lists = limo_test_lists(files, STUDY, fullfile(folder, 'lists'));
verifyEqual(testCase, readlines(lists.beta, 'EmptyLineRule', 'skip'), string(files.Beta));
verifyEqual(testCase, readlines(lists.group_con{1}, 'EmptyLineRule', 'skip'), string(files.Beta([1 3])));
verifyEqual(testCase, readlines(lists.group_beta{2}, 'EmptyLineRule', 'skip'), string(files.Beta(2)));
end
