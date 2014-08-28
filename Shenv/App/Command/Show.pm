# ABSTRACT: show current environment
package Shenv::App::Command::Show;


use strict;
use warnings;
use feature 'say';

use String::ShellQuote 'shell_quote';

use Shenv::Client;
use Shenv::App -command;


sub opt_spec {
    return (
        ["eval|e", "output export statements to use in shell eval"]
    )
}


sub execute {
    my ($self, $opt, $args) = @_;

    my %environment = source();

    while (my ($name, $value) = each(%environment)) {
        if ($opt->{eval}) {
            my $quoted_value = shell_quote($value);
            say("export $name=$quoted_value;");
        }
        else {
            say("$name=$value");
        }
    }
}


1;
