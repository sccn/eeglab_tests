function tests = sigprocfunc_eegplot2event_wrapperTest
tests = functiontests(localfunctions);


function test_pass_general(~)
pass_general

function test_pass_multiple_events(~)
pass_multiple_events

function test_pass_multiple_events_colorin(~)
pass_multiple_events_colorin

function test_pass_multiple_events_colorout(~)
pass_multiple_events_colorout

function test_pass_multiple_events_notfound(~)
pass_multiple_events_notfound

function test_pass_one_arg(~)
pass_one_arg
