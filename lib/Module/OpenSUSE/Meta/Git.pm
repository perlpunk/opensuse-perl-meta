use v5.42;
use experimental 'class';

class Module::OpenSUSE::Meta::Git 0.001 {
    use autodie;

    field $dir :param :reader;
    field $url :param :reader = undef;

    method commit_and_date () {
        my $cmd = "git -C $dir log --pretty=format:'%H %ad' --date=short -1";
        my ($rc, @out) = $self->execute($cmd);
        my ($sha, $date) = split ' ', $out[0];
        return ($sha, $date);
    }

    method clone (%args) {
        my $branch = $args{branch};
        my $cmd = "git clone $url ";
        if ($branch) {
            $cmd .= "-b $branch --single-branch ";
        }
        $cmd .= $dir;
        my ($rc, @out) = $self->execute($cmd);
    }

    method changedfiles ($ref1, $ref2) {
        my $cmd = "git -C $dir diff --name-only $ref1..$ref2";
        my ($rc, @out) = $self->execute($cmd);
        chomp @out;
        return \@out;
    }

    method update_submodule ($sub) {
        my $cmd = "git -C $dir submodule update --init $sub";
        my ($rc, @out) = $self->execute($cmd);
    }

    method execute ($cmd) {
        # no local config files
        local $ENV{GIT_CONFIG_NOSYSTEM} = 1;
        local $ENV{GIT_CONFIG} = '';
        local $ENV{HOME} = '';
        say "# cmd: $cmd";
        my @out = qx{$cmd};
        say "<< $_" for @out;
        return $?, @out;
    }
}
