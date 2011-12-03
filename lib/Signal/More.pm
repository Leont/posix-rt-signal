package Signal::More;

use strict;
use warnings FATAL => 'all';

use POSIX::RT::Signal qw/sigwait sigqueue/;
use Sub::Exporter -setup => { exports => [qw/sigwait sigqueue/] };

1;

#ABSTRACT: Various signal handling functions, legacy name

__END__

=head1 DESCRIPTION

This is the old name of L<POSIX::RT::Signal>. This is only available for legacy purposes and will be removed at some point in the future. For a description of the functions it exports, see POSIX::RT::Signal.

=cut

