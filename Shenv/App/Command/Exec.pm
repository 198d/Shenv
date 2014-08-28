# ABSTRACT: execute a command in the current environment
package Shenv::App::Command::Exec;


use strict;
use warnings;

use IO::Socket::UNIX;

use Shenv::Client;
use Shenv::App -command;


sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("need to provide a command to execute") unless @$args;
}


sub execute {
    my ($self, $opt, $args) = @_;
    source(\%ENV);
    exec @$args;
}


1;
