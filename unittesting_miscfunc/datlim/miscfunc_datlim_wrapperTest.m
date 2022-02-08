function tests = miscfunc_datlim_wrapperTest
tests = functiontests(localfunctions);


function test_fail_not_numeric(~)
fail_not_numeric

function test_pass_all_positive(~)
pass_all_positive

function test_pass_mixed(~)
pass_mixed
