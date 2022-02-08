function tests = miscfunc_numdim_wrapperTest
tests = functiontests(localfunctions);


function test_pass_column_vector(~)
pass_column_vector

function test_pass_general(~)
pass_general

function test_pass_row_vector(~)
pass_row_vector

function test_pass_singular_matrix(~)
pass_singular_matrix
