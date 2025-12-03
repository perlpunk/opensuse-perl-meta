use v5.42;
use Test2::V0;

use Module::OpenSUSE::Meta::DB;
use Module::OpenSUSE::Meta::Package;
use FindBin qw/ $Bin /;
use File::Temp qw/ tempdir /;
use YAML::PP qw/ Load LoadFile /;

my $temp = tempdir('XXXXXX', TMPDIR => 1, CLEANUP => 1);
my $obsdir = "$Bin/data";
my $exportdir = "$temp/exportdir";
mkdir $exportdir;

my $mock_git = mock 'Module::OpenSUSE::Meta::Git' => (
    track => true,
    override => [
        commit_and_date => sub {
            return ('c0ffee', '2025-12-02');
        },
    ],
);
my $meta = Module::OpenSUSE::Meta::DB->new(obsdir => $obsdir, exportdir => $exportdir);
my $pkg = Module::OpenSUSE::Meta::Package->new(db => $meta, name => 'perl-Foo-Bar');

my $yaml = <<'EOM';
---
last_commit:
  date: 2025-12-02
  sha: c0ffee
packages:
  perl-Foo-Bar:
    last_commit:
      sha: c0ffee
      date: 2025-12-02
    build_requires:
    - perl(Module::Load)
    - perl(Test::More)
    - perl(Test::Warn)
    patches:
      - some-bugfix.patch
    cpanspec:
        patches:
          some-bugfix.patch: -p1
        preamble: 'BuildRequires: libyaml'
    requires:
    - perl(Module::Load)
    recommends:
    - perl(YAML::PP)
    version: 0.39.0
EOM
my $expected = Load $yaml;

my $data = $pkg->read_meta;
is $data, $expected->{packages}->{'perl-Foo-Bar'}, 'Module::OpenSUSE::Meta::Package metadata';
my $track = $mock_git->sub_tracking;
like $track, { commit_and_date => [{}] }, 'Module::OpenSUSE::Meta::Git mock tracking';

$meta->init;
my $exported_yaml = LoadFile "$exportdir/meta.yaml";
is $exported_yaml, $expected, 'Module::OpenSUSE::Meta::DB meta.yaml';

done_testing;
