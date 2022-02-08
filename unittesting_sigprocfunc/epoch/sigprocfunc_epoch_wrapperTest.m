function tests = sigprocfunc_epoch_wrapperTest
tests = functiontests(localfunctions);


function test_pass_allevents(~)
pass_allevents

function test_pass_boundary(~)
pass_boundary

function test_pass_general(~)
pass_general

function test_pass_no_srate(~)
pass_no_srate

function test_pass_valuelim(~)
pass_valuelim
