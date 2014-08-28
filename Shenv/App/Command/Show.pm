# ABSTRACT: show current environment
package Shenv::App::Command::Show;


use strict;
use warnings;
use feature 'say';

use Shenv::Client;
use Shenv::App -command;


sub execute {
    my %environment = source();
    while (my ($name, $value) = each(%environment)) {
        say("$name=$value");
    }
}


1;
