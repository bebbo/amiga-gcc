#ifndef _SIGNAL_H_
#define _SIGNAL_H_

#include "_ansi.h"
#include <sys/cdefs.h>
#include <sys/signal.h>

_BEGIN_STD_C

typedef int	sig_atomic_t;		/* Atomic entity type (ANSI) */
#if __BSD_VISIBLE
typedef _sig_func_ptr sig_t;		/* BSD naming */
#endif
#if __GNU_VISIBLE
typedef _sig_func_ptr sighandler_t;	/* glibc naming */
#endif

#define SIG_DFL ((_sig_func_ptr)0)	/* Default action */
#define SIG_IGN ((_sig_func_ptr)1)	/* Ignore action */
#define SIG_ERR ((_sig_func_ptr)-1)	/* Error return */

struct _reent;

__stdargs _sig_func_ptr _signal_r (struct _reent *, int, _sig_func_ptr);
__stdargs int	_raise_r (struct _reent *, int);

#ifndef _REENT_ONLY
__stdargs _sig_func_ptr signal (int, _sig_func_ptr);
__stdargs int	raise (int);
__stdargs void	psignal (int, const char *);
#endif

/*
 * SA_FLAGS values:
 *
 * SA_ONSTACK indicates that a registered stack_t will be used.
 * SA_RESTART flag to get restarting signals (which were the default long ago)
 * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
 * SA_RESETHAND clears the handler when the signal is delivered.
 * SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
 * SA_NODEFER prevents the current signal from being masked in the handler.
 *
 * SA_ONESHOT and SA_NOMASK are the historical Linux names for the Single
 * Unix names RESETHAND and NODEFER respectively.
 */
#define SA_NOCLDSTOP        0x00000001
#define SA_NOCLDWAIT        0x00000002
#define SA_SIGINFO        0x00000004
#define SA_ONSTACK        0x08000000
#define SA_RESTART        0x10000000
#define SA_NODEFER        0x40000000
#define SA_RESETHAND        0x80000000

#define SA_NOMASK        SA_NODEFER
#define SA_ONESHOT        SA_RESETHAND


_END_STD_C

#endif /* _SIGNAL_H_ */
