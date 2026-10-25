function lists = limo_test_lists(files, STUDY, folder)
% Build test input lists from returned references, not plugin filename guesses.
assert(numel(files.mat) == numel(STUDY.datasetinfo), 'Missing first level subjects.');
mkdir(folder);
lists.mat = writeList(fullfile(folder, 'LIMO_files.txt'), files.mat);
lists.beta = writeList(fullfile(folder, 'Beta_files.txt'), files.Beta);
if isfield(files, 'con')
    for contrast = 1:numel(files.con{1})
        paths = cellfun(@(entry) entry{contrast}, files.con, 'UniformOutput', false);
        lists.con{contrast} = writeList(fullfile(folder, sprintf('con_%d_files.txt', contrast)), paths);
    end
end
groups = unique({STUDY.datasetinfo.group}, 'stable');
for group = 1:numel(groups)
    selected = strcmp({STUDY.datasetinfo.group}, groups{group});
    lists.group_beta{group} = writeList(fullfile(folder, sprintf('Beta_group_%d.txt', group)), files.Beta(selected));
    if isfield(files, 'con')
        for contrast = 1:numel(files.con{1})
            paths = cellfun(@(entry) entry{contrast}, files.con(selected), 'UniformOutput', false);
            lists.group_con{group, contrast} = writeList(fullfile(folder, sprintf('con_%d_group_%d.txt', contrast, group)), paths);
        end
    end
end
end

function file = writeList(file, paths)
assert(all(cellfun(@isfile, paths)), 'A returned LIMO output file does not exist.');
handle = fopen(file, 'w');
assert(handle ~= -1, 'Cannot write LIMO input list %s.', file);
cleanup = onCleanup(@() fclose(handle)); %#ok<NASGU>
fprintf(handle, '%s\n', paths{:});
end
