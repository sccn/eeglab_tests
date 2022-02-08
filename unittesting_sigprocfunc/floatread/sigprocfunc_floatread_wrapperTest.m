function tests = sigprocfunc_floatread_wrapperTest
tests = functiontests(localfunctions);


function test_pass_general(~)
pass_general

function test_pass_nan_inf(~)
pass_nan_inf

function test_pass_no_size(~)
pass_no_size

function test_pass_offset(~)
pass_offset

function test_pass_square(~)
pass_square
