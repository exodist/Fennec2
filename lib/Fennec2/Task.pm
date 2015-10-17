package Fennec2::Task;
use strict;
use warnings;

use Carp qw/confess/;

use Test::Stream::Workflow::Task;
use Test::Stream::HashBase(
    base => 'Test::Stream::Workflow::Task',
);

sub _run_primaries {
    my $self = shift;

    my $runner = $self->runner;
    my $monitor = [];
    push @{$runner->monitor} => $monitor;

    $self->SUPER::_run_primaries(@_);

    confess "Internal error: Monitor stack mismatch!"
        unless @{$runner->monitor} && $runner->monitor->[-1] == $monitor;

    pop @{$runner->monitor};

    $runner->wait(sets => $monitor, block => 1)
        if @$monitor;

    return;
}

1;

