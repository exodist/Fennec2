package Fennec2::Runner;
use strict;
use warnings;

use parent 'Test::Stream::Workflow::Runner';

use Carp qw/croak/;

use Test::Stream::HashBase(
    accessors => [qw/subtests isolator async/],
);

use Fennec2::Task;
use Fennec2::Isolator;

sub run_task { croak "run_task() is unimplemented" }

sub instance {
    my $class = shift;
    my %args = @_;

    return $class->new(
        %args,
        subtests => 1,
        isolator => Fennec2::Isolator->new(async => $args{async}),
    );
}

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

sub run {
    my $self = shift;
    my %params = @_;
    my $unit     = $params{unit};
    my $args     = $params{args};
    my $no_final = $params{no_final};

    $self->verify_meta($unit);

    my $task = Fennec2::Task->new(
        unit       => $unit,
        args       => $args,
        runner     => $self,
        no_final   => $no_final,
        isolator   => $self->{+ISOLATOR},
        no_subtest => !$self->subtests($unit),
    );

    $self->{+ISOLATOR}->run($task);

    return;
}

1;
