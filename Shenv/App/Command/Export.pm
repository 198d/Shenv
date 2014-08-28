# ABSTRACT: export a variable into the environment
package Shenv::App::Command::Export;

use strict;
use warnings;
use feature 'say';

use Shenv::Client;
use Shenv::App -command;


sub validate_args {
    my ($self, $opt, $args) = @_;
    unless (scalar(@$args) == 2) {
        $self->usage_error("provide exactly 2 arguments: a name and a value");
    }
}


sub execute {
    my ($self, $opt, $args) = @_;
    my ($name, $value) = @$args;
    export($name, $value);
}


1;
