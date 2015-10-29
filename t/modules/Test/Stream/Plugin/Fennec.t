use Test::Stream -V1, Spec, Fennec, Class => ['Test::Stream::Plugin::Fennec'];

tests meta => sub {
    my $meta = Test::Stream::Workflow::Meta->get(__PACKAGE__);
    ok($meta, "got meta");
    isa_ok($meta, 'Test::Stream::Workflow::Meta');
    isa_ok($meta->runner, 'Fennec2::Runner');
};

done_testing;
