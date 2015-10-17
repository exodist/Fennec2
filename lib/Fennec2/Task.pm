package Fennec2::Task;
use strict;
use warnings;

use Test::Stream::Workflow::Task;
use Test::Stream:HashBase(
    base => 'Test::Stream::Workflow::Task',
    accessors => [qw/isolator/],
);

sub _run_primaries {
    my $self = shift;
    my $isolator = $self->isolator;


    $self->SUPER::_run_primaries(@_);


    return;
}

1;

