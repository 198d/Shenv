# ABSTRACT: show current environment
package Shenv::App::Command::Show;
use Shenv::App -command;


use v5.016;
use warnings;

use Data::Dumper;

use Shenv::Client;


sub execute {
    my %environment = source();
    while (my ($name, $value) = each(%environment)) {
        say "$name=$value";
    }
}


1;
