function tests = adminfunc_eeg_retrieve_wrapperTest
tests = functiontests(localfunctions);


function test_fail_no_arg(~)
fail_no_arg

function test_fail_outside(~)
fail_outside

function test_pass_general(~)
pass_general

function test_pass_multiple(~)
pass_multiple

function test_pass_zero(~)
pass_zero
