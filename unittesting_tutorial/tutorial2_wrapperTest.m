function tests = tutorial2_wrapperTest
% not registered as a test by default
tests = functiontests(localfunctions);

function setupOnce(testCase)
folder = fullfile(fileparts(which('eeglab')), 'tutorial_scripts');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(folder));

function setup(testCase)
testCase.addTeardown(@cd, pwd);

function test_bids_process_face_experiment(~)
%p = fileparts(which('tutorial2_wrapperTest.m'));
%cd(fullfile(p, '..', 'ds002718'));
%bids_process_face_experiment

function test_bids_p300(~)
p = fileparts(which('tutorial2_wrapperTest.m'));
cd(fullfile(p, '..', 'ds003061'));
simple_study_pipeline;
