function tests = sigprocfunc_runica_wrapperTest
tests = functiontests(localfunctions);


function test_pass_extended(~)
pass_extended

function test_pass_extended_nobias(~)
pass_extended_nobias

function test_pass_extended_noise10dB(~)
pass_extended_noise10dB

function test_pass_extended_noise20dB(~)
pass_extended_noise20dB

function test_pass_general(~)
pass_general

function test_pass_general_nobias(~)
pass_general_nobias

function test_pass_general_noise10dB(~)
pass_general_noise10dB

function test_pass_general_noise20dB(~)
pass_general_noise20dB

function test_pass_ncomps(~)
pass_ncomps

function test_pass_pca(~)
pass_pca

function test_pass_posact(~)
pass_posact

function test_pass_weights(~)
pass_weights
