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

__END__

=pod

=encoding UTF-8

=head1 NAME

Fennec2 - Test::Stream based usccessor to Fennnec

=head1 DESCRIPTION

This is a replacement for the L<Fennec> module. It is not drop-in compatible,
but it does provide all of the same functionality in one way or another.

=head1 SYNOPSIS

    use Fennec2;

    ...

    done_testing;

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2015 Chad Granum E<lt>exodist7@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut
