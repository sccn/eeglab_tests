function [studypath, outputdir, cleanup] = limo_test_output(studypath, outputdir)
% All LIMO test products belong in a new directory. Never delete source data.
assert(isfile(fullfile(studypath, 'participants.tsv')), 'LIMO test requires the local ds002718 dataset.');
[~, attributes] = fileattrib(studypath);
studypath = attributes.Name;
if isempty(outputdir)
    outputdir = tempname;
end
assert(~isfolder(outputdir), 'Choose a new LIMO output directory. Existing results are preserved.');
mkdir(outputdir);
[~, attributes] = fileattrib(outputdir);
outputdir = attributes.Name;
oldFolder = pwd;
cleanup = onCleanup(@() cd(oldFolder));
fprintf('LIMO test outputs retained in %s\n', outputdir);
end
