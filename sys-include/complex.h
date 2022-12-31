/* $NetBSD: complex.h,v 1.3 2010/09/15 16:11:30 christos Exp $ */

/*
 * Written by Matthias Drochner.
 * Public domain.
 */

#ifndef	_COMPLEX_H
#define	_COMPLEX_H

#define complex _Complex
#define _Complex_I 1.0fi
#define I _Complex_I

#include <sys/cdefs.h>

__BEGIN_DECLS

/* 7.3.5 Trigonometric functions */
/* 7.3.5.1 The cacos functions */
__stdargs double complex cacos(double complex);
__stdargs float complex cacosf(float complex);

/* 7.3.5.2 The casin functions */
__stdargs double complex casin(double complex);
__stdargs float complex casinf(float complex);
__stdargs long double complex casinl(long double complex);

/* 7.3.5.1 The catan functions */
__stdargs double complex catan(double complex);
__stdargs float complex catanf(float complex);
__stdargs long double complex catanl(long double complex);

/* 7.3.5.1 The ccos functions */
__stdargs double complex ccos(double complex);
__stdargs float complex ccosf(float complex);

/* 7.3.5.1 The csin functions */
__stdargs double complex csin(double complex);
__stdargs float complex csinf(float complex);

/* 7.3.5.1 The ctan functions */
__stdargs double complex ctan(double complex);
__stdargs float complex ctanf(float complex);

/* 7.3.6 Hyperbolic functions */
/* 7.3.6.1 The cacosh functions */
__stdargs double complex cacosh(double complex);
__stdargs float complex cacoshf(float complex);

/* 7.3.6.2 The casinh functions */
__stdargs double complex casinh(double complex);
__stdargs float complex casinhf(float complex);

/* 7.3.6.3 The catanh functions */
__stdargs double complex catanh(double complex);
__stdargs float complex catanhf(float complex);

/* 7.3.6.4 The ccosh functions */
__stdargs double complex ccosh(double complex);
__stdargs float complex ccoshf(float complex);

/* 7.3.6.5 The csinh functions */
__stdargs double complex csinh(double complex);
__stdargs float complex csinhf(float complex);

/* 7.3.6.6 The ctanh functions */
__stdargs double complex ctanh(double complex);
__stdargs float complex ctanhf(float complex);

/* 7.3.7 Exponential and logarithmic functions */
/* 7.3.7.1 The cexp functions */
__stdargs double complex cexp(double complex);
__stdargs float complex cexpf(float complex);

/* 7.3.7.2 The clog functions */
__stdargs double complex clog(double complex);
__stdargs float complex clogf(float complex);
__stdargs long double complex clogl(long double complex);

/* 7.3.8 Power and absolute-value functions */
/* 7.3.8.1 The cabs functions */
/*#ifndef __LIBM0_SOURCE__ */
/* avoid conflict with historical cabs(struct complex) */
/* double cabs(double complex) __RENAME(__c99_cabs);
   __stdargs float cabsf(float complex) __RENAME(__c99_cabsf);
   #endif
*/
__stdargs long double cabsl(long double complex) ;
__stdargs double cabs(double complex) ;
__stdargs float cabsf(float complex) ;

/* 7.3.8.2 The cpow functions */
__stdargs double complex cpow(double complex, double complex);
__stdargs float complex cpowf(float complex, float complex);

/* 7.3.8.3 The csqrt functions */
__stdargs double complex csqrt(double complex);
__stdargs float complex csqrtf(float complex);
__stdargs long double complex csqrtl(long double complex);

/* 7.3.9 Manipulation functions */
/* 7.3.9.1 The carg functions */ 
__stdargs double carg(double complex);
__stdargs float cargf(float complex);
__stdargs long double cargl(long double complex);

/* 7.3.9.2 The cimag functions */
__stdargs double cimag(double complex);
__stdargs float cimagf(float complex);
__stdargs long double cimagl(long double complex);

/* 7.3.9.3 The conj functions */
__stdargs double complex conj(double complex);
__stdargs float complex conjf(float complex);

/* 7.3.9.4 The cproj functions */
__stdargs double complex cproj(double complex);
__stdargs float complex cprojf(float complex);

/* 7.3.9.5 The creal functions */
__stdargs double creal(double complex);
__stdargs float crealf(float complex);
__stdargs long double creall(long double complex);

#if __GNU_VISIBLE
__stdargs double complex clog10(double complex);
__stdargs float complex clog10f(float complex);
#endif

#if defined(__CYGWIN__)
__stdargs long double complex cacosl(long double complex);
__stdargs long double complex ccosl(long double complex);
__stdargs long double complex csinl(long double complex);
__stdargs long double complex ctanl(long double complex);
__stdargs long double complex cacoshl(long double complex);
__stdargs long double complex casinhl(long double complex);
__stdargs long double complex catanhl(long double complex);
__stdargs long double complex ccoshl(long double complex);
__stdargs long double complex csinhl(long double complex);
__stdargs long double complex ctanhl(long double complex);
__stdargs long double complex cexpl(long double complex);
__stdargs long double complex cpowl(long double complex, long double complex);
__stdargs long double complex conjl(long double complex);
__stdargs long double complex cprojl(long double complex);
#if __GNU_VISIBLE
__stdargs long double complex clog10l(long double complex);
#endif
#endif /* __CYGWIN__ */

__END_DECLS

#endif	/* ! _COMPLEX_H */
