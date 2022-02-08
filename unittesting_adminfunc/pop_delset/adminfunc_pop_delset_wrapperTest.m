function tests = adminfunc_pop_delset_wrapperTest
tests = functiontests(localfunctions);


function test_fail_alleeg_empty(~)
fail_alleeg_empty

function test_fail_no_arg(~)
fail_no_arg

function test_i_pass_general(~)
i_pass_general

function test_i_pass_set_in_negative(~)
i_pass_set_in_negative

function test_pass_set_in(~)
pass_set_in
