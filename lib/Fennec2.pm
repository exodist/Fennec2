package Fennec2;
use strict;
use warnings;

our $VERSION = "0.000001";

use parent 'Test::Stream';

require Test::Stream::IPC;
Test::Stream::IPC->enable_polling;

sub default { return qw{-Fennec} }

sub import {
    my $class = shift;
    my @caller = caller;

    unshift @_ => $class->default;

    $class->load(\@caller, @_);

    1;
}

sub opt_hide {
    shift;
    my %params = @_;
    my $list = $params{list};
    my $args = $params{args};
    my $order = $params{order};

    my $class = shift @$list;

    push @{$params{order}} => 'Test::Stream::Plugin::Hide'
        unless $args->{'Test::Stream::Plugin::Hide'};

    $args->{'Test::Stream::Plugin::Hide'} ||= [];
    push @{$args->{'Test::Stream::Plugin::Hide'}} => $class;
}

for my $arg (qw/max rand no_fork no_threads/) {
    my $sub = sub {
        shift;
        my %params = @_;
        my $list   = $params{list};
        my $args   = $params{args};
        my $order  = $params{order};

        my $val = shift @$list;

        push @{$params{order}} => 'Test::Stream::Plugin::Fennec'
            unless $args->{'Test::Stream::Plugin::Fennec'};

        $args->{'Test::Stream::Plugin::Fennec'} ||= [];
        push @{$args->{'Test::Stream::Plugin::Fennec'}} => ($arg => $val);
    };
    no strict 'refs';
    *{"opt_$arg"} = $sub;
}

1;
