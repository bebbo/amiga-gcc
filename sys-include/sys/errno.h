/* errno is not a global variable, because that would make using it
   non-reentrant.  Instead, its address is returned by the function
   __errno.  */

#ifndef _SYS_ERRNO_H_
#ifdef __cplusplus
extern "C" {
#endif
#define _SYS_ERRNO_H_

#ifndef __stdargs
#define __stdargs
#endif

#include <sys/reent.h>

//#ifndef __libnix__
#if 0
#ifndef _REENT_ONLY
#define errno (*__errno())
#ifdef __NO_INLINE__
extern int *__errno (void);
#else
static inline __stdargs int *
__errno ()
{
  return &_REENT->_errno;
}
#endif
#endif

#ifndef __IMPORT
#define __IMPORT
#endif

/* Please don't use these variables directly.
   Use strerror instead. */
extern __IMPORT const char * const _sys_errlist[];
extern __IMPORT int _sys_nerr;
#ifdef __CYGWIN__
extern __IMPORT const char * const sys_errlist[];
extern __IMPORT int sys_nerr;
extern __IMPORT char *program_invocation_name;
extern __IMPORT char *program_invocation_short_name;
#endif

#define __errno_r(ptr) ((ptr)->_errno)
#endif // __libnix__

#define	EPERM 1		/* Not owner */
#define	ENOENT 2	/* No such file or directory */
#define	ESRCH 3		/* No such process */
#define	EINTR 4		/* Interrupted system call */
#define	EIO 5		/* I/O error */
#define	ENXIO 6		/* No such device or address */
#define	E2BIG 7		/* Arg list too long */
#define	ENOEXEC 8	/* Exec format error */
#define	EBADF 9		/* Bad file number */
#define	ECHILD 10	/* No children */
#define	EDEADLK 11	/* Resource deadlock avoided */
#define	ENOMEM 12	/* Not enough space */
#define	EACCES 13	/* Permission denied */
#define	EFAULT 14	/* Bad address */
#define	ENOTBLK 15	/* Block device required */
#define	EBUSY 16	/* Device or resource busy */
#define	EEXIST 17	/* File exists */
#define	EXDEV 18	/* Cross-device link */
#define	ENODEV 19	/* No such device */
#define	ENOTDIR 20	/* Not a directory */
#define	EISDIR 21	/* Is a directory */
#define	EINVAL 22	/* Invalid argument */
#define	ENFILE 23	/* Too many open files in system */
#define	EMFILE 24	/* File descriptor value too large */
#define	ENOTTY 25	/* Not a character device */
#define	ETXTBSY 26	/* Text file busy */
#define	EFBIG 27	/* File too large */
#define	ENOSPC 28	/* No space left on device */
#define	ESPIPE 29	/* Illegal seek */
#define	EROFS 30	/* Read-only file system */
#define	EMLINK 31	/* Too many links */
#define	EPIPE 32	/* Broken pipe */
#define	EDOM 33		/* Mathematics argument out of domain of function */
#define	ERANGE 34	/* Result too large */

/* non-blocking and interrupt i/o */
#define	EAGAIN		35		/* Resource temporarily unavailable */
#define	EWOULDBLOCK	EAGAIN		/* Operation would block */
#define	EINPROGRESS	36		/* Operation now in progress */
#define	EALREADY	37		/* Operation already in progress */

/* ipc/network software -- argument errors */
#define	ENOTSOCK	38		/* Socket operation on non-socket */
#define	EDESTADDRREQ	39		/* Destination address required */
#define	EMSGSIZE	40		/* Message too long */
#define	EPROTOTYPE	41		/* Protocol wrong type for socket */
#define	ENOPROTOOPT	42		/* Protocol not available */
#define	EPROTONOSUPPORT	43		/* Protocol not supported */
#define	ESOCKTNOSUPPORT	44		/* Socket type not supported */
#define	EOPNOTSUPP	45		/* Operation not supported */
#define	EPFNOSUPPORT	46		/* Protocol family not supported */
#define	EAFNOSUPPORT	47		/* Address family not supported by protocol family */
#define	EADDRINUSE	48		/* Address already in use */
#define	EADDRNOTAVAIL	49		/* Can't assign requested address */

/* ipc/network software -- operational errors */
#define	ENETDOWN	50		/* Network is down */
#define	ENETUNREACH	51		/* Network is unreachable */
#define	ENETRESET	52		/* Network dropped connection on reset */
#define	ECONNABORTED	53		/* Software caused connection abort */
#define	ECONNRESET	54		/* Connection reset by peer */
#define	ENOBUFS		55		/* No buffer space available */
#define	EISCONN		56		/* Socket is already connected */
#define	ENOTCONN	57		/* Socket is not connected */
#define	ESHUTDOWN	58		/* Can't send after socket shutdown */
#define	ETOOMANYREFS	59		/* Too many references: can't splice */
#define	ETIMEDOUT	60		/* Operation timed out */
#define	ECONNREFUSED	61		/* Connection refused */

#define	ELOOP		62		/* Too many levels of symbolic links */
#define	ENAMETOOLONG	63		/* File name too long */

/* should be rearranged */
#define	EHOSTDOWN	64		/* Host is down */
#define	EHOSTUNREACH	65		/* No route to host */
#define	ENOTEMPTY	66		/* Directory not empty */

/* quotas & mush */
#define	EPROCLIM	67		/* Too many processes */
#define	EUSERS		68		/* Too many users */
#define	EDQUOT		69		/* Disc quota exceeded */

/* Network File System */
#define	ESTALE		70		/* Stale NFS file handle */
#define	EREMOTE		71		/* Too many levels of remote in path */
#define	EBADRPC		72		/* RPC struct is bad */
#define	ERPCMISMATCH	73		/* RPC version wrong */
#define	EPROGUNAVAIL	74		/* RPC prog. not avail */
#define	EPROGMISMATCH	75		/* Program version wrong */
#define	EPROCUNAVAIL	76		/* Bad procedure for program */

#define	ENOLCK		77		/* No locks available */
#define	ENOSYS		78		/* Function not implemented */

#define	EFTYPE		79		/* Inappropriate file type or format */
#define	EAUTH		80		/* Authentication error */
#define	ENEEDAUTH	81		/* Need authenticator */

#define EREMCHG 82	/* Remote address changed */
#define ELIBACC 83	/* Can't access a needed shared lib */
#define ELIBBAD 84	/* Accessing a corrupted shared lib */
#define ELIBSCN 85	/* .lib section in a.out corrupted */
#define ELIBMAX 86	/* Attempting to link in too many libs */
#define ELIBEXEC 87	/* Attempting to exec a shared library */
#define ENOTUNIQ 88	/* Given log. name not unique */
#define EBADFD 89	/* f.d. invalid for this operation */

#define	ENOMSG 91	/* No message of desired type */
#define	EIDRM 92	/* Identifier removed */
#define	ECHRNG 93	/* Channel number out of range */
#define	EL2NSYNC 94	/* Level 2 not synchronized */
#define	EL3HLT 95	/* Level 3 halted */
#define	EL3RST 96	/* Level 3 reset */
#define	ELNRNG 97	/* Link number out of range */
#define	EUNATCH 98	/* Protocol driver not attached */
#define	ENOCSI 99	/* No CSI structure available */
#define	EL2HLT 100	/* Level 2 halted */
#define EBADE 101	/* Invalid exchange */
#define EBADR 102	/* Invalid request descriptor */
#define EXFULL 103	/* Exchange full */
#define ENOANO 104	/* No anode */
#define EBADRQC 105	/* Invalid request code */
#define EBADSLT 106	/* Invalid slot */
#define EDEADLOCK 107	/* File locking deadlock error */
#define EBFONT 108	/* Bad font file fmt */
#define ENOSTR 109	/* Not a stream */
#define ENODATA 110	/* No data (for no delay io) */
#define ETIME 111	/* Stream ioctl timeout */
#define ENOSR 112	/* No stream resources */
#define ENONET 113	/* Machine is not on the network */
#define ENOPKG 114	/* Package not installed */
#define ENOLINK 115	/* Virtual circuit is gone */
#define EADV 116		/* Advertise error */
#define ESRMNT 117	/* Srmount error */
#define	ECOMM 118	/* Communication error on send */
#define EPROTO 119	/* Protocol error */
#define	EMULTIHOP 120	/* Multihop attempted */
#define	ELBIN 121	/* Inode is remote (not really error) */
#define	EDOTDOT 122	/* Cross mount point (not really error) */
#define EBADMSG 123	/* Bad message */
#define ENMFILE 124      /* No more files */
#define ENOTSUP 134		/* Not supported */
#define ENOMEDIUM 135   /* No medium (in tape drive) */
#define ENOSHARE 136    /* No such host or network path */
#define ECASECLASH 137  /* Filename exists with different case */
#define EILSEQ 138		/* Illegal byte sequence */
#define EOVERFLOW 139	/* Value too large for defined data type */
#define ECANCELED 140	/* Operation canceled */
#define ENOTRECOVERABLE 141	/* State not recoverable */
#define EOWNERDEAD 142	/* Previous owner died */
#define ESTRPIPE 143	/* Streams pipe error */

#define	ELAST		143		/* Must be equal largest errno */
#define __ELASTERROR 2000	/* Users can add values starting here */

#ifdef __cplusplus
}
#endif
#endif /* _SYS_ERRNO_H */
