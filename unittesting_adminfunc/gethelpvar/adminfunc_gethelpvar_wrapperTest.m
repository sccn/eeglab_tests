function tests = adminfunc_gethelpvar_wrapperTest
tests = functiontests(localfunctions);


function test_fail_no_arg(~)
fail_no_arg

function test_fail_no_file(~)
fail_no_file

function test_pass_all(~)
pass_all

function test_pass_general(~)
pass_general

function test_pass_no_var(~)
pass_no_var

function test_pass_some(~)
pass_some
