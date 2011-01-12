#!perl -T

use strict;
use warnings;
use Test::More tests => 8;
use Signal::More qw/sigwait sigqueue/;
use POSIX qw/sigprocmask SIG_BLOCK SIG_UNBLOCK SIGUSR1 SIGALRM/;
use Time::HiRes qw/alarm/;

{
	my $status = 1;
	my $should_match = 1;
	local $SIG{USR1} = sub { is $status++, $should_match };
	kill SIGUSR1, $$;
	is $status, 2;
	$should_match = $status;
	sigqueue($$, 'USR1');
	is $status, 3;
}

{
	my $sigset = POSIX::SigSet->new(SIGALRM);
	sigprocmask(SIG_BLOCK, $sigset);
	alarm .2;
	ok !defined sigwait($sigset, 0.1), 'Nothing yet';

	my @ret = sigwait('ALRM');
	is @ret, 2, 'Returned two elements';
	sigprocmask(SIG_UNBLOCK, $sigset);
}

{
	alarm 1;
	my $sigset = POSIX::SigSet->new(SIGUSR1);
	sigprocmask(SIG_BLOCK, $sigset);
	sigqueue($$, SIGUSR1, 42);

	my ($signo, $int) = sigwait($sigset);
	is $signo, SIGUSR1;
	is $int, 42;
	sigprocmask(SIG_UNBLOCK, $sigset);
}
