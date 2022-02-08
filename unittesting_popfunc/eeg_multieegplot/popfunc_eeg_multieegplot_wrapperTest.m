function tests = popfunc_eeg_multieegplot_wrapperTest
tests = functiontests(localfunctions);


function test_pass_continuous(~)
pass_continuous

function test_pass_continuous_reject(~)
pass_continuous_reject

function test_pass_epochs(~)
pass_epochs
