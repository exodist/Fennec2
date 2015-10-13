package Fennec2::Runner;
use strict;
use warnings;

use parent 'Test::Stream::Workflow::Runner';

use Test::Stream::Util qw/try/;
use List::Util qw/min/;

use Test::Stream::Workflow::Task;
use Test::Stream::Sync;

use Test::Stream::HashBase(
    accessors => [qw/parallel subtests/],
);

sub instance {
    my $class = shift;
    my %args = @_;

    # Default to 3 if nothing is specified
    # Never go above the 'parallel' argument
    # Never go above FENNEC_PARALLEL env var
    if (defined($ENV{FENNEC_PARALLEL})) {
        my @list = ($ENV{FENNEC_PARALLEL});
        push @list => $args{parallel} if exists $args{parallel};
        $args{parallel} = min(@list);
    }
    else {
        $args{parallel} = 3 unless exists $args{parallel};
    }

    $class->new(subtests => 1, %args)
}

my %SUPPORTED = map {$_ => 1} qw/todo skip iso sync/;
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

sub run {
    my $self = shift;
    my %params = @_;
    my $unit     = $params{unit};
    my $args     = $params{args};
    my $no_final = $params{no_final};

    $self->verify_meta($unit);

    my $task = Test::Stream::Workflow::Task->new(
        unit       => $unit,
        args       => $args,
        runner     => $self,
        no_final   => $no_final,
        no_subtest => !$self->subtests($unit),
    );

    my ($ok, $err) = try { $self->run_task($task) };
    Test::Stream::Sync->stack->top->cull();

    # Report exceptions
    unless($ok) {
        my $ctx = $unit->context;
        $ctx->ok(0, $unit->name, ["Caught Exception: $err"]);
    }

    return;
}

sub run_task {
    my $class = shift;
    my ($task) = @_;

    return $task->run();
}


1;
