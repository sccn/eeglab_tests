function tests = miscfunc_eeg_ms2f_wrapperTest
tests = functiontests(localfunctions);


function test_fail_outside(~)
fail_outside

function test_pass_center(~)
pass_center

function test_pass_exact(~)
pass_exact

function test_pass_rounded(~)
pass_rounded
