#!/usr/bin/perl
use Test::Most;
use Mojo::Base -strict, -signatures;

# import mocked test API
use FindBin '$Bin';
use lib "$Bin/lib";
use testapi;

# import modules we'd like to test
use lib "$Bin/..", "$Bin/../lib";
use OpenQA::Wheel::Launcher qw(start_gui_program);

subtest 'run wheel as a whole' => sub {
    { package tests::wheels::launcher; use tests::wheels::launcher }  # uncoverable statement

    tests::wheels::launcher->new->run;
    is_deeply testapi::invoked_functions, [
        [send_key => ('alt-f2')],
        [mouse_hide => (1)],
        [assert_screen => ('desktop-runner', undef)],
        [type_string => ('firefox')],
        [save_screenshot => ()],
        [send_key => ('ret')],
    ], 'expected test API functions invoked' or diag explain testapi::invoked_functions;
};

subtest 'helper for starting GUI program with custom timeout, terminal and validation' => sub {
    my $check_screen_invocations = 0;
    testapi::function_overrides->{check_screen} = sub (@) { ++$check_screen_invocations != 2 };
    testapi::clear_invoked_functions;

    start_gui_program('foo', 42, valid => 1, terminal => 1);
    is_deeply testapi::invoked_functions, [
       [send_key => ('alt-f2')],
       [mouse_hide => (1)],
       [assert_screen => ('desktop-runner', 42)],  # timeout passed to assert_screen
       [type_string => ('foo')],  # program name typed
       [wait_screen_change => ()],  # due to terminal flag
       [send_key => ('alt-t')],  # via wait_screen_change callback
       [save_screenshot => ()],
       [send_key => ('ret')],
       [check_screen => ('desktop-runner-border', 2)],  # due to valid flag
       [send_key => ('ret')],
       [check_screen => ('desktop-runner-border', 2)],  # no 3rd check_screen call as 2nd invocation mocked to return falsy value
    ], 'expected test API functions invoked' or diag explain testapi::invoked_functions;
};

done_testing();
