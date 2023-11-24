package testapi;
use Exporter;
use Mojo::Base 'Exporter', -signatures;

# list names of test API functions our wheel is expected to call
our @EXPORT = qw(send_key assert_screen check_var check_screen save_screenshot type_string mouse_hide wait_screen_change);

# define helpers for tracking invoked test API functions
my @INVOKED;
my %OVERRIDES;
sub invoked_functions () { \@INVOKED }
sub clear_invoked_functions () { @INVOKED = () }
sub function_overrides () { \%OVERRIDES }
sub _track_function_call ($function, @args) {
    push @INVOKED, [$function, @args];
    return 1 unless my $override = $OVERRIDES{$function};
    return $override->(@args);
}

# define test API functions that cannot just be no-ops
sub wait_screen_change : prototype(&@) {
    my $callback = shift;
    _track_function_call wait_screen_change => @_;
    $callback->();
}

# use AUTOLOAD to handle remaining test API functions
sub AUTOLOAD {
    my $function = our $AUTOLOAD;
    $function =~ s,.*::,,;

    no strict 'refs';
    *$AUTOLOAD = sub { _track_function_call($function, @_) };
    goto &$AUTOLOAD;
}

1;
