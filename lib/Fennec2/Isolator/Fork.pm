package Fennec2::Isolate::Fork;
use strict;
use warnings;

use POSIX;

use Scope::Guard qw/guard/;

use Fennec2::Isolator();
use Test::Stream::HashBase(
    base => 'Fennec2::Isolator',
);

sub spawn {
    my $self = shift;
    my ($task) = @_;

    my $guard = guard {
        warn "Scope Leak Detected!\n";
        CORE::exit(255);
    };

    my $pid = fork();
    die "fork() failed!" unless defined $pid;
    return $pid if $pid;

    # In Child.
    my $ok = $self->run_task($task);

    $guard->dismiss;
    exit(0) if $ok;
    exit(255);
    warn "We passed exit?!\n";
    # Try HARDER
    CORE::exit(255);
}

sub wait_set {
    my $self = shift;
    my ($pid, $task) = @_;

    my $check = waitpid($pid, &POSIX::WNOHANG);
    my $exit = $?;
    return 0 unless $check;    # Not done yet

    # Handle Problems
    if ($check == -1) {
        my $ctx    = $task->unit->context;
        my $detail = $ctx->debug->detail;
        $ctx->diag("Unable to check exit status of process $pid $detail");
    }
    elsif($exit) {
        $exit = $exit >> 8;
        my $ctx    = $task->unit->context;
        my $detail = $ctx->debug->detail;
        $ctx->send_event('Exception', 'error' => "process $pid exited badly ($exit) $detail");
    }

    return 1;
}

1;
