package Fennec2::Runner;
use strict;
use warnings;

use parent 'Test::Stream::Workflow::Runner';

use Test::Stream::Capabilities qw/CAN_REALLY_FORK CAN_THREAD/;
use Test::Stream::Util qw/try get_tid/;
use List::Util qw/min shuffle/;
use Scalar::Util qw/reftype/;
use Time::HiRes qw/sleep/;
use Carp qw/croak/;

use Test::Stream::Sync;
use Fennec2::Task;

use Test::Stream::HashBase(
    accessors => [qw/subtests max tid pid running monitor rand no_fork no_threads/],
);

sub instance {
    my $class = shift;
    my %args = @_;

    my $use_class;
    if(CAN_REALLY_FORK && !$ENV{FENNEC_NO_FORK} && !$args{no_fork}) {
        require Fennec2::Runner::Fork;
        $use_class = 'Fennec2::Runner::Fork';
    }
    elsif(CAN_THREAD && !$ENV{FENNEC_NO_THREADS} && !$args{no_threads} && eval { require threads; threads->VERSION('1.34'); 1 }) {
        require Fennec2::Runner::Threads;
        $use_class = 'Fennec2::Runner::Threads';
    }
    else {
        require Fennec2::Runner::NoIso;
        $use_class = 'Fennec2::Runner::NoIso';
    }

    return $use_class->new(
        %args,
        subtests => 1,
    );
}

sub init {
    my $self = shift;
    $self->{+TID} = get_tid();
    $self->{+PID} = $$;
    $self->{+RUNNING} = [];
    $self->{+MONITOR} = [];
    $self->{+MAX} = min(grep {defined $_} $self->{+MAX}, $ENV{FENNEC_ASYNC}) || 3;
    $self->{+RAND} = 1 unless exists $self->{+RAND};
}

sub spawn    { croak "not implemented" }
sub wait_set { croak "not implemented" }

my %SUPPORTED = map {$_ => 1} qw/todo skip iso async/;
sub verify_meta {
    my $class = shift;
    my ($unit) = @_;
    my $meta = $unit->meta or return;
    my $ctx = $unit->context;
    for my $k (keys %$meta) {
        next if $SUPPORTED{$k};
        $ctx->alert("'$k' is not a recognised meta-key");
    }
}

sub can_async {
    my $self = shift;
    return 0 unless $self->{+MAX};
    return 0 unless $self->{+TID} == get_tid();
    return 0 unless $self->{+PID} == $$;

    return 1;
}

sub split_check {
    my $self = shift;
    return if $self->{+PID} == $$ && $self->{+TID} == get_tid();

    $self->{+TID} = get_tid();
    $self->{+PID} = $$;
    $self->{+MAX} = 0;
    $self->{+RUNNING} = [];
    $self->{+MONITOR} = [];

    return;
}

sub run {
    my $self = shift;
    my %params = @_;

    $self->split_check();

    my $unit     = $params{unit};
    my $args     = $params{args};
    my $no_final = $params{no_final};
    my $iso      = $unit->meta->{iso};
    my $async    = $unit->meta->{async} && $self->can_async;

    $self->verify_meta($unit);

    if ($self->rand) {
        my $p = $unit->primary;
        @$p = shuffle @$p if ref($p) && reftype($p) eq 'ARRAY';
    }

    my $task = Fennec2::Task->new(
        unit       => $unit,
        args       => $args,
        runner     => $self,
        no_final   => $no_final,
        no_subtest => !$self->subtests($unit),
    );

    return $self->run_task($task) unless $iso || $async;

    $self->wait(block => 0) while @{$self->{+RUNNING}} >= $self->{+MAX};

    my $run = $self->spawn($task);
    my $set = [$run, $task];

    if ($async) {
        push @{$self->{+RUNNING}} => $set;
        if (@{$self->{+MONITOR}}) {
            my $list = $self->{+MONITOR}->[-1];
            push @$list => $set;
        }
    }
    else {
        $self->wait(sets => [$set], block => 1);
    }

    return;
}

sub run_task {
    my $self = shift;
    my ($task) = @_;

    my ($ok, $err) = try { $task->run };
    Test::Stream::Sync->stack->top->cull();

    # Report exceptions
    unless($ok) {
        my $ctx = $task->unit->context;
        $ctx->send_event('Exception', 'error' => $err);
    }

    return $ok;
}

sub wait {
    my $self = shift;
    my %params = @_;

    $self->split_check();

    my $sets  = $params{sets} || $self->{+RUNNING};
    my $block = $params{block};

    while (@$sets) {
        for my $set (@$sets) {
            my ($run, $task, $done) = @$set;
            local ($?, $!);

            unless ($done) {
                $done = $self->wait_set(@$set);
                Test::Stream::Sync->stack->top->cull();
            }

            if ($done) {
                push @$set => $done;
                @$sets = grep {$_ != $set} @$sets if $done;
            }
        }

        # Only loop once in non-blocking mode
        last unless $block;
        sleep(0.1) if @$sets;
    }
}

sub DESTROY {
    my $self = shift;
    $self->wait;
}

1;
