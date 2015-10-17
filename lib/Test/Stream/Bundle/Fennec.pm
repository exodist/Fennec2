package Test::Stream::Bundle::Fennec;
use strict;
use warnings;

use Test::Stream::Bundle;

require Test::Stream::IPC;
Test::Stream::IPC->enable_polling;

sub plugins {
    return (
        sub { strict->import(); warnings->import() },
        qw{
            SRand
            UTF8
            IPC
            Mock
            Core    *
            Compare *
            Spec    *
            Fennec
        },
    );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Stream::Bundle::Fennec - Bundle to replace the Fennec module.

=head1 DESCRIPTION

This bundle is a replacement for the L<Fennec> module. It is not drop-in
compatible, but it does provide all of the same functionality in one way or
another.

=head1 SYNOPSIS

    use Test::Stream '-Fennec';

    ...

    done_testing;

=head1 INCLUDED TOOLS

=over 4

=item strict

'strict' is turned on for you.

=item warnings

'warnings' are turned on for you.

=item Compare => '*'

This provides C<is()> and C<like()>. Unlike the 'V1' plugin ALL tools are
imported.

See L<Test::Stream::Plugin::Compare> for more details.

=item Core => *

This provides essential tools such as C<ok()>, C<done_testing()>, as well as
others.

See L<Test::Stream::Plugin::Core> for more details.

=item IPC

This loads IPC support so that threading and forking just work.

See L<Test::Stream::Plugin::IPC> for more details.

=item Mock

This provides the C<mock()> and C<mocked()> functions which can be used to do
nearly any kind of mocking you might need.

See L<Test::Stream::Plugin::Mock> for more details.

=item UTF8

This module turns on the utf8 pragma for your test file, it also sets STDERR,
STDOUT and the formatter output handles to use utf8.

See L<Test::Stream::Plugin::UTF8> for more details.

=item Spec => '*'

This plugin provides RSPEC like workflows.

See L<Test::Stream::Plugin::Spec>.

=item SRand

This plugin initiates the random seed using todays date.

=item Fennec => '*'

This plugin sets the L<Fennec2::Runner> as the Spec runner.

=back

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
