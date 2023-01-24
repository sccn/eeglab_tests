function tests = adminfunc_eeglab_execmenu_wrapperTest
tests = functiontests(localfunctions);

function test_i_pass_general(~)
evalin('base', 'test_eeglab_execmenu');
