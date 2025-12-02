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

my $meta = Module::OpenSUSE::Meta::DB->new(obsdir => $obsdir, exportdir => $exportdir);
my $pkg = Module::OpenSUSE::Meta::Package->new(meta => $meta, name => 'perl-Foo-Bar');

my $yaml = <<'EOM';
---
perl-Foo-Bar:
  build_requires:
  - perl
  - perl-macros
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
  version: 0.39.0
EOM
my $expected = Load $yaml;

my $data = $pkg->read_meta;
is $data, $expected->{'perl-Foo-Bar'}, 'Module::OpenSUSE::Meta::Package metadata';

$meta->init;
my $exported_yaml = LoadFile "$exportdir/meta.yaml";
is $exported_yaml, $expected, 'Module::OpenSUSE::Meta::DB meta.yaml';

done_testing;
