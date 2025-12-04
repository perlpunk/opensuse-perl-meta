#!/usr/bin/perl
use v5.42;
use Getopt::Long::Descriptive;
use Module::OpenSUSE::Meta::DB;
use File::Temp qw/ tempdir /;

sub main ($opt) {
    if ($opt->{init}) {
        my $obsdir = $opt->{obs_dir};
        my $exportdir = $opt->{export_dir};
        my $meta = Module::OpenSUSE::Meta::DB->new(obsdir => $obsdir, exportdir => $exportdir);
        $meta->init;
    }
    elsif ($opt->{update}) {
        my $temp = tempdir('opensuse-perl-meta-XXXXXX', TMPDIR => 1, CLEANUP => 1);
        say "dir: $temp";
        my $obsdir = "$temp/obsprj";
        my $exportdir = "$temp/meta";
        my $meta = Module::OpenSUSE::Meta::DB->new(obsdir => $obsdir, exportdir => $exportdir);
        $meta->update($temp);
    }
}

my ($opt, $usage) = describe_options(
    'update.pl %o <some-arg>',
    [ 'obs-dir|d=s', "Directory of _ObsPrj", { required => 0 } ],
    [ 'export-dir|e=s', "Directory of export", { required => 0 } ],
    [ 'init', "Do an initial export of metadata" ],
    [ 'update', "Update data to a certain commit" ],
    [],
    [ 'verbose|v',  "print extra stuff" ],
    [ 'help',       "print usage message and exit", { shortcircuit => 1 } ],
);

main($opt) unless caller;
