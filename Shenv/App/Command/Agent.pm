# ABSTRACT: run the agent daemon to manage the environment
package Shenv::App::Command::Agent;
use Shenv::App -command;


use v5.016;
use warnings;

use threads;
use threads::shared;

use POSIX;
use File::Temp;
use File::Path qw(rmtree);
use Sys::Syslog qw(:standard :macros);
use Perl::Unsafe::Signals;
use IO::Socket::UNIX;

use Shenv::Util;


sub opt_spec {
  return (
    ["kill|k", "kill the current agent process"]
  );
}


sub execute {
  my ($self, $opt, $args) = @_;

  if ($opt->{kill}) {
    my $agent_pid = $ENV{SHENV_AGENT_PID};
    unless ($agent_pid && kill('TERM', $agent_pid)) {
      say(STDERR "failed to kill agent; is agent running?");
      exit(1);
    }
    say("sent TERM to $agent_pid");
    exit();
  }

  unless (fork()) {
    POSIX::setsid();

    my $agent_dir = File::Temp::mkdtemp("/tmp/shenv-agentXXXX");
    my $agent_pipe_name = File::Temp::tempnam($agent_dir, "");
    my $agent_socket_name = File::Temp::tempnam($agent_dir, "");

    my $agent_pid = fork();

    unless ($agent_pid) {
      umask(0);
      close(STDERR);
      close(STDOUT);
      close(STDIN);

      my %environment :shared;

      $SIG{TERM} = sub {
        syslog(LOG_INFO, "Handling TERM; cleaning up and exiting");
        rmtree($agent_dir);
        exit();
      };

      openlog("shenv");

      UNSAFE_SIGNALS {
        my $input_thread = threads->create(
          sub {
            syslog(LOG_INFO, "Starting input thread");

            POSIX::mkfifo($agent_pipe_name, 0700);
            open(my $agent_pipe, "+<", $agent_pipe_name);

            while(my $line = <$agent_pipe>) {
              my ($name, $value) = set_value_pair($line, \%environment);
              syslog(LOG_DEBUG, "Set $name to $value");
            }
          });

        my $socket_thread = threads->create(
          sub {
            syslog(LOG_INFO, "Starting socket thread");

            my $listener = IO::Socket::UNIX->new(
              Type => SOCK_STREAM(),
              Local => $agent_socket_name,
              Listen => 1
            );

            while(my $connection = $listener->accept()) {
              syslog(LOG_DEBUG, "Handling connection");
              while(my ($name, $value) = each(%environment)) {
                $connection->print("$name=$value\n");
              }
              $connection->close();
            }
          });

        $input_thread->join();
        $socket_thread->join();
      };
    }
    else {
      say("SHENV_AGENT_PID=$agent_pid; export SHENV_AGENT_PID;");
      say("SHENV_AGENT_INPUT=$agent_pipe_name; export SHENV_AGENT_INPUT;");
      say("SHENV_AGENT_SOCKET=$agent_socket_name; export SHENV_AGENT_SOCKET;");
      say("echo Shenv Agent PID is $agent_pid;");
      say("echo Shenv Agent Input is $agent_pipe_name;");
      say("echo Shenv Agent Socket is $agent_socket_name;");
      exit();
    }
  } else {
    exit();
  }
}


1;
