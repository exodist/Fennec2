use Test::Stream -Fennec, Class => ['Test::Stream::Bundle::Fennec'];

tests plugins => sub {
    is(
        [$CLASS->plugins],
        [
            meta { prop reftype => 'CODE' },
            qw{
                SRand
                UTF8
                IPC
                Mock
                Core    *
                Compare *
                Spec    *
                Exception
                Warnings
                Fennec
            },
        ],
        "Got plugin list"
    );

    like(
        dies { ${"foo"} = 1 },
        qr/while "strict refs" in use/,
        "strict is on"
    );

    like(
        warning { my $x; "empty: $x" },
        qr/uninitialized value/,
        "warnings are on"
    );

    ok(Test::Stream::IPC->polling_enabled, "polling is on");
};

done_testing;
