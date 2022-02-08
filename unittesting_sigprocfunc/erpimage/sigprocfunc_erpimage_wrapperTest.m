function tests = sigprocfunc_erpimage_wrapperTest
tests = functiontests(localfunctions);


function test_fail_continuous(~)
fail_continuous

function test_fail_no_arg(~)
fail_no_arg

function test_fail_one_trial(~)
fail_one_trial

function test_fail_trial_div(~)
fail_trial_div

function test_pass_general(~)
pass_general

function test_pass_many_args(~)
pass_many_args

function test_pass_times(~)
pass_times

function test_todo_bugzilla_326(~)
todo_bugzilla_326
