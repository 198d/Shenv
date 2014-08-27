# ABSTRACT: export a variable into the environment
package Shenv::App::Command::Export;
use Shenv::App -command;


use v5.016;
use warnings;


use Shenv::Client;


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
