use v5.42;
use experimental 'class';

class Module::OpenSUSE::Meta::DB 0.001 {
    use autodie;
    use Module::OpenSUSE::Meta::Package;
    use YAML::PP qw/ DumpFile LoadFile /;
    use JSON::PP qw/ encode_json /;

    field $obsdir :param :reader;
    field $exportdir :param;

    method init {
        opendir(my $dh, $obsdir);
        my @dirs = grep m/^perl-/, readdir $dh;
        closedir $dh;
        my %packages;
        for my $name (sort @dirs) {
            say "=== $name";
            my $pkg = Module::OpenSUSE::Meta::Package->new(db => $self, name => $name);
            my $data = $pkg->read_meta or next;
            $packages{ $name } = $data;
        }
        my %data = (packages => \%packages);
        my ($sha, $date) = Module::OpenSUSE::Meta::Git->new(dir => $obsdir)->commit_and_date;
        $data{last_commit} = { sha => $sha, date => $date };

        $self->write_data(\%data);
    }

    method write_data ($data) {
        my $json = encode_json $data;
        DumpFile "$exportdir/meta.yaml", $data;
        open my $fh, '>', "$exportdir/meta.json";
        print $fh $json;
        close $fh;
        say "Wrote $exportdir/meta.{yaml,json}";
    }

    method update ($tmpdir) {
        my $git = Module::OpenSUSE::Meta::Git->new(
            dir => $exportdir,
            url => 'https://github.com/perlpunk/opensuse-devel-languages-perl-meta.git',
        );
        $git->clone(branch => 'gh-pages');
        my $data = LoadFile "$exportdir/meta.yaml";
        my $oldsha = $data->{last_commit}->{sha};
        say "Last sha: $oldsha";

        my $obsgit = Module::OpenSUSE::Meta::Git->new(
            dir => "$tmpdir/obsprj",
            url => 'https://src.opensuse.org/perl/_ObsPrj.git',
        );
        $obsgit->clone(branch => 'master');
        my $changedfiles = $obsgit->changedfiles($oldsha, 'HEAD');

        my %packages;
        for my $name (sort @$changedfiles) {
            say "=== $name";
            $obsgit->update_submodule($name);
            my $pkg = Module::OpenSUSE::Meta::Package->new(db => $self, name => $name);
            my $data = $pkg->read_meta or next;
            $packages{ $name } = $data;
        }

        my ($sha, $date) = Module::OpenSUSE::Meta::Git->new(dir => $obsdir)->commit_and_date;
        $data->{last_commit} = { sha => $sha, date => $date };
        warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%packages], ['packages']);
        @{$data->{packages}}{keys %packages} = values %packages;

        $self->write_data($data);
    }
}
