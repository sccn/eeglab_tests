function tests = limo_wrapperTest
tests = functiontests(localfunctions);

function limo_test1(~)
p = fileparts(fileparts(which('limo_wrapperTest.m')));
cd(fullfile(p, 'ds002718'));
limo_preproc_stats_hw;

function limo_test2(~)
p = fileparts(fileparts(which('limo_wrapperTest.m')));
cd(fullfile(p, 'ds002718'));
limo_test_integration;