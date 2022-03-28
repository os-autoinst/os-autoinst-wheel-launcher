use Mojo::Base 'basetest';
# use testapi;
# use utils;
use OpenQA::Wheel::Launcher 'start_gui_program';

sub run {
    start_gui_program('firefox');
};

1
