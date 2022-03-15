function tests = binary_pop_chancoresp_wrapperTest
tests = functiontests(localfunctions);


function test_pass_autoselect_fiducials(~)
pass_autoselect_fiducials

function test_pass_autoselect_none(~)
pass_autoselect_none

function test_pass_chanlists_not_empty(~)
pass_chanlists_not_empty

function test_pass_clear(~)
pass_clear

function test_pass_invalid_fiducials(~)
pass_invalid_fiducials

function test_pass_labels_only(~)
pass_labels_only

function test_pass_pair(~)
pass_pair

function test_pass_unpair(~)
pass_unpair

function test_test_pop_chancoresp(~)
test_pop_chancoresp
