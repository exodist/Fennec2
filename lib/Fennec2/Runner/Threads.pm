package Fennec2::Runner::Threads;
use strict;
use warnings;
use threads 1.34;

use Fennec2::Runner();
use Test::Stream::HashBase(
    base => 'Fennec2::Runner',
);

sub spawn {
    my $self = shift;
    my ($task) = @_;

    my $thr = 'threads'->create(sub {
        my $ok = $self->run_task($task);
        Test::Stream::Sync->stack->top->cull();
        return $ok;
    });

    die "threads->create() failed!" unless $thr;
    return $thr;
}

sub wait_set {
    my $self = shift;
    my ($thr, $task) = @_;

    return 0 unless $thr->is_joinable();

    my $check = $thr->join;

    unless ($check) {
        my $ctx = $task->unit->context;
        my $detail = $ctx->debug->detail;
        my $error = $thr->can('error') ? $thr->error : "unknown error";
        $error ||= "unknown error";
        chomp($error);
        $ctx->send_event('Exception', 'error' => "$error $detail");
    }

    return 1;
}

1;
