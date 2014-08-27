package Shenv::Client;


use v5.016;
use warnings;

use IO::Socket::UNIX;
use Exporter qw(import);

use Shenv::Util;


sub export {
    my ($name, $value) = @_;
    open(my $agent_input, ">", $ENV{SHENV_AGENT_INPUT});
    say($agent_input "$name=$value");
}


sub source {
    my $environment = shift || {};
    my $connection = IO::Socket::UNIX->new(
        Type => SOCK_STREAM(),
        Peer => $ENV{SHENV_AGENT_SOCKET}
    );

    while (my $line = <$connection>) {
        set_value_pair($line, $environment);
    }

    return %$environment;
}


our @EXPORT = qw(export source);
