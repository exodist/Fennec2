package Fennec2::Task;
use strict;
use warnings;

use Test::Stream::Workflow::Task;
use Test::Stream::HashBase(
    base => 'Test::Stream::Workflow::Task',
);

sub _run_primaries {
    my $self = shift;


    $self->SUPER::_run_primaries(@_);


    return;
}

1;

