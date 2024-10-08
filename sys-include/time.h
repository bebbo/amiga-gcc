/*
 * time.h
 * 
 * Struct and function declarations for dealing with time.
 */

#ifndef _TIME_H_
#define _TIME_H_

#include "_ansi.h"
#include <sys/cdefs.h>
#include <sys/reent.h>

#define __need_size_t
#define __need_NULL
#include <stddef.h>

/* Get _CLOCKS_PER_SEC_ */
#include <machine/time.h>

#ifndef _CLOCKS_PER_SEC_
#define _CLOCKS_PER_SEC_ 1000
#endif

#define CLOCKS_PER_SEC _CLOCKS_PER_SEC_
#define CLK_TCK CLOCKS_PER_SEC

#include <sys/types.h>
#include <sys/timespec.h>

#if __POSIX_VISIBLE >= 200809
#include <xlocale.h>
#endif

_BEGIN_STD_C

struct tm
{
  int	tm_sec;
  int	tm_min;
  int	tm_hour;
  int	tm_mday;
  int	tm_mon;
  int	tm_year;
  int	tm_wday;
  int	tm_yday;
  int	tm_isdst;
#ifdef __TM_GMTOFF
  long	__TM_GMTOFF;
#endif
#ifdef __TM_ZONE
  const char *__TM_ZONE;
#endif
};

__stdargs clock_t	   clock (void);
__stdargs double	   difftime (time_t _time2, time_t _time1);
__stdargs time_t	   mktime (struct tm *_timeptr);
__stdargs time_t	   time (time_t *_timer);
#ifndef _REENT_ONLY
__stdargs char	  *asctime (const struct tm *_tblock);
__stdargs char	  *ctime (const time_t *_time);
__stdargs struct tm *gmtime (const time_t *_timer);
__stdargs struct tm *localtime (const time_t *_timer);
#endif
__stdargs size_t	   strftime (char *__restrict _s,
			     size_t _maxsize, const char *__restrict _fmt,
			     const struct tm *__restrict _t);

#if __POSIX_VISIBLE >= 200809
extern __stdargs size_t strftime_l (char *__restrict _s, size_t _maxsize,
			  const char *__restrict _fmt,
			  const struct tm *__restrict _t, locale_t _l);
#endif

__stdargs char	  *asctime_r 	(const struct tm *__restrict,
				 char *__restrict);
__stdargs char	  *ctime_r 	(const time_t *, char *);
__stdargs struct tm *gmtime_r 	(const time_t *__restrict,
				 struct tm *__restrict);
__stdargs struct tm *localtime_r 	(const time_t *__restrict,
				 struct tm *__restrict);

_END_STD_C

#ifdef __cplusplus
extern "C" {
#endif

#if __XSI_VISIBLE
__stdargs char      *strptime (const char *__restrict,
				 const char *__restrict,
				 struct tm *__restrict);
#endif
#if __GNU_VISIBLE
__stdargs char *strptime_l (const char *__restrict, const char *__restrict,
		  struct tm *__restrict, locale_t);
#endif

#if __POSIX_VISIBLE
__stdargs void      tzset 	(void);
#endif
__stdargs void      _tzset_r 	(struct _reent *);

typedef struct __tzrule_struct
{
  char ch;
  int m;
  int n;
  int d;
  int s;
  time_t change;
  long offset; /* Match type of _timezone. */
} __tzrule_type;

typedef struct __tzinfo_struct
{
  int __tznorth;
  int __tzyear;
  __tzrule_type __tzrule[2];
} __tzinfo_type;

__stdargs __tzinfo_type *__gettzinfo (void);

/* getdate functions */

#ifdef HAVE_GETDATE
#if __XSI_VISIBLE >= 4
#ifndef _REENT_ONLY
#define getdate_err (*__getdate_err())
__stdargs int *__getdate_err (void);

__stdargs struct tm *	getdate (const char *);
/* getdate_err is set to one of the following values to indicate the error.
     1  the DATEMSK environment variable is null or undefined,
     2  the template file cannot be opened for reading,
     3  failed to get file status information,
     4  the template file is not a regular file,
     5  an error is encountered while reading the template file,
     6  memory allication failed (not enough memory available),
     7  there is no line in the template that matches the input,
     8  invalid input specification  */
#endif /* !_REENT_ONLY */
#endif /* __XSI_VISIBLE >= 4 */

#if __GNU_VISIBLE
/* getdate_r returns the error code as above */
__stdargs int		getdate_r (const char *, struct tm *);
#endif /* __GNU_VISIBLE */
#endif /* HAVE_GETDATE */

extern long * __timezone;
extern int  * __daylight;
extern char **__tzname;

//#define timezone (*__timezone)
//#define daylight (*__daylight)
#define _timezone (*__timezone)
#define _daylight (*__daylight)

#define _tzname (*__tzname)
#ifndef tzname
#define tzname (*__tzname)
#endif

#ifdef __cplusplus
}
#endif

