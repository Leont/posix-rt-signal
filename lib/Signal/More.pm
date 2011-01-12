package Signal::More;

use strict;
use warnings FATAL => 'all';

our $VERSION = '0.001';

use XSLoader;
use Sub::Exporter -setup => { exports => [qw/sigwait sigqueue/] };

XSLoader::load(__PACKAGE__, $VERSION);

1;    # End of Signal::More

__END__

=head1 NAME

Signal::More - Various signal handling functions

=head1 VERSION

Version 0.001

=head1 SYNOPSIS

 use Signal::More qw//;
 use Signal::Mask '%SIG_MASK';
 use POSIX 'SIGUSR1';
 
 $SIG_MASK{USR1}++;
 sigqueue($$, SIGUSR1);
 sigwait(POSIX::SigSet->new(SIGUSR1));

=head1 SUBROUTINES

=head2 sigqueue($pid, $sig, $value = 0)

Queue a signal $sig to process $pid, optionally with the additional argument $value. On error an exception is thrown. $sig must be either a signal number(C<14>) or a signal name (C<'ALRM'>).

=head2 sigwait($signals, $timeout = undef)

Wait for a signal in $signals to arrive and return it. The signal handler (if any) will not be called. Unlike signal handlers it is not affected by signal masks, in fact you are expected to mask signals you're waiting for. $signals must either be a POSIX::SigSet object, a signal number or a signal name. If $timeout is specified, it indicates the maximal time the thread is suspended in fractional seconds; if no signal is received it returns an empty list, or in void context an exception. If $timeout is not defined it may wait indefititely until a signal arrives.

=head1 SEE ALSO

=over 4

=item * L<Signal::Mask>

=item * L<POSIX>

=back

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-signal-more at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Signal-More>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Signal::More

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Signal-More>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Signal-More>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Signal-More>

=item * Search CPAN

L<http://search.cpan.org/dist/Signal-More/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Leon Timmermans.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
