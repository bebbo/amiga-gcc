/*
 * stdlib.h
 *
 * Definitions for common types, variables, and functions.
 */

#ifndef _STDLIB_H_
#define _STDLIB_H_

#include <machine/ieeefp.h>
#include "_ansi.h"

#define __need_size_t
#define __need_wchar_t
#define __need_NULL
#include <stddef.h>
#include <errno.h>
#include <sys/_types.h>
#include <sys/reent.h>
#include <sys/cdefs.h>
#include <machine/stdlib.h>
#ifndef __STRICT_ANSI__
#include <alloca.h>
#endif

#ifdef __CYGWIN__
#include <cygwin/stdlib.h>
#endif

#if __GNU_VISIBLE
#include <xlocale.h>
#endif

_BEGIN_STD_C

typedef struct 
{
  int quot; /* quotient */
  int rem; /* remainder */
} div_t;

typedef struct 
{
  long quot; /* quotient */
  long rem; /* remainder */
} ldiv_t;

#if __ISO_C_VISIBLE >= 1999
typedef struct
{
  long long int quot; /* quotient */
  long long int rem; /* remainder */
} lldiv_t;
#endif

#ifndef __stdargs
#define __stdargs
#endif

#ifndef __compar_fn_t_defined
#define __compar_fn_t_defined
typedef __stdargs int (*__compar_fn_t) (const void *, const void *);
#endif

struct _reent;

#define EXIT_FAILURE 1
#define EXIT_SUCCESS 0

#define RAND_MAX __RAND_MAX

__stdargs int	__locale_mb_cur_max (void);

#define MB_CUR_MAX __locale_mb_cur_max()

__stdargs void	abort (void) _ATTRIBUTE ((__noreturn__));
__stdargs int	abs (int);
#if __BSD_VISIBLE
__stdargs __uint32_t arc4random (void);
__stdargs __uint32_t arc4random_uniform (__uint32_t);
__stdargs void    arc4random_buf (void *, size_t);
#endif
__stdargs int	atexit (void (*__func)(void));
__stdargs double	atof (const char *__nptr);
#if __MISC_VISIBLE
__stdargs float	atoff (const char *__nptr);
#endif
__stdargs int	atoi (const char *__nptr);
__stdargs int	_atoi_r (struct _reent *, const char *__nptr);
__stdargs long	atol (const char *__nptr);
__stdargs long	_atol_r (struct _reent *, const char *__nptr);
__stdargs void *	bsearch (const void *__key,
		       const void *__base,
		       size_t __nmemb,
		       size_t __size,
		       __compar_fn_t _compar);
__stdargs void *	calloc (size_t __nmemb, size_t __size) _NOTHROW;
__stdargs div_t	div (int __numer, int __denom);
__stdargs void	exit (int __status) _ATTRIBUTE ((__noreturn__));
__stdargs void	free (void *) _NOTHROW;
__stdargs char *  getenv (const char *__string);
__stdargs char *	_getenv_r (struct _reent *, const char *__string);
__stdargs char *	_findenv (const char *, int *);
__stdargs char *	_findenv_r (struct _reent *, const char *, int *);
#if __POSIX_VISIBLE >= 200809
extern char *suboptarg;			/* getsubopt(3) external variable */
__stdargs int	getsubopt (char **, char * const *, char **);
#endif
__stdargs long	labs (long);
__stdargs ldiv_t	ldiv (long __numer, long __denom);
__stdargs void *	malloc (size_t __size) _NOTHROW;
__stdargs int	mblen (const char *, size_t);
__stdargs int	_mblen_r (struct _reent *, const char *, size_t, _mbstate_t *);
__stdargs int	mbtowc (wchar_t *__restrict, const char *__restrict, size_t);
__stdargs int	_mbtowc_r (struct _reent *, wchar_t *__restrict, const char *__restrict, size_t, _mbstate_t *);
__stdargs int	wctomb (char *, wchar_t);
__stdargs int	_wctomb_r (struct _reent *, char *, wchar_t, _mbstate_t *);
__stdargs size_t	mbstowcs (wchar_t *__restrict, const char *__restrict, size_t);
__stdargs size_t	_mbstowcs_r (struct _reent *, wchar_t *__restrict, const char *__restrict, size_t, _mbstate_t *);
__stdargs size_t	wcstombs (char *__restrict, const wchar_t *__restrict, size_t);
__stdargs size_t	_wcstombs_r (struct _reent *, char *__restrict, const wchar_t *__restrict, size_t, _mbstate_t *);
#ifndef _REENT_ONLY
#if __BSD_VISIBLE || __POSIX_VISIBLE >= 200809
__stdargs char *	mkdtemp (char *);
#endif
#if __GNU_VISIBLE
__stdargs int	mkostemp (char *, int);
__stdargs int	mkostemps (char *, int, int);
#endif
#if __MISC_VISIBLE || __POSIX_VISIBLE >= 200112 || __XSI_VISIBLE >= 4
__stdargs int	mkstemp (char *);
#endif
#if __MISC_VISIBLE
__stdargs int	mkstemps (char *, int);
#endif
#if __BSD_VISIBLE || (__XSI_VISIBLE >= 4 && __POSIX_VISIBLE < 200112)
__stdargs char *	mktemp (char *) 
 // _ATTRIBUTE ((__deprecated__("the use of `mktemp' is dangerous; use `mkstemp' instead")))
