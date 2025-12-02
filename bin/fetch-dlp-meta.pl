#!/usr/bin/perl
use v5.42;
use Getopt::Long::Descriptive;
use Module::OpenSUSE::Meta::DB;

sub main ($opt) {
    my $obsdir = $opt->{obs_dir};
    my $exportdir = $opt->{export_dir};
    my $meta = Module::OpenSUSE::Meta::DB->new(obsdir => $obsdir, exportdir => $exportdir);
    if ($opt->{init}) {
        $meta->init;
    }
}

my ($opt, $usage) = describe_options(
    'update.pl %o <some-arg>',
    [ 'obs-dir|d=s', "Directory of _ObsPrj", { required => 1 } ],
    [ 'export-dir|e=s', "Directory of export", { required => 1 } ],
    [ 'init', "Do an initial export of metadata" ],
    [ 'update', "Update data to a certain commit" ],
    [],
    [ 'verbose|v',  "print extra stuff" ],
    [ 'help',       "print usage message and exit", { shortcircuit => 1 } ],
);

main($opt) unless caller;
