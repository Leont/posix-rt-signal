#if defined linux
#	ifndef _GNU_SOURCE
#		define _GNU_SOURCE
#	endif
#	define GNU_STRERROR_R
#endif

#include <signal.h>

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static void get_sys_error(char* buffer, size_t buffer_size) {
#ifdef _GNU_SOURCE
	const char* message = strerror_r(errno, buffer, buffer_size);
	if (message != buffer) {
		memcpy(buffer, message, buffer_size -1);
		buffer[buffer_size] = '\0';
	}
#else
	strerror_r(errno, buffer, buffer_size);
#endif
}

static void S_die_sys(pTHX_ const char* format) {
	char buffer[128];
	get_sys_error(buffer, sizeof buffer);
	Perl_croak(aTHX_ format, buffer);
}
#define die_sys(format) S_die_sys(aTHX_ format)

sigset_t* S_sv_to_sigset(pTHX_ SV* sigmask, const char* name) {
	if (!SvOK(sigmask))
		return NULL;
	if (!SvROK(sigmask) || !sv_derived_from(sigmask, "POSIX::SigSet"))
		Perl_croak(aTHX_ "%s is not of type POSIX::SigSet");
#if PERL_VERSION > 15 || PERL_VERSION == 15 && PERL_SUBVERSION > 2
	return (sigset_t *) SvPV_nolen(SvRV(sigmask));
#else
	IV tmp = SvIV((SV*)SvRV(sigmask));
	return INT2PTR(sigset_t*, tmp);
#endif
}
#define sv_to_sigset(sigmask, name) S_sv_to_sigset(aTHX_ sigmask, name)


sigset_t* S_get_sigset(pTHX_ SV* signal, const char* name) {
	if (SvROK(signal))
		return sv_to_sigset(signal, name);
	else {
		int signo = (SvIOK(signal) || looks_like_number(signal)) && SvIV(signal) ? SvIV(signal) : whichsig(SvPV_nolen(signal));
		SV* buffer = sv_2mortal(newSVpvn("", 0));
		sv_grow(buffer, sizeof(sigset_t));
		sigset_t* ret = (sigset_t*)SvPV_nolen(buffer);
		sigemptyset(ret);
		sigaddset(ret, signo);
		return ret;
	}
}
#define get_sigset(sigmask, name) S_get_sigset(aTHX_ sigmask, name)

#define NANO_SECONDS 1000000000

static void nv_to_timespec(NV input, struct timespec* output) {
	output->tv_sec  = (time_t) floor(input);
	output->tv_nsec = (long) ((input - output->tv_sec) * NANO_SECONDS);
}

#define add_entry(name, value) hv_stores(ret, name, newSViv(value))
#define add_simple(name) add_entry(#name, info.si_##name)
#define undef &PL_sv_undef

MODULE = POSIX::RT::Signal				PACKAGE = POSIX::RT::Signal

SV*
sigwait(set, timeout = undef)
	SV* set;
	SV* timeout;
	PREINIT:
		int val;
		siginfo_t info;
	PPCODE:
		if (SvOK(timeout)) {
			struct timespec timer;
			nv_to_timespec(SvNV(timeout), &timer);
			val = sigtimedwait(get_sigset(set, "set"), &info, &timer);
		}
		else {
			val = sigwaitinfo(get_sigset(set, "set"), &info);
		}
		if (val > 0) {
			HV* ret = newHV();
			add_simple(signo);
			add_simple(code);
			add_simple(errno);
			add_simple(pid);
			add_simple(uid);
			add_simple(status);
			add_simple(band);
			add_entry("value", info.si_value.sival_int);
			hv_stores(ret, "addr", newSVuv(PTR2UV(info.si_addr)));
			
			mPUSHs(newRV_noinc((SV*)ret));
		}
		else if (GIMME_V == G_VOID && errno != EAGAIN) {
			die_sys("Couldn't sigwait: %s");
		}

void
sigqueue(pid, signal, number = 0)
	int pid;
	SV* signal;
	int number;
	PREINIT:
		int ret, signo;
	CODE:
		signo = (SvIOK(signal) || looks_like_number(signal)) && SvIV(signal) ? SvIV(signal) : whichsig(SvPV_nolen(signal));
		ret = sigqueue(pid, signo, (union sigval) number);
		if (ret == 0)
			XSRETURN_YES;
		else
			die_sys("Couldn't sigqueue: %s");

