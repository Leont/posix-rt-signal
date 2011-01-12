use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Signal::More',
	license             => 'perl',
	dist_author         => q{Leon Timmermans <leont@cpan.org>},
	dist_version_from   => 'lib/Signal/More.pm',
	configure_requires  => {
		'Module::Build' => 0.28,
	},
	build_requires   => {
		'ExtUtils::CBuilder' => 0.15,
		'Module::Build' => 0.28,
		'Test::More'    => 0,
	},
	requires            => {
		perl            => 5.006,
		'Sub::Exporter' => 0,
	},
	meta_merge => {
		resources      => {
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Signal-More',
			repository => 'http://github.com/Leont/signal-more/tree',
		},
		keywords       => [ 'signal', 'sigqueue', 'sigwait', 'sigwaitinfo', 'sigtimedwait' ],
	},
	add_to_cleanup      => [ 'Signal-More-*' ],
	create_makefile_pl  => 'small',
	sign               => 1,
);

$builder->create_build_script();
