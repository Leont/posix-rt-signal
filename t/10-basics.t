#!perl

use strict;
use warnings;
use Test::More tests => 13;
use Test::Exception;
use POSIX::RT::Signal qw/sigwait sigqueue/;
use POSIX qw/sigprocmask SIG_BLOCK SIG_UNBLOCK SIGUSR1 SIGALRM setlocale LC_ALL/;

use Time::HiRes qw/alarm/;

setlocale(LC_ALL, 'C');

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

	my $ret = sigwait('ALRM');
	is(ref $ret, 'HASH', 'Return value is a hash');
	sigprocmask(SIG_UNBLOCK, $sigset);
}

{
	alarm 1;
	my $sigset = POSIX::SigSet->new(SIGUSR1);
	sigprocmask(SIG_BLOCK, $sigset);
	sigqueue($$, SIGUSR1, 42);

	my $info = sigwait($sigset);
	is($info->{signo}, SIGUSR1, 'Signal numer is USR1');
	is($info->{value}, 42, 'signal value is 42');
	is($info->{pid}, $$, "pid is $$");
	is($info->{uid}, $<, "uid is $<");
	sigprocmask(SIG_UNBLOCK, $sigset);
}

throws_ok { sigqueue($$, 65536) } qr/Couldn't sigqueue: Invalid argument/, 'sigqueue dies on error in void context';

{
	my $sigset = POSIX::SigSet->new(SIGUSR1);
	throws_ok { sigwait($sigset, -1) } qr/Couldn't sigwait: Invalid argument at/;
	lives_ok { sigwait($sigset, -1) or 1 };
}
