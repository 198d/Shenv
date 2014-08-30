# ABSTRACT: run a shell with a new agent and environment
package Shenv::App::Command::Shell;


use strict;
use warnings;
use feature 'say';

use File::Basename;

use Shenv::App -command;


sub execute {
    # stolen from perlbrew
    $ENV{SHELL} ||= readlink("/proc/" . getppid() . "/exe") if -d "/proc";
    $ENV{SHENV_EXECUTABLE} = $0;

    if ($ENV{SHELL} =~ /bash/) {
        bash();
    }
    else {
        say("current shell not supported; falling back to bash");
        bash();
    }
}


sub bash {
    my $dirname = dirname(__FILE__);
    exec($ENV{SHELL}, "--init-file", "$dirname/bashrc");
}


1;
