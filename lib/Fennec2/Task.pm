package Fennec2::Task;
use strict;
use warnings;

use Carp qw/confess/;

use Test::Stream::Util qw/try/;

use Test::Stream::Workflow::Task;
use Test::Stream::HashBase(
    base => 'Test::Stream::Workflow::Task',
);

sub _run_primaries {
    my $self = shift;

    my $runner = $self->runner;
    my $monitor = [];
    push @{$runner->monitor} => $monitor;

    my ($ok, $err) = try {
        $self->SUPER::_run_primaries(@_);
    };

    unless (@{$runner->monitor} && $runner->monitor->[-1] == $monitor) {
        my $error = "Internal error: Monitor stack mismatch!";
        if ($err) {
            chomp($err);
            $error .= " (After catching $err)";
            confess $error;
        }
    }

    pop @{$runner->monitor};

    $runner->wait(sets => $monitor, block => 1)
        if @$monitor;

    die $err unless $ok;

    return;
}

1;

