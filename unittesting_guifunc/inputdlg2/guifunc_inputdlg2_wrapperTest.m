function tests = guifunc_inputdlg2_wrapperTest
tests = functiontests(localfunctions);


function test_fail_invalid_length(~)
fail_invalid_length

function test_fail_no_arg(~)
fail_no_arg

function test_i_pass_general(~)
i_pass_general

function test_i_pass_horizontal(~)
i_pass_horizontal

function test_i_pass_no_function(~)
i_pass_no_function