;
#endif
#endif /* !_REENT_ONLY */
__stdargs char *	_mkdtemp_r (struct _reent *, char *);
__stdargs int	_mkostemp_r (struct _reent *, char *, int);
__stdargs int	_mkostemps_r (struct _reent *, char *, int, int);
__stdargs int	_mkstemp_r (struct _reent *, char *);
__stdargs int	_mkstemps_r (struct _reent *, char *, int);
__stdargs char *	_mktemp_r (struct _reent *, char *)
// _ATTRIBUTE ((__deprecated__("the use of `mktemp' is dangerous; use `mkstemp' instead")))
;
__stdargs void	qsort (void *__base, size_t __nmemb, size_t __size, __compar_fn_t _compar);
__stdargs int	rand (void);
__stdargs void *	realloc (void *__r, size_t __size) _NOTHROW;
#if __BSD_VISIBLE
__stdargs void	*reallocarray(void *, size_t, size_t) __result_use_check __alloc_size((2,3));
__stdargs void *	reallocf (void *__r, size_t __size);
#endif
#if __BSD_VISIBLE || __XSI_VISIBLE >= 4
__stdargs char *	realpath (const char *__restrict path, char *__restrict resolved_path);
#endif
#if __BSD_VISIBLE
__stdargs int	rpmatch (const char *response);
#endif
#if __XSI_VISIBLE
__stdargs void	setkey (const char *__key);
#endif
__stdargs void	srand (unsigned __seed);
__stdargs double	strtod (const char *__restrict __n, char **__restrict __end_PTR);
__stdargs double	_strtod_r (struct _reent *,const char *__restrict __n, char **__restrict __end_PTR);
#if __ISO_C_VISIBLE >= 1999
__stdargs float	strtof (const char *__restrict __n, char **__restrict __end_PTR);
#endif
#if __MISC_VISIBLE
/* the following strtodf interface is deprecated...use strtof instead */
# ifndef strtodf
#  define strtodf strtof
# endif
#endif
__stdargs long	strtol (const char *__restrict __n, char **__restrict __end_PTR, int __base);
__stdargs long	_strtol_r (struct _reent *,const char *__restrict __n, char **__restrict __end_PTR, int __base);
__stdargs unsigned long strtoul (const char *__restrict __n, char **__restrict __end_PTR, int __base);
__stdargs unsigned long _strtoul_r (struct _reent *,const char *__restrict __n, char **__restrict __end_PTR, int __base);

#if __GNU_VISIBLE
__stdargs double	strtod_l (const char *__restrict, char **__restrict, locale_t);
__stdargs float	strtof_l (const char *__restrict, char **__restrict, locale_t);
#ifdef _HAVE_LONG_DOUBLE
extern __stdargs long double strtold_l (const char *__restrict, char **__restrict,
			      locale_t);
