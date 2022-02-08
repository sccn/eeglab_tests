function tests = miscfunc_matcorr_wrapperTest
tests = functiontests(localfunctions);


function test_pass_general(~)
pass_general

function test_pass_mean(~)
pass_mean

function test_pass_method_hungarian(~)
pass_method_hungarian

function test_pass_method_vam(~)
pass_method_vam

function test_pass_not_square(~)
pass_not_square

function test_pass_not_square_hungarian(~)
pass_not_square_hungarian

function test_pass_num_rows(~)
pass_num_rows

function test_pass_weights(~)
pass_weights
