function tests = adminfunc_getkeyval_wrapperTest
tests = functiontests(localfunctions);


function test_fail_no_arg(~)
fail_no_arg

function test_pass_array(~)
pass_array

function test_pass_array_default(~)
pass_array_default

function test_pass_default(~)
pass_default

function test_pass_empty(~)
pass_empty

function test_pass_full(~)
pass_full

function test_pass_full_parent(~)
pass_full_parent

function test_pass_general(~)
pass_general

function test_pass_multi_array(~)
pass_multi_array

function test_pass_not_present(~)
pass_not_present

function test_pass_num_key(~)
pass_num_key

function test_pass_num_key_array(~)
pass_num_key_array

function test_pass_num_key_default(~)
pass_num_key_default

function test_pass_numeric(~)
pass_numeric

function test_pass_present(~)
pass_present
