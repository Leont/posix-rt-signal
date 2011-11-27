use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
  module_name         => 'POSIX::RT::Signal',
##{ $plugin->get_prereqs ##}
  extra_linker_flags  => [ '-lrt' ],
);

$builder->create_build_script();
