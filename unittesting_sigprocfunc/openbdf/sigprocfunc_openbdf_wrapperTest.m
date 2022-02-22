function tests = sigprocfunc_openbdf_wrapperTest
tests = functiontests(localfunctions);


function test_pass_chan_types(~)
pass_chan_types

function test_pass_dig_min_larger_max(~)
pass_dig_min_larger_max

function test_pass_general(~)
pass_general

function test_pass_invalid_dig_min_max(~)
pass_invalid_dig_min_max

function test_pass_invalid_phys_min_max(~)
pass_invalid_phys_min_max

function test_pass_phys_min_larger_max(~)
pass_phys_min_larger_max

function test_pass_unknown_record_size(~)
pass_unknown_record_size
