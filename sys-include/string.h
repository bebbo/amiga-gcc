/*
 * string.h
 *
 * Definitions for memory and string functions.
 */

#ifndef _STRING_H_
#define	_STRING_H_

#include "_ansi.h"
#include <sys/reent.h>
#include <sys/cdefs.h>
#include <sys/features.h>

#define __need_size_t
#define __need_NULL
#include <stddef.h>

#if __POSIX_VISIBLE >= 200809
#include <xlocale.h>
#endif

#if __BSD_VISIBLE
#include <strings.h>
#endif

_BEGIN_STD_C

__stdargs void *	 memchr (const void *, int, size_t);
__stdargs int 	 memcmp (const void *, const void *, size_t);
__stdargs void *	 memcpy (void *__restrict, const void *__restrict, size_t);
__stdargs void *	 memmove (void *, const void *, size_t);
__stdargs void *	 memset (void *, int, size_t);
__stdargs char 	*strcat (char *__restrict, const char *__restrict);
__stdargs char 	*strchr (const char *, int);
__stdargs int	 strcmp (const char *, const char *);
__stdargs int	 strcoll (const char *, const char *);
__stdargs char 	*strcpy (char *__restrict, const char *__restrict);
__stdargs size_t	 strcspn (const char *, const char *);
__stdargs char 	*strerror (int);
__stdargs size_t	 strlen (const char *);
__stdargs char 	*strncat (char *__restrict, const char *__restrict, size_t);
__stdargs int	 strncmp (const char *, const char *, size_t);
__stdargs char 	*strncpy (char *__restrict, const char *__restrict, size_t);
__stdargs char 	*strpbrk (const char *, const char *);
__stdargs char 	*strrchr (const char *, int);
__stdargs size_t	 strspn (const char *, const char *);
__stdargs char 	*strstr (const char *, const char *);
#ifndef _REENT_ONLY
__stdargs char 	*strtok (char *__restrict, const char *__restrict);
#endif
__stdargs size_t	 strxfrm (char *__restrict, const char *__restrict, size_t);

#if __POSIX_VISIBLE >= 200809
__stdargs int	 strcoll_l (const char *, const char *, locale_t);
__stdargs char	*strerror_l (int, locale_t);
__stdargs size_t	 strxfrm_l (char *__restrict, const char *__restrict, size_t, locale_t);
#endif
#if __MISC_VISIBLE || __POSIX_VISIBLE
__stdargs char 	*strtok_r (char *__restrict, const char *__restrict, char **__restrict);
#endif
#if __BSD_VISIBLE
__stdargs int	 timingsafe_bcmp (const void *, const void *, size_t);
__stdargs int	 timingsafe_memcmp (const void *, const void *, size_t);
#endif
#if __MISC_VISIBLE || __POSIX_VISIBLE
__stdargs void *	 memccpy (void *__restrict, const void *__restrict, int, size_t);
#endif
#if __GNU_VISIBLE
__stdargs void *	 mempcpy (void *, const void *, size_t);
__stdargs void *	 memmem (const void *, size_t, const void *, size_t);
__stdargs void *	 memrchr (const void *, int, size_t);
__stdargs void *	 rawmemchr (const void *, int);
#endif
#if __POSIX_VISIBLE >= 200809
__stdargs char 	*stpcpy (char *__restrict, const char *__restrict);
__stdargs char 	*stpncpy (char *__restrict, const char *__restrict, size_t);
#endif
#if __GNU_VISIBLE
__stdargs char	*strcasestr (const char *, const char *);
__stdargs char 	*strchrnul (const char *, int);
#endif
#if __MISC_VISIBLE || __POSIX_VISIBLE >= 200809 || __XSI_VISIBLE >= 4
__stdargs char 	*strdup (const char *);
#endif
__stdargs char 	*_strdup_r (struct _reent *, const char *);
#if __POSIX_VISIBLE >= 200809
__stdargs char 	*strndup (const char *, size_t);
#endif
__stdargs char 	*_strndup_r (struct _reent *, const char *, size_t);

/* There are two common strerror_r variants.  If you request
   _GNU_SOURCE, you get the GNU version; otherwise you get the POSIX
   version.  POSIX requires that #undef strerror_r will still let you
   invoke the underlying function, but that requires gcc support.  */
#if __GNU_VISIBLE
__stdargs char	*strerror_r (int, char *, size_t);
#elif __POSIX_VISIBLE >= 200112
# ifdef __GNUC__
__stdargs int	strerror_r (int, char *, size_t)
#ifdef __ASMNAME
             __asm__ (__ASMNAME ("__xpg_strerror_r"))
#endif
  ;
# else
__stdargs int	__xpg_strerror_r (int, char *, size_t);
#  define strerror_r __xpg_strerror_r
# endif
#endif

/* Reentrant version of strerror.  */
__stdargs char *	_strerror_r (struct _reent *, int, int, int *);

#if __BSD_VISIBLE
__stdargs size_t	strlcat (char *, const char *, size_t);
__stdargs size_t	strlcpy (char *, const char *, size_t);
#endif
#if __POSIX_VISIBLE >= 200809
__stdargs size_t	 strnlen (const char *, size_t);
#endif
#if __BSD_VISIBLE
__stdargs char 	*strsep (char **, const char *);
#endif
#if __BSD_VISIBLE
__stdargs char    *strnstr(const char *, const char *, size_t) __pure;
#endif

#if __MISC_VISIBLE
__stdargs char	*strlwr (char *);
__stdargs char	*strupr (char *);
#endif

#ifndef DEFS_H	/* Kludge to work around problem compiling in gdb */
__stdargs const char	*strsignal (int __signo);
#endif

#ifdef __CYGWIN__
__stdargs int	strtosigno (const char *__name);
#endif

#if __GNU_VISIBLE
__stdargs int	 strverscmp (const char *, const char *);
#endif

#if __GNU_VISIBLE && defined(__GNUC__)
#define strdupa(__s) \
	(__extension__ ({const char *__sin = (__s); \
			 size_t __len = strlen (__sin) + 1; \
			 char * __sout = (char *) __builtin_alloca (__len); \
			 (char *) memcpy (__sout, __sin, __len);}))
#define strndupa(__s, __n) \
	(__extension__ ({const char *__sin = (__s); \
			 size_t __len = strnlen (__sin, (__n)) + 1; \
			 char *__sout = (char *) __builtin_alloca (__len); \
			 __sout[__len-1] = '\0'; \
			 (char *) memcpy (__sout, __sin, __len-1);}))
#endif /* __GNU_VISIBLE && __GNUC__ */

/* There are two common basename variants.  If you do NOT #include <libgen.h>
   and you do

     #define _GNU_SOURCE
     #include <string.h>

   you get the GNU version.  Otherwise you get the POSIX versionfor which you
   should #include <libgen.h>i for the function prototype.  POSIX requires that
   #undef basename will still let you invoke the underlying function.  However,
   this also implies that the POSIX version is used in this case.  That's made
   sure here. */
#if __GNU_VISIBLE && !defined(basename)
# define basename basename
__stdargs char	*__nonnull ((1)) basename (const char *) __asm__(__ASMNAME("__gnu_basename"));
#endif

#include <sys/string.h>

_END_STD_C

#if __SSP_FORTIFY_LEVEL > 0
#include <ssp/string.h>
#endif

#endif /* _STRING_H_ */
