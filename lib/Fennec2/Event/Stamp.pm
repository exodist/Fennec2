package Fennec2::Event::Stamp;
use strict;
use warnings;

use Time::HiRes qw/time/;
use Carp qw/croak/;

use Test::Stream::Event(
    accessors => [qw/stamp name action/],
);

sub init {
    my $self = shift;

    $self->{+STAMP} ||= time();
    $self->{+NAME}  ||= 'unknown';

    croak "'action' is a required attribute"
        unless defined $self->{+ACTION};
}

1;
