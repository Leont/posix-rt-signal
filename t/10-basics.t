#!perl -T

use strict;
use warnings;
use Test::More tests => 11;
use Test::Exception;
use Signal::More qw/sigwait sigqueue/;
use POSIX qw/sigprocmask SIG_BLOCK SIG_UNBLOCK SIGUSR1 SIGALRM/;
use Time::HiRes qw/alarm/;

sub foo { 1 }

{
	my $status = 1;
	my $should_match = 1;
	local $SIG{USR1} = sub { is($status++, $should_match, "status is $should_match") };
	kill SIGUSR1, $$;
	is($status, 2, 'Status is 2');
	$should_match = $status;
	sigqueue($$, 'USR1');
	is($status, 3, 'status is 3');
}

{
	my $sigset = POSIX::SigSet->new(SIGALRM);
	sigprocmask(SIG_BLOCK, $sigset);
	alarm .2;
	ok(!defined sigwait($sigset, 0.1), 'Nothing yet');

	my @ret = sigwait('ALRM');
	is(@ret, 2, 'Returned two elements');
	sigprocmask(SIG_UNBLOCK, $sigset);
}

{
	alarm 1;
	my $sigset = POSIX::SigSet->new(SIGUSR1);
	sigprocmask(SIG_BLOCK, $sigset);
	sigqueue($$, SIGUSR1, 42);

	my ($signo, $int) = sigwait($sigset);
	is($signo, SIGUSR1, 'Signal numer is USR1');
	is($int, 42, 'signal value is 42');
	sigprocmask(SIG_UNBLOCK, $sigset);
}

throws_ok { sigqueue($$, -1) } qr/Couldn't sigqueue: Invalid argument/, 'sigqueue dies on error in void context';

{
	my $sigset = POSIX::SigSet->new(SIGUSR1);
	throws_ok { sigwait($sigset, -1) } qr/Couldn't sigwait: Invalid argument at/;
	lives_ok { sigwait($sigset, -1) or 1 };
}
