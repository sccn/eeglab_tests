function tests = sigprocfunc_eegthresh_wrapperTest
tests = functiontests(localfunctions);


function test_pass_continuous(~)
pass_continuous

function test_pass_general(~)
pass_general

function test_pass_one_elec(~)
pass_one_elec

function test_pass_one_epoch(~)
pass_one_epoch

function test_pass_rej_all(~)
pass_rej_all

function test_pass_rej_nothing(~)
pass_rej_nothing

function test_pass_two_epochs(~)
pass_two_epochs
