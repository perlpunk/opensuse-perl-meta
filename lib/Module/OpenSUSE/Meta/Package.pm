use v5.42;
use experimental 'class';

class Module::OpenSUSE::Meta::Package 0.001 {
    use autodie;
    use Module::OpenSUSE::Meta::Git;
    use YAML::PP qw/ LoadFile /;
    field $db :param;
    field $name :param;

    method read_meta () {
        my $spec = $self->read_spec;
        if (my $cpanspec = $self->read_cpanspec) {
            $spec->{cpanspec} = $cpanspec;
        }
        my ($sha, $date) = Module::OpenSUSE::Meta::Git->new(dir => $self->dir)->commit_and_date;
        $spec->{last_commit} = { sha => $sha, date => $date };
        return $spec;
    }

    method dir () {
        my $obsdir = $db->obsdir;
        return "$obsdir/$name";
    }

    method read_spec () {
        my $obsdir = $db->obsdir;
        my $specfile = "$obsdir/$name/$name.spec";
        return unless -f $specfile;

        open my $fh, '<', $specfile;
        my %meta;
        my $manualsection = '';
        while (my $line = <$fh> ) {
            if ($line =~ m/^# MANUAL BEGIN/ ... $line =~ m/^# MANUAL END/) {
                $manualsection .= $line;
                next;
            }
            if ($line =~ m/^Version: *(\S+)/) {
                $meta{version} = $1;
                next;
            }
            if ($line =~ m/^BuildRequires: *(\S+)/) {
                my $req = $1;
                next if $req =~ m/^perl(-macros)?$/;
                push @{ $meta{build_requires} }, $req;
                next;
            }
            if ($line =~ m/^Requires: *(\S+)/) {
                push @{ $meta{requires} }, $1;
                next;
            }
            if ($line =~ m/^Recommends: *(\S+)/) {
                push @{ $meta{recommends} }, $1;
                next;
            }
            if ($line =~ m/^Provides: *(\S+)/) {
                push @{ $meta{provides} }, $1;
                next;
            }
            if ($line =~ m/^Patch\d*: *(\S+)/) {
                push @{ $meta{patches} }, $1;
                next;
            }
        }
        $meta{manualsections} = $manualsection if $manualsection;
        close $fh;
        return \%meta;
    }

    method read_cpanspec () {
        my $obsdir = $db->obsdir;
        my $cpanspec = "$obsdir/$name/cpanspec.yml";
        return unless -f $cpanspec;
        my $data = LoadFile $cpanspec;
        not defined $data->{ $_ } and delete $data->{ $_ } for keys %$data;
        not keys %{ $data->{ $_ } || {} } and delete $data->{ $_ }
            for qw/ patches /;
        $data->{sources} = [ $data->{sources} ]
            if $data->{sources} and not ref $data->{sources};
        not @{ $data->{ $_ } || [] } and delete $data->{ $_ }
            for qw/ sources /;
        return unless keys %$data;
        return $data;
    }
}
