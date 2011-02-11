package Signal::More;

use strict;
use warnings FATAL => 'all';

our $VERSION;

use XSLoader;
use Sub::Exporter -setup => { exports => [qw/sigwait sigqueue/] };

XSLoader::load(__PACKAGE__, $VERSION);

1;    # End of Signal::More

#ABSTRACT: Various signal handling functions

__END__

=head1 SYNOPSIS

 use Signal::More qw/sigqueue sigwait/;
 use Signal::Mask;
 
 $Signal::Mask{USR1}++;
 sigqueue($$, 'USR1');
 sigwait('USR1');

=func sigqueue($pid, $sig, $value = 0)

Queue a signal $sig to process $pid, optionally with the additional argument $value. On error an exception is thrown. $sig must be either a signal number(C<14>) or a signal name (C<'ALRM'>).

=func sigwait($signals, $timeout = undef)

Wait for a signal in $signals to arrive and return it. The signal handler (if any) will not be called. Unlike signal handlers it is not affected by signal masks, in fact you are expected to mask signals you're waiting for. $signals must either be a POSIX::SigSet object, a signal number or a signal name. If $timeout is specified, it indicates the maximal time the thread is suspended in fractional seconds; if no signal is received it returns an empty list, or in void context an exception. If $timeout is not defined it may wait indefinitely until a signal arrives.

=head1 SEE ALSO

=over 4

=item * L<Signal::Mask>

=item * L<POSIX>

=back

=cut
