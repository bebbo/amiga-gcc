#ifndef _SYS_RESOURCE_H_
#define _SYS_RESOURCE_H_

#include <sys/time.h>

/*
 * Resource limit IDs
 *
 * ( Compatibility detail: there are architectures that have
 *   a different rlimit ID order in the 5-9 range and want
 *   to keep that order for binary compatibility. The reasons
 *   are historic and all new rlimits are identical across all
 *   arches. If an arch has such special order for some rlimits
 *   then it defines them prior including asm-generic/resource.h. )
 */

#define RLIMIT_CPU		0	/* CPU time in sec */
#define RLIMIT_FSIZE		1	/* Maximum filesize */
#define RLIMIT_DATA		2	/* max data size */
#define RLIMIT_STACK		3	/* max stack size */
#define RLIMIT_CORE		4	/* max core file size */

#ifndef RLIMIT_RSS
# define RLIMIT_RSS		5	/* max resident set size */
#endif

#ifndef RLIMIT_NPROC
# define RLIMIT_NPROC		6	/* max number of processes */
#endif

#ifndef RLIMIT_NOFILE
# define RLIMIT_NOFILE		7	/* max number of open files */
#endif

#ifndef RLIMIT_MEMLOCK
# define RLIMIT_MEMLOCK		8	/* max locked-in-memory address space */
#endif

#ifndef RLIMIT_AS
# define RLIMIT_AS		9	/* address space limit */
#endif

#define RLIMIT_LOCKS		10	/* maximum file locks held */
#define RLIMIT_SIGPENDING	11	/* max number of pending signals */
#define RLIMIT_MSGQUEUE		12	/* maximum bytes in POSIX mqueues */
#define RLIMIT_NICE		13	/* max nice prio allowed to raise to
					   0-39 for nice level 19 .. -20 */
#define RLIMIT_RTPRIO		14	/* maximum realtime priority */
#define RLIMIT_RTTIME		15	/* timeout for RT tasks in us */
#define RLIM_NLIMITS		16

/*
 * SuS says limits have to be unsigned.
 * Which makes a ton more sense anyway.
 *
 * Some architectures override this (for compatibility reasons):
 */
#ifndef RLIM_INFINITY
# define RLIM_INFINITY		(~0UL)
#endif

#define	RUSAGE_SELF	0		/* calling process */
#define	RUSAGE_CHILDREN	-1		/* terminated child processes */

struct rusage {
	struct timeval ru_utime; /* user time used */
	struct timeval ru_stime; /* system time used */
};

typedef unsigned rlim_t;

struct rlimit {
	rlim_t rlim_cur; /* Soft limit */
	rlim_t rlim_max; /* Hard limit (ceiling for rlim_cur) */
};

__stdargs int getrusage(int, struct rusage*);
__stdargs int getrlimit(int resource, struct rlimit *rlim);
__stdargs int setrlimit(int resource, struct rlimit *rlim);

#endif
