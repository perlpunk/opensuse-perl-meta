use v5.42;
use experimental 'class';

class Module::OpenSUSE::Meta::Package 0.001 {
    use YAML::PP qw/ LoadFile /;
    use autodie;
    field $meta :param;
    field $name :param;

    method read_meta () {
        my $spec = $self->read_spec;
        my $cpanspec = $self->read_cpanspec or return $spec;
        $spec->{cpanspec} = $cpanspec;
        return $spec;
    }

    method read_spec () {
        my $obsdir = $meta->obsdir;
        my $specfile = "$obsdir/$name/$name.spec";
        return unless -f $specfile;

        open my $fh, '<', $specfile;
        my %meta;
        my $manualsection = '';
        while (my $line = <$fh> ) {
            if (my $manual = $line =~ m/^# MANUAL BEGIN/ ... $line =~ m/^# MANUAL END/) {
                $manualsection .= $line;
                next;
            }
            if ($line =~ m/^Version: *(\S+)/) {
                $meta{version} = $1;
                next;
            }
            if ($line =~ m/^BuildRequires: *(\S+)/) {
                push @{ $meta{build_requires} }, $1;
                next;
            }
            if ($line =~ m/^Requires: *(\S+)/) {
                push @{ $meta{requires} }, $1;
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
        my $obsdir = $meta->obsdir;
        my $cpanspec = "$obsdir/$name/cpanspec.yml";
        return unless -f $cpanspec;
        my $data = LoadFile $cpanspec;
        not defined $data->{ $_ } and delete $data->{ $_ } for keys %$data;
        not keys %{ $data->{ $_ } || {} } and delete $data->{ $_ } for qw/ patches /;
        not @{ $data->{ $_ } || [] } and delete $data->{ $_ } for qw/ sources /;
        return unless keys %$data;
        return $data;
    }
}