#include <sys/features.h>

#ifdef __CYGWIN__
#include <cygwin/time.h>
#endif /*__CYGWIN__*/

/* Clocks, P1003.1b-1993, p. 263 */

//__stdargs int clock_settime (clockid_t clock_id, const struct timespec *tp);
__stdargs int clock_gettime (clockid_t clock_id, struct timespec *tp);
__stdargs int clock_getres (clockid_t clock_id, struct timespec *res);

#if defined(_POSIX_TIMERS)

#include <signal.h>

#ifdef __cplusplus
extern "C" {
#endif



/* Create a Per-Process Timer, P1003.1b-1993, p. 264 */

__stdargs int timer_create (clockid_t clock_id,
 	struct sigevent *__restrict evp,
	timer_t *__restrict timerid);

/* Delete a Per_process Timer, P1003.1b-1993, p. 266 */

__stdargs int timer_delete (timer_t timerid);

/* Per-Process Timers, P1003.1b-1993, p. 267 */

__stdargs int timer_settime (timer_t timerid, int flags,
	const struct itimerspec *__restrict value,
	struct itimerspec *__restrict ovalue);
__stdargs int timer_gettime (timer_t timerid, struct itimerspec *value);
__stdargs int timer_getoverrun (timer_t timerid);

/* High Resolution Sleep, P1003.1b-1993, p. 269 */

__stdargs int nanosleep (const struct timespec  *rqtp, struct timespec *rmtp);

#ifdef __cplusplus
}
#endif
#endif /* _POSIX_TIMERS */

#if defined(_POSIX_CLOCK_SELECTION)

#ifdef __cplusplus
extern "C" {
#endif

__stdargs int clock_nanosleep (clockid_t clock_id, int flags,
	const struct timespec *rqtp, struct timespec *rmtp);

#ifdef __cplusplus
}
#endif

#endif /* _POSIX_CLOCK_SELECTION */

#ifdef __cplusplus
extern "C" {
#endif

/* CPU-time Clock Attributes, P1003.4b/D8, p. 54 */

/* values for the clock enable attribute */

#define CLOCK_ENABLED  1  /* clock is enabled, i.e. counting execution time */
#define CLOCK_DISABLED 0  /* clock is disabled */

/* values for the pthread cputime_clock_allowed attribute */

#define CLOCK_ALLOWED    1 /* If a thread is created with this value a */
                           /*   CPU-time clock attached to that thread */
                           /*   shall be accessible. */
#define CLOCK_DISALLOWED 0 /* If a thread is created with this value, the */
                           /*   thread shall not have a CPU-time clock */
                           /*   accessible. */

/* Manifest Constants, P1003.1b-1993, p. 262 */

#define CLOCK_REALTIME (clockid_t)1

/* Flag indicating time is "absolute" with respect to the clock
   associated with a time.  */

#define TIMER_ABSTIME	4

/* Manifest Constants, P1003.4b/D8, p. 55 */

#if defined(_POSIX_CPUTIME)

/* When used in a clock or timer function call, this is interpreted as
   the identifier of the CPU_time clock associated with the PROCESS
   making the function call.  */

#define CLOCK_PROCESS_CPUTIME_ID (clockid_t)2

#endif

#if defined(_POSIX_THREAD_CPUTIME)

/*  When used in a clock or timer function call, this is interpreted as
    the identifier of the CPU_time clock associated with the THREAD
    making the function call.  */

#define CLOCK_THREAD_CPUTIME_ID (clockid_t)3

#endif

#if 1 //defined(_POSIX_MONOTONIC_CLOCK)

/*  The identifier for the system-wide monotonic clock, which is defined
 *      as a clock whose value cannot be set via clock_settime() and which 
 *          cannot have backward clock jumps. */

#define CLOCK_MONOTONIC (clockid_t)4

#endif

#if defined(_POSIX_CPUTIME)

/* Accessing a Process CPU-time CLock, P1003.4b/D8, p. 55 */

__stdargs int clock_getcpuclockid (pid_t pid, clockid_t *clock_id);

#endif /* _POSIX_CPUTIME */

#if defined(_POSIX_CPUTIME) || defined(_POSIX_THREAD_CPUTIME)

/* CPU-time Clock Attribute Access, P1003.4b/D8, p. 56 */

__stdargs int clock_setenable_attr (clockid_t clock_id, int attr);
__stdargs int clock_getenable_attr (clockid_t clock_id, int *attr);

#endif /* _POSIX_CPUTIME or _POSIX_THREAD_CPUTIME */

#if !__BSD_VISIBLE
#ifndef timeradd
void timeradd(struct timeval *a, struct timeval *b, struct timeval *res);
#endif
#ifndef timersub
void timersub(struct timeval *a, struct timeval *b, struct timeval *res);
#endif
#endif

#ifdef __cplusplus
}
#endif

#endif /* _TIME_H_ */

