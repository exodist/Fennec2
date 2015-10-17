package Fennec2::Runner::NoIso;
use strict;
use warnings;

use Fennec2::Runner();
use Test::Stream::HashBase(
    base => 'Fennec2::Runner',
);

sub can_async { 0 }
sub wait { 1 };

sub run {
    my $self = shift;
    my ($task) = @_;
    my $unit = $task->unit;

    return $self->run_task($task)
        unless $unit->meta->{iso};

    my $ctx = $unit->context;
    $ctx->debug->set_skip("No isolation method is available");
    $ctx->ok(1, $unit->name);
}


1;
