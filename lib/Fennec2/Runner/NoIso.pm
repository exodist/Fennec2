package Fennec2::Runner::NoIso;
use strict;
use warnings;

use Fennec2::Runner();
use Test::Stream::HashBase(
    base => 'Fennec2::Runner',
);

sub can_async { 0 }

sub spawn {
    my $self = shift;
    my ($task) = @_;

    my $unit = $task->unit;

    my $ctx = $unit->context;
    $ctx->debug->set_skip("No isolation method is available");
    $ctx->ok(1, $unit->name);

    return 1;
}

sub wait {
    my $self = shift;
    my %params = @_;

    $self->split_check();

    my $sets  = $params{sets} || $self->{+RUNNING};

    @$sets = ();
    return 1;
}

1;
