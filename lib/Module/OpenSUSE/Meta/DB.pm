use v5.42;
use experimental 'class';

use Module::OpenSUSE::Meta::Package;

class Module::OpenSUSE::Meta::DB 0.001 {
    use autodie;
    use YAML::PP qw/ DumpFile /;
    use JSON::PP qw/ encode_json /;

    field $obsdir :param :reader;
    field $exportdir :param;

    method init {
        opendir(my $dh, $obsdir);
        my @dirs = grep m/^perl-/, readdir $dh;
        closedir $dh;
        my %packages;
        for my $dir (sort @dirs) {
            say "=== $dir";
            my $pkg = Module::OpenSUSE::Meta::Package->new(meta => $self, name => $dir);
            my $data = $pkg->read_meta or next;
            $packages{ $dir } = $data;
        }

        my $json = encode_json \%packages;
        DumpFile "$exportdir/meta.yaml", \%packages;
        open my $fh, '>', "$exportdir/meta.json";
        print $fh $json;
        close $fh;
        say "Wrote $exportdir/meta.{yaml,json}";
    }
}
