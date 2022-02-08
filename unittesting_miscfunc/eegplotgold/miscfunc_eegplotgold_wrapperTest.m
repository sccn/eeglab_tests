function tests = miscfunc_eegplotgold_wrapperTest
tests = functiontests(localfunctions);


function test_fail_no_chanfile(~)
fail_no_chanfile

function test_pass_all_args(~)
pass_all_args

function test_pass_general(~)
pass_general

function test_pass_no_chanlocs(~)
pass_no_chanlocs

function test_pass_no_chanlocs_large(~)
pass_no_chanlocs_large

function test_pass_no_title(~)
pass_no_title
