function tests = adminfunc_eeg_store_wrapperTest
tests = functiontests(localfunctions);


function test_fail_negative_index(~)
fail_negative_index

function test_fail_no_arg(~)
fail_no_arg

function test_fail_num_index(~)
fail_num_index

function test_pass_bugzilla_17(~)
pass_bugzilla_17

function test_pass_general(~)
pass_general

function test_pass_multiple(~)
pass_multiple

function test_pass_multiple_new(~)
pass_multiple_new

function test_pass_new(~)
pass_new
