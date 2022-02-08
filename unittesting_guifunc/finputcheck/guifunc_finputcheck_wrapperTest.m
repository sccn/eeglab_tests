function tests = guifunc_finputcheck_wrapperTest
tests = functiontests(localfunctions);


function test_fail_no_arg(~)
fail_no_arg

function test_fail_no_key_val(~)
fail_no_key_val

function test_pass_empty(~)
pass_empty

function test_pass_general(~)
pass_general

function test_pass_multiple_types(~)
pass_multiple_types

function test_pass_standard(~)
pass_standard

function test_pass_strings(~)
pass_strings

function test_pass_unknown(~)
pass_unknown
