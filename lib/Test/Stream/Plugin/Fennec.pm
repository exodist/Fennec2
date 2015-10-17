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

    my $runner = Fennec2::Runner->instance(@_);
    $meta->set_runner($runner);

    Test::Stream::Sync->post_load(sub {
        my $hub = Test::Stream::Sync->stack->top;
        $hub->follow_up(sub { $runner->wait(block => 1) });
    });
}

1;
