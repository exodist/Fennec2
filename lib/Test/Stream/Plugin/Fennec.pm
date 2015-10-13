package Test::Stream::Plugin::Fennec;
use strict;
use warnings;

use Test::Stream::Plugin;
use Test::Stream::Workflow::Meta;
use Fennec2::Runner;

sub load_ts_plugin {
    my $class = shift;
    my $caller = shift;

    my $meta = Test::Stream::Workflow::Meta->build(
        $caller->[0],
        $caller->[1],
        $caller->[2],
        'EOF',
    );

    $meta->set_runner(Fennec2::Runner->instance(@_));
}

1;