#endif /* _HAVE_LONG_DOUBLE */
__stdargs long	strtol_l (const char *__restrict, char **__restrict, int, locale_t);
__stdargs unsigned long strtoul_l (const char *__restrict, char **__restrict, int,
			 locale_t __loc);
__stdargs long long strtoll_l (const char *__restrict, char **__restrict, int, locale_t);
__stdargs unsigned long long strtoull_l (const char *__restrict, char **__restrict, int,
			       locale_t __loc);
#endif

__stdargs int	system (const char *__string);

#if __SVID_VISIBLE || __XSI_VISIBLE >= 4
__stdargs long    a64l (const char *__input);
__stdargs char *  l64a (long __input);
__stdargs char *  _l64a_r (struct _reent *,long __input);
#endif
#if __MISC_VISIBLE
__stdargs int	on_exit (void (*__func)(int, void *),void *__arg);
#endif
#if __ISO_C_VISIBLE >= 1999
__stdargs void	_Exit (int __status) _ATTRIBUTE ((__noreturn__));
#endif
#if __SVID_VISIBLE || __XSI_VISIBLE
__stdargs int	putenv (const char *__string);
#endif
__stdargs int	_putenv_r (struct _reent *, char *__string);
__stdargs void *	_reallocf_r (struct _reent *, void *, size_t);
#if __BSD_VISIBLE || __POSIX_VISIBLE >= 200112
__stdargs int	setenv (const char *__string, const char *__value, int __overwrite);
#endif
__stdargs int	_setenv_r (struct _reent *, const char *__string, const char *__value, int __overwrite);

#if __XSI_VISIBLE >= 4 && __POSIX_VISIBLE < 200112
__stdargs char *	gcvt (double,int,char *);
__stdargs char *	gcvtf (float,int,char *);
__stdargs char *	fcvt (double,int,int *,int *);
__stdargs char *	fcvtf (float,int,int *,int *);
__stdargs char *	ecvt (double,int,int *,int *);
__stdargs char *	ecvtbuf (double, int, int*, int*, char *);
__stdargs char *	fcvtbuf (double, int, int*, int*, char *);
__stdargs char *	ecvtf (float,int,int *,int *);
#endif
__stdargs char *	__itoa (int, char *, int);
__stdargs char *	__utoa (unsigned, char *, int);
#if __MISC_VISIBLE
__stdargs char *	itoa (int, char *, int);
__stdargs char *	utoa (unsigned, char *, int);
#endif
#if __POSIX_VISIBLE
__stdargs int	rand_r (unsigned *__seed);
#endif

#if __SVID_VISIBLE || __XSI_VISIBLE
__stdargs double drand48 (void);
__stdargs double _drand48_r (struct _reent *);
__stdargs double erand48 (unsigned short [3]);
__stdargs double _erand48_r (struct _reent *, unsigned short [3]);
__stdargs long   jrand48 (unsigned short [3]);
__stdargs long   _jrand48_r (struct _reent *, unsigned short [3]);
__stdargs void  lcong48 (unsigned short [7]);
__stdargs void  _lcong48_r (struct _reent *, unsigned short [7]);
__stdargs long   lrand48 (void);
__stdargs long   _lrand48_r (struct _reent *);
__stdargs long   mrand48 (void);
__stdargs long   _mrand48_r (struct _reent *);
__stdargs long   nrand48 (unsigned short [3]);
__stdargs long   _nrand48_r (struct _reent *, unsigned short [3]);
__stdargs unsigned short *
       seed48 (unsigned short [3]);
__stdargs unsigned short *
       _seed48_r (struct _reent *, unsigned short [3]);
