[![codecov](https://codecov.io/gh/perlpunk/opensuse-devel-languages-perl-meta/graph/badge.svg?token=YJDMPYSA5G)](https://codecov.io/gh/perlpunk/opensuse-devel-languages-perl-meta)

## Fetch metadata from devel:languages:perl packages

* https://build.opensuse.org/project/show/devel:languages:perl
* https://src.opensuse.org/perl

```
# Note: cloning with all submdules can take very long (e.g. 1h)
git clone --recurse-submodules https://src.opensuse.org/perl/_ObsPrj.git
# Generate data under ./export
perl -Ilib bin/fetch-dlp-meta.pl -d ~/oscgit/perl/_ObsPrj -e ./export --init
```
