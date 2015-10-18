use Fennec2 no_threads => 1, no_fork => 1;

my $x;

tests a => {async => 1, iso => 1}, sub { ok(!$x, 'a'); $x = 'a'};
tests b => {async => 1, iso => 1}, sub { ok(!$x, 'b'); $x = 'b'};
tests c => {async => 1, iso => 1}, sub { ok(!$x, 'c'); $x = 'c'};
tests d => {async => 1, iso => 1}, sub { ok(!$x, 'd'); $x = 'd'};
tests e => {async => 1, iso => 1}, sub { ok(!$x, 'e'); $x = 'e'};
tests f => {async => 1, iso => 1}, sub { ok(!$x, 'f'); $x = 'f'};
tests g => {async => 1, iso => 1}, sub { ok(!$x, 'g'); $x = 'g'};

done_testing;

die "Ooops, we leaked |$x|" if $x;
