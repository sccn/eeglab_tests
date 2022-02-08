function tests = adminfunc_eegh_wrapperTest
tests = functiontests(localfunctions);


function test_fail_get_empty(~)
fail_get_empty

function test_pass_add_history(~)
pass_add_history

function test_pass_add_multiple_history(~)
pass_add_multiple_history

function test_pass_add_multiple_history2(~)
pass_add_multiple_history2

function test_pass_delete_commands(~)
pass_delete_commands

function test_pass_empty_command(~)
pass_empty_command

function test_pass_execute_command(~)
pass_execute_command

function test_pass_find_command(~)
pass_find_command

function test_pass_find_command2(~)
pass_find_command2

function test_pass_insert_command(~)
pass_insert_command

function test_pass_new_command(~)
pass_new_command

function test_pass_return_commands(~)
pass_return_commands

function test_pass_unstack_command(~)
pass_unstack_command
