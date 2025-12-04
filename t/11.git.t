use v5.42;
use Test2::V0;

use Module::OpenSUSE::Meta::Git;
use FindBin qw/ $Bin /;
use File::Temp qw/ tempdir /;

subtest commit_and_date => sub {
    my $git = Module::OpenSUSE::Meta::Git->new(dir => "$Bin/data/gitdir/.gitdummy");
    my ($sha, $date) = $git->commit_and_date;
    is $sha, '7a6560347a8bea31b6e3e55d474b184a4ef5e849', 'correct sha';
    is $date, '2025-12-02', 'correct date';
};

subtest clone => sub {
    my $temp = tempdir('XXXXXX', TMPDIR => 1, CLEANUP => 1);
    my $git = Module::OpenSUSE::Meta::Git->new(dir => $temp, url => "$Bin/data/gitdir/.gitdummy");
    $git->clone;
    my ($sha, $date) = $git->commit_and_date;
    is $sha, '7a6560347a8bea31b6e3e55d474b184a4ef5e849', 'correct sha';
    is $date, '2025-12-02', 'correct date';
};

done_testing;
