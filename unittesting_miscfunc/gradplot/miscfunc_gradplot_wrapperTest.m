function tests = miscfunc_gradplot_wrapperTest
tests = functiontests(localfunctions);


function test_fail_no_arg(~)
fail_no_arg

function test_pass_center(~)
pass_center

function test_pass_center_file(~)
pass_center_file

function test_pass_corner(~)
pass_corner
