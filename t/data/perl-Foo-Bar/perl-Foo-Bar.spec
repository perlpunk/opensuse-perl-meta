#
# spec file for package perl-Foo-Bar
#
# Copyright (c) 2025 SUSE LLC
#


%define cpan_name Foo-Bar
Name:           perl-Foo-Bar
Version:        0.39.0
Release:        0
# v0.39.0 -> normalize -> 0.39.0
%define cpan_version v0.39.0
License:        Artistic-1.0 OR GPL-1.0-or-later
Summary:        Some module
URL:            https://metacpan.org/release/%{cpan_name}
Source0:        https://cpan.metacpan.org/authors/id/T/TI/TINITA/%{cpan_name}-%{cpan_version}.tar.gz
Source1:        cpanspec.yml
Patch0:         some-bugfix.patch
BuildArch:      noarch
BuildRequires:  perl
BuildRequires:  perl-macros
BuildRequires:  perl(Module::Load)
BuildRequires:  perl(Test::More) >= 0.98
BuildRequires:  perl(Test::Warn)
Requires:       perl(Module::Load)
Recommends:     perl(YAML::PP)
%{perl_requires}

%description
Foo::Bar bla bla.

%prep
%autosetup -n %{cpan_name}-%{cpan_version} -p1

%build
perl Makefile.PL INSTALLDIRS=vendor
%make_build
