package OpenQA::Wheel::Launcher;
use Mojo::Base 'Exporter', -signatures;

use testapi qw(send_key assert_screen check_screen save_screenshot type_string mouse_hide);

our @EXPORT_OK = qw(start_gui_program);

=head1 introduction

=for stopwords os autoinst isotovideo openQA

This openQA wheel provides GUI program launching features.

It is meant to be added to your distribution's wheels.yaml.

=cut

=head1 test API

=head2 start_gui_program

The given program will be launched via the command prompt
of the desktop environment, assuming it's accessible via F2.

The needle 'desktop-runner' must be matched.

If the optional value C<terminal> is set Alt-T will be pressed.

If the optional value C<valid> is set to 1 the presence of the
needle 'desktop-runner-border' will be required.

=cut

sub start_gui_program ($program, $timeout, %args) {
    send_key 'alt-f2';
    mouse_hide(1);
    assert_screen('desktop-runner', $timeout);
    type_string $program;
    if ($args{terminal}) {
        wait_screen_change { send_key 'alt-t' };
    }
    save_screenshot;
    send_key 'ret';
    # make sure desktop runner was executed and closed successfully
    if ($args{valid}) {
        foreach my $i (1 .. 3) {
            last unless check_screen 'desktop-runner-border', 2;
            send_key 'ret';
        }
    }
}

1;
