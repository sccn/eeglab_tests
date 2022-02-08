function tests = miscfunc_averef_wrapperTest
tests = functiontests(localfunctions);


function test_fail_few_data(~)
fail_few_data

function test_fail_no_arg(~)
fail_no_arg

function test_pass_one_arg_mixed(~)
pass_one_arg_mixed

function test_pass_one_arg_positive(~)
pass_one_arg_positive
