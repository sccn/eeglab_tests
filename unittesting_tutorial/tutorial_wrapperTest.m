function tests = tutorial_wrapperTest
tests = functiontests(localfunctions);


% function test_bids_process_face_experiment(~)
% bids_process_face_experiment

function test_eeglab_history(~)
eeglab_history

function test_event_processing_single_dataset(~)
event_processing_single_dataset

function test_event_processing_study(~)
event_processing_study

function test_make_eeg_movie(~)
make_eeg_movie

%function test_plot_study_erp(~)
% asking for download
%plot_study_erp

% function test_source_reconstruction_advanced(~)
% source_reconstruction_advanced
% 
% function test_source_reconstruction_eeg(~)
% source_reconstruction_eeg

% function test_study_script(~)
% p = fileparts(which('tutorial_wrapperTest.m'));
% cd(fullfile(p, '..', 'unittesting_studyfunc', 'teststudy'));
% study_script

function test_time_freq_all_elec(~)
time_freq_all_elec
