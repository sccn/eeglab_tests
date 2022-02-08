function tests = miscfunc_abspeak_wrapperTest
tests = functiontests(localfunctions);


function test_fail_invalid_frames(~)
fail_invalid_frames

function test_fail_no_arg(~)
fail_no_arg

function test_pass_all_identical(~)
pass_all_identical

function test_pass_all_negative(~)
pass_all_negative

function test_pass_all_positive(~)
pass_all_positive

function test_pass_inf(~)
pass_inf

function test_pass_mixed_sign(~)
pass_mixed_sign

function test_pass_nan_inf(~)
pass_nan_inf

function test_pass_small_diff(~)
pass_small_diff