__stdargs void  srand48 (long);
__stdargs void  _srand48_r (struct _reent *, long);
#endif /* __SVID_VISIBLE || __XSI_VISIBLE */
#if __SVID_VISIBLE || __XSI_VISIBLE >= 4 || __BSD_VISIBLE
__stdargs char *	initstate (unsigned, char *, size_t);
__stdargs long	random (void);
__stdargs char *	setstate (char *);
__stdargs void	srandom (unsigned);
#endif
#if __ISO_C_VISIBLE >= 1999
__stdargs long long atoll (const char *__nptr);
#endif
__stdargs long long _atoll_r (struct _reent *, const char *__nptr);
#if __ISO_C_VISIBLE >= 1999
__stdargs long long llabs (long long);
__stdargs lldiv_t	lldiv (long long __numer, long long __denom);
__stdargs long long strtoll (const char *__restrict __n, char **__restrict __end_PTR, int __base);
#endif
__stdargs long long _strtoll_r (struct _reent *, const char *__restrict __n, char **__restrict __end_PTR, int __base);
#if __ISO_C_VISIBLE >= 1999
__stdargs unsigned long long strtoull (const char *__restrict __n, char **__restrict __end_PTR, int __base);
#endif
unsigned long long _strtoull_r (struct _reent *, const char *__restrict __n, char **__restrict __end_PTR, int __base);

#ifndef __CYGWIN__
#if __MISC_VISIBLE
__stdargs void	cfree (void *);
#endif
#if __BSD_VISIBLE || __POSIX_VISIBLE >= 200112
__stdargs int	unsetenv (const char *__string);
#endif
__stdargs int	_unsetenv_r (struct _reent *, const char *__string);
#endif /* !__CYGWIN__ */

#if __POSIX_VISIBLE >= 200112
__stdargs int __nonnull ((1)) posix_memalign (void **, size_t, size_t);
#endif

__stdargs char *	_dtoa_r (struct _reent *, double, int, int, int *, int*, char**);
#ifndef __CYGWIN__
__stdargs void *	_malloc_r (struct _reent *, size_t) _NOTHROW;
__stdargs void *	_calloc_r (struct _reent *, size_t, size_t) _NOTHROW;
__stdargs void	_free_r (struct _reent *, void *) _NOTHROW;
__stdargs void *	_realloc_r (struct _reent *, void *, size_t) _NOTHROW;
__stdargs void	_mstats_r (struct _reent *, char *);
#endif
__stdargs int	_system_r (struct _reent *, const char *);

__stdargs void	__eprintf (const char *, const char *, unsigned int, const char *);

/* There are two common qsort_r variants.  If you request
   _BSD_SOURCE, you get the BSD version; otherwise you get the GNU
   version.  We want that #undef qsort_r will still let you
   invoke the underlying function, but that requires gcc support. */
#if __GNU_VISIBLE
__stdargs void	qsort_r (void *__base, size_t __nmemb, size_t __size, __stdargs int (*_compar)(const void *, const void *, void *), void *__thunk);
#elif __BSD_VISIBLE
# ifdef __GNUC__
__stdargs void	qsort_r (void *__base, size_t __nmemb, size_t __size, void *__thunk, __stdargs int (*_compar)(void *, const void *, const void *))
             __asm__ (__ASMNAME ("__bsd_qsort_r"));
# else
__stdargs void	__bsd_qsort_r (void *__base, size_t __nmemb, size_t __size, void *__thunk, __stdargs int (*_compar)(void *, const void *, const void *));
#  define qsort_r __bsd_qsort_r
# endif
#endif

/* On platforms where long double equals double.  */
#ifdef _HAVE_LONG_DOUBLE
extern __stdargs long double _strtold_r (struct _reent *, const char *__restrict, char **__restrict);
#if __ISO_C_VISIBLE >= 1999
extern __stdargs long double strtold (const char *__restrict, char **__restrict);
#endif
#endif /* _HAVE_LONG_DOUBLE */

/*
 * If we're in a mode greater than C99, expose C11 functions.
 */
#if __ISO_C_VISIBLE >= 2011
__stdargs void *	aligned_alloc(size_t, size_t) __malloc_like __alloc_align((1))
	    __alloc_size((2));
__stdargs int	at_quick_exit(void (*)(void));
_Noreturn __stdargs void
	quick_exit(int);
#endif /* __ISO_C_VISIBLE >= 2011 */

_END_STD_C

#if __SSP_FORTIFY_LEVEL > 0
#include <ssp/stdlib.h>
#endif

#endif /* _STDLIB_H_ */
