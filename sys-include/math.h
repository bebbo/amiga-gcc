#ifndef  _MATH_H_

#define  _MATH_H_

#include <sys/reent.h>
#include <sys/cdefs.h>
#include <machine/ieeefp.h>
#include "_ansi.h"

_BEGIN_STD_C

/* Natural log of 2 */
#define _M_LN2        0.693147180559945309417

#if __GNUC_PREREQ (3, 3)
 /* gcc >= 3.3 implicitly defines builtins for HUGE_VALx values.  */

# ifndef HUGE_VAL
#  define HUGE_VAL (__builtin_huge_val())
# endif

# ifndef HUGE_VALF
#  define HUGE_VALF (__builtin_huge_valf())
# endif

# ifndef HUGE_VALL
#  define HUGE_VALL (__builtin_huge_vall())
# endif

# ifndef INFINITY
#  define INFINITY (__builtin_inff())
# endif

# ifndef NAN
#  define NAN (__builtin_nanf(""))
# endif

#else /* !gcc >= 3.3  */

 /*      No builtins.  Use fixed defines instead.  (All 3 HUGE plus the INFINITY
  * and NAN macros are required to be constant expressions.  Using a variable--
  * even a static const--does not meet this requirement, as it cannot be
  * evaluated at translation time.)
  *      The infinities are done using numbers that are far in excess of
  * something that would be expected to be encountered in a floating-point
  * implementation.  (A more certain way uses values from float.h, but that is
  * avoided because system includes are not supposed to include each other.)
  *      This method might produce warnings from some compilers.  (It does in
  * newer GCCs, but not for ones that would hit this #else.)  If this happens,
  * please report details to the Newlib mailing list.  */

 #ifndef HUGE_VAL
  #define HUGE_VAL (1.0e999999999)
 #endif

 #ifndef HUGE_VALF
  #define HUGE_VALF (1.0e999999999F)
 #endif

 #if !defined(HUGE_VALL)  &&  defined(_HAVE_LONG_DOUBLE)
  #define HUGE_VALL (1.0e999999999L)
 #endif

 #if !defined(INFINITY)
  #define INFINITY (HUGE_VALF)
 #endif

 #if !defined(NAN)
  #if defined(__GNUC__)  &&  defined(__cplusplus)
    /* Exception:  older g++ versions warn about the divide by 0 used in the
     * normal case (even though older gccs do not).  This trick suppresses the
     * warning, but causes errors for plain gcc, so is only used in the one
     * special case.  */
    static const union { __ULong __i[1]; float __d; } __Nanf = {0x7FC00000};
    #define NAN (__Nanf.__d)
  #else
    #define NAN (0.0F/0.0F)
  #endif
 #endif

#endif /* !gcc >= 3.3  */

/* Reentrant ANSI C functions.  */

#ifndef __stdargs
#define __stdargs
#endif

#ifndef __math_68881
extern __stdargs double atan (double);
extern __stdargs double cos (double);
extern __stdargs double sin (double);
extern __stdargs double tan (double);
extern __stdargs double tanh (double);
extern __stdargs double frexp (double, int *);
extern __stdargs double modf (double, double *);
extern __stdargs double ceil (double);
extern __stdargs double fabs (double);
extern __stdargs double floor (double);
#endif /* ! defined (__math_68881) */

/* Non reentrant ANSI C functions.  */

#ifndef _REENT_ONLY
#ifndef __math_68881
extern __stdargs double acos (double);
extern __stdargs double asin (double);
extern __stdargs double atan2 (double, double);
extern __stdargs double cosh (double);
extern __stdargs double sinh (double);
extern __stdargs double exp (double);
extern __stdargs double ldexp (double, int);
extern __stdargs double log (double);
extern __stdargs double log10 (double);
extern __stdargs double pow (double, double);
extern __stdargs double sqrt (double);
extern __stdargs double fmod (double, double);
#endif /* ! defined (__math_68881) */
#endif /* ! defined (_REENT_ONLY) */

#if __MISC_VISIBLE
extern __stdargs int finite (double);
extern __stdargs int finitef (float);
extern __stdargs int finitel (long double);
extern __stdargs int isinff (float);
extern __stdargs int isnanf (float);
#ifdef __CYGWIN__ /* not implemented in newlib yet */
extern __stdargs int isinfl (long double);
extern __stdargs int isnanl (long double);
#endif
#if !defined(__cplusplus) || __cplusplus < 201103L
extern __stdargs int isinf (double);
#endif
#endif /* __MISC_VISIBLE */
#if (__MISC_VISIBLE || (__XSI_VISIBLE && __XSI_VISIBLE < 600)) \
  && (!defined(__cplusplus) || __cplusplus < 201103L)
extern __stdargs int isnan (double);
#endif

#if __ISO_C_VISIBLE >= 1999
/* ISO C99 types and macros. */

/* FIXME:  FLT_EVAL_METHOD should somehow be gotten from float.h (which is hard,
 * considering that the standard says the includes it defines should not
 * include other includes that it defines) and that value used.  (This can be
 * solved, but autoconf has a bug which makes the solution more difficult, so
 * it has been skipped for now.)  */
#if !defined(FLT_EVAL_METHOD) && defined(__FLT_EVAL_METHOD__)
  #define FLT_EVAL_METHOD __FLT_EVAL_METHOD__
  #define __TMP_FLT_EVAL_METHOD
#endif /* FLT_EVAL_METHOD */
#if defined FLT_EVAL_METHOD
  #if FLT_EVAL_METHOD == 0
    typedef float  float_t;
    typedef double double_t;
   #elif FLT_EVAL_METHOD == 1
    typedef double float_t;
    typedef double double_t;
   #elif FLT_EVAL_METHOD == 2
    typedef long double float_t;
    typedef long double double_t;
   #else
    /* Implementation-defined.  Assume float_t and double_t have been
     * defined previously for this configuration (e.g. config.h). */
  #endif
#else
    /* Assume basic definitions.  */
    typedef float  float_t;
    typedef double double_t;
#endif
#if defined(__TMP_FLT_EVAL_METHOD)
  #undef FLT_EVAL_METHOD
#endif

#define FP_NAN         0
#define FP_INFINITE    1
#define FP_ZERO        2
#define FP_SUBNORMAL   3
#define FP_NORMAL      4

#ifndef FP_ILOGB0
# define FP_ILOGB0 (-__INT_MAX__)
#endif
#ifndef FP_ILOGBNAN
# define FP_ILOGBNAN __INT_MAX__
#endif

#ifndef MATH_ERRNO
# define MATH_ERRNO 1
#endif
#ifndef MATH_ERREXCEPT
# define MATH_ERREXCEPT 2
#endif
#ifndef math_errhandling
# define math_errhandling MATH_ERRNO
#endif

extern __stdargs int __isinff (float x);
extern __stdargs int __isinfd (double x);
extern __stdargs int __isnanf (float x);
extern __stdargs int __isnand (double x);
extern __stdargs int __fpclassifyf (float x);
extern __stdargs int __fpclassifyd (double x);
extern __stdargs int __signbitf (float x);
extern __stdargs int __signbitd (double x);

/* Note: isinf and isnan were once functions in newlib that took double
 *       arguments.  C99 specifies that these names are reserved for macros
 *       supporting multiple floating point types.  Thus, they are
 *       now defined as macros.  Implementations of the old functions
 *       taking double arguments still exist for compatibility purposes
 *       (prototypes for them are earlier in this header).  */

#if __GNUC_PREREQ (4, 4)
  #define fpclassify(__x) (__builtin_fpclassify (FP_NAN, FP_INFINITE, \
						 FP_NORMAL, FP_SUBNORMAL, \
						 FP_ZERO, __x))
  #ifndef isfinite
    #define isfinite(__x)	(__builtin_isfinite (__x))
  #endif
  #ifndef isinf
    #define isinf(__x) (__builtin_isinf_sign (__x))
  #endif
  #ifndef isnan
    #define isnan(__x) (__builtin_isnan (__x))
  #endif
  #define isnormal(__x) (__builtin_isnormal (__x))
#else
  #define fpclassify(__x) \
	  ((sizeof(__x) == sizeof(float))  ? __fpclassifyf(__x) : \
	  __fpclassifyd(__x))
  #ifndef isfinite
    #define isfinite(__y) \
	    (__extension__ ({int __cy = fpclassify(__y); \
			     __cy != FP_INFINITE && __cy != FP_NAN;}))
  #endif
  #ifndef isinf
    #define isinf(__x) (fpclassify(__x) == FP_INFINITE)
  #endif
  #ifndef isnan
    #define isnan(__x) (fpclassify(__x) == FP_NAN)
  #endif
  #define isnormal(__x) (fpclassify(__x) == FP_NORMAL)
#endif

#if __GNUC_PREREQ (4, 0)
  #if defined(_HAVE_LONG_DOUBLE)
    #define signbit(__x) \
	    ((sizeof(__x) == sizeof(float))  ? __builtin_signbitf(__x) : \
	     (sizeof(__x) == sizeof(double)) ? __builtin_signbit (__x) : \
					       __builtin_signbitl(__x))
  #else
    #define signbit(__x) \
	    ((sizeof(__x) == sizeof(float))  ? __builtin_signbitf(__x) : \
					       __builtin_signbit (__x))
  #endif
#else
  #define signbit(__x) \
	  ((sizeof(__x) == sizeof(float))  ?  __signbitf(__x) : \
		  __signbitd(__x))
#endif

#if __GNUC_PREREQ (2, 97)
#define isgreater(__x,__y)	(__builtin_isgreater (__x, __y))
#define isgreaterequal(__x,__y)	(__builtin_isgreaterequal (__x, __y))
#define isless(__x,__y)		(__builtin_isless (__x, __y))
#define islessequal(__x,__y)	(__builtin_islessequal (__x, __y))
#define islessgreater(__x,__y)	(__builtin_islessgreater (__x, __y))
#define isunordered(__x,__y)	(__builtin_isunordered (__x, __y))
#else
#define isgreater(x,y) \
          (__extension__ ({__typeof__(x) __x = (x); __typeof__(y) __y = (y); \
                           !isunordered(__x,__y) && (__x > __y);}))
#define isgreaterequal(x,y) \
          (__extension__ ({__typeof__(x) __x = (x); __typeof__(y) __y = (y); \
                           !isunordered(__x,__y) && (__x >= __y);}))
#define isless(x,y) \
          (__extension__ ({__typeof__(x) __x = (x); __typeof__(y) __y = (y); \
                           !isunordered(__x,__y) && (__x < __y);}))
#define islessequal(x,y) \
          (__extension__ ({__typeof__(x) __x = (x); __typeof__(y) __y = (y); \
                           !isunordered(__x,__y) && (__x <= __y);}))
#define islessgreater(x,y) \
          (__extension__ ({__typeof__(x) __x = (x); __typeof__(y) __y = (y); \
                           !isunordered(__x,__y) && (__x < __y || __x > __y);}))

#define isunordered(a,b) \
          (__extension__ ({__typeof__(a) __a = (a); __typeof__(b) __b = (b); \
                           fpclassify(__a) == FP_NAN || fpclassify(__b) == FP_NAN;}))
#endif

/* Non ANSI double precision functions.  */

extern __stdargs double infinity (void);
extern __stdargs double nan (const char *);
extern __stdargs double copysign (double, double);
extern __stdargs double logb (double);
extern __stdargs int ilogb (double);

extern __stdargs double asinh (double);
extern __stdargs double cbrt (double);
extern __stdargs double nextafter (double, double);
extern __stdargs double rint (double);
extern __stdargs double scalbn (double, int);

extern __stdargs double exp2 (double);
extern __stdargs double scalbln (double, long int);
extern __stdargs double tgamma (double);
extern __stdargs double nearbyint (double);
extern __stdargs long int lrint (double);
extern __stdargs long long int llrint (double);
extern __stdargs double round (double);
extern __stdargs long int lround (double);
extern __stdargs long long int llround (double);
extern __stdargs double trunc (double);
extern __stdargs double remquo (double, double, int *);
extern __stdargs double fdim (double, double);
extern __stdargs double fmax (double, double);
extern __stdargs double fmin (double, double);
extern __stdargs double fma (double, double, double);

#ifndef __math_68881
extern __stdargs double log1p (double);
extern __stdargs double expm1 (double);
#endif /* ! defined (__math_68881) */

#ifndef _REENT_ONLY
extern __stdargs double acosh (double);
extern __stdargs double atanh (double);
extern __stdargs double remainder (double, double);
extern __stdargs double gamma (double);
extern __stdargs double lgamma (double);
extern __stdargs double erf (double);
extern __stdargs double erfc (double);
extern __stdargs double log2 (double);
#if !defined(__cplusplus)
#define log2(x) (log (x) / _M_LN2)
#endif

#ifndef __math_68881
extern __stdargs double hypot (double, double);
#endif

#endif /* ! defined (_REENT_ONLY) */

/* Single precision versions of ANSI functions.  */

extern __stdargs float atanf (float);
extern __stdargs float cosf (float);
extern __stdargs float sinf (float);
extern __stdargs float tanf (float);
extern __stdargs float tanhf (float);
extern __stdargs float frexpf (float, int *);
extern __stdargs float modff (float, float *);
extern __stdargs float ceilf (float);
extern __stdargs float fabsf (float);
extern __stdargs float floorf (float);

#ifndef _REENT_ONLY
extern __stdargs float acosf (float);
extern __stdargs float asinf (float);
extern __stdargs float atan2f (float, float);
extern __stdargs float coshf (float);
extern __stdargs float sinhf (float);
extern __stdargs float expf (float);
extern __stdargs float ldexpf (float, int);
extern __stdargs float logf (float);
extern __stdargs float log10f (float);
extern __stdargs float powf (float, float);
extern __stdargs float sqrtf (float);
extern __stdargs float fmodf (float, float);
#endif /* ! defined (_REENT_ONLY) */

/* Other single precision functions.  */

extern __stdargs float exp2f (float);
extern __stdargs float scalblnf (float, long int);
extern __stdargs float tgammaf (float);
extern __stdargs float nearbyintf (float);
extern __stdargs long int lrintf (float);
extern __stdargs long long int llrintf (float);
extern __stdargs float roundf (float);
extern __stdargs long int lroundf (float);
extern __stdargs long long int llroundf (float);
extern __stdargs float truncf (float);
extern __stdargs float remquof (float, float, int *);
extern __stdargs float fdimf (float, float);
extern __stdargs float fmaxf (float, float);
extern __stdargs float fminf (float, float);
extern __stdargs float fmaf (float, float, float);

extern __stdargs float infinityf (void);
extern __stdargs float nanf (const char *);
extern __stdargs float copysignf (float, float);
extern __stdargs float logbf (float);
extern __stdargs int ilogbf (float);

extern __stdargs float asinhf (float);
extern __stdargs float cbrtf (float);
extern __stdargs float nextafterf (float, float);
extern __stdargs float rintf (float);
extern __stdargs float scalbnf (float, int);
extern __stdargs float log1pf (float);
extern __stdargs float expm1f (float);

#ifndef _REENT_ONLY
extern __stdargs float acoshf (float);
extern __stdargs float atanhf (float);
extern __stdargs float remainderf (float, float);
extern __stdargs float gammaf (float);
extern __stdargs float lgammaf (float);
extern __stdargs float erff (float);
extern __stdargs float erfcf (float);
extern __stdargs float log2f (float);
extern __stdargs float hypotf (float, float);
#endif /* ! defined (_REENT_ONLY) */

/* Newlib doesn't fully support long double math functions so far.
   On platforms where long double equals double the long double functions
   simply call the double functions.  On Cygwin the long double functions
   are implemented independently from newlib to be able to use optimized
   assembler functions despite using the Microsoft x86_64 ABI. */
#if defined (_LDBL_EQ_DBL) || defined (__CYGWIN__)
/* Reentrant ANSI C functions.  */
#ifndef __math_68881
extern __stdargs long double atanl (long double);
extern __stdargs long double cosl (long double);
extern __stdargs long double sinl (long double);
extern __stdargs long double tanl (long double);
extern __stdargs long double tanhl (long double);
extern __stdargs long double frexpl (long double, int *);
extern __stdargs long double modfl (long double, long double *);
extern __stdargs long double ceill (long double);
extern __stdargs long double fabsl (long double);
extern __stdargs long double floorl (long double);
extern __stdargs long double log1pl (long double);
extern __stdargs long double expm1l (long double);
#endif /* ! defined (__math_68881) */
/* Non reentrant ANSI C functions.  */
#ifndef _REENT_ONLY
#ifndef __math_68881
extern __stdargs long double acosl (long double);
extern __stdargs long double asinl (long double);
extern __stdargs long double atan2l (long double, long double);
extern __stdargs long double coshl (long double);
extern __stdargs long double sinhl (long double);
extern __stdargs long double expl (long double);
extern __stdargs long double ldexpl (long double, int);
extern __stdargs long double logl (long double);
extern __stdargs long double log10l (long double);
extern __stdargs long double powl (long double, long double);
extern __stdargs long double sqrtl (long double);
extern __stdargs long double fmodl (long double, long double);
extern __stdargs long double hypotl (long double, long double);
#endif /* ! defined (__math_68881) */
#endif /* ! defined (_REENT_ONLY) */
extern __stdargs long double copysignl (long double, long double);
extern __stdargs long double nanl (const char *);
extern __stdargs int ilogbl (long double);
extern __stdargs long double asinhl (long double);
extern __stdargs long double cbrtl (long double);
extern __stdargs long double nextafterl (long double, long double);
extern __stdargs float nexttowardf (float, long double);
extern __stdargs double nexttoward (double, long double);
extern __stdargs long double nexttowardl (long double, long double);
extern __stdargs long double logbl (long double);
extern __stdargs long double log2l (long double);
extern __stdargs long double rintl (long double);
extern __stdargs long double scalbnl (long double, int);
extern __stdargs long double exp2l (long double);
extern __stdargs long double scalblnl (long double, long);
extern __stdargs long double tgammal (long double);
extern __stdargs long double nearbyintl (long double);
extern __stdargs long int lrintl (long double);
extern __stdargs long long int llrintl (long double);
extern __stdargs long double roundl (long double);
extern __stdargs long lroundl (long double);
extern __stdargs long long int llroundl (long double);
extern __stdargs long double truncl (long double);
extern __stdargs long double remquol (long double, long double, int *);
extern __stdargs long double fdiml (long double, long double);
extern __stdargs long double fmaxl (long double, long double);
extern __stdargs long double fminl (long double, long double);
extern __stdargs long double fmal (long double, long double, long double);
#ifndef _REENT_ONLY
extern __stdargs long double acoshl (long double);
extern __stdargs long double atanhl (long double);
extern __stdargs long double remainderl (long double, long double);
extern __stdargs long double lgammal (long double);
extern __stdargs long double erfl (long double);
extern __stdargs long double erfcl (long double);
#endif /* ! defined (_REENT_ONLY) */
#else /* !_LDBL_EQ_DBL && !__CYGWIN__ */
extern __stdargs long double hypotl (long double, long double);
extern __stdargs long double sqrtl (long double);
#ifdef __i386__
/* Other long double precision functions.  */
extern __stdargs _LONG_DOUBLE rintl (_LONG_DOUBLE);
extern __stdargs long int lrintl (_LONG_DOUBLE);
extern __stdargs long long int llrintl (_LONG_DOUBLE);
#endif /* __i386__ */
#endif /* !_LDBL_EQ_DBL && !__CYGWIN__ */

#endif /* __ISO_C_VISIBLE >= 1999 */

#if __MISC_VISIBLE
extern __stdargs double drem (double, double);
extern __stdargs float dremf (float, float);
#ifdef __CYGWIN__
extern __stdargs float dreml (long double, long double);
#endif /* __CYGWIN__ */
extern __stdargs double gamma_r (double, int *);
extern __stdargs double lgamma_r (double, int *);
extern __stdargs float gammaf_r (float, int *);
extern __stdargs float lgammaf_r (float, int *);
#endif

#if __MISC_VISIBLE || __XSI_VISIBLE
extern __stdargs double y0 (double);
extern __stdargs double y1 (double);
extern __stdargs double yn (int, double);
extern __stdargs double j0 (double);
extern __stdargs double j1 (double);
extern __stdargs double jn (int, double);
#endif

#if __MISC_VISIBLE || __XSI_VISIBLE >= 600
extern __stdargs float y0f (float);
extern __stdargs float y1f (float);
extern __stdargs float ynf (int, float);
extern __stdargs float j0f (float);
extern __stdargs float j1f (float);
extern __stdargs float jnf (int, float);
#endif

/* GNU extensions */
#if __GNU_VISIBLE
extern __stdargs void sincos (double, double *, double *);
extern __stdargs void sincosf (float, float *, float *);
#ifdef __CYGWIN__
extern __stdargs void sincosl (long double, long double *, long double *);
#endif /* __CYGWIN__ */
# ifndef exp10
extern __stdargs double exp10 (double);
# endif
# ifndef pow10
extern __stdargs double pow10 (double);
# endif
# ifndef exp10f
extern __stdargs float exp10f (float);
# endif
# ifndef pow10f
extern __stdargs float pow10f (float);
# endif
#ifdef __CYGWIN__
# ifndef exp10l
extern __stdargs float exp10l (float);
# endif
# ifndef pow10l
extern __stdargs float pow10l (float);
# endif
#endif /* __CYGWIN__ */
#endif /* __GNU_VISIBLE */

#if __MISC_VISIBLE || __XSI_VISIBLE
/* The gamma functions use a global variable, signgam.  */
#ifndef _REENT_ONLY
#define signgam (*__signgam())
extern __stdargs int *__signgam (void);
#endif /* ! defined (_REENT_ONLY) */

#define __signgam_r(ptr) _REENT_SIGNGAM(ptr)
#endif /* __MISC_VISIBLE || __XSI_VISIBLE */

#if __SVID_VISIBLE
/* The exception structure passed to the matherr routine.  */
/* We have a problem when using C++ since `exception' is a reserved
   name in C++.  */
#ifdef __cplusplus
struct __exception
#else
struct exception
#endif
{
  int type;
  char *name;
  double arg1;
  double arg2;
  double retval;
  int err;
};

#ifdef __cplusplus
extern __stdargs int matherr (struct __exception *e);
#else
extern __stdargs int matherr (struct exception *e);
#endif

/* Values for the type field of struct exception.  */

#define DOMAIN 1
#define SING 2
#define OVERFLOW 3
#define UNDERFLOW 4
#define TLOSS 5
#define PLOSS 6

#endif /* __SVID_VISIBLE */

/* Useful constants.  */

#if __BSD_VISIBLE || __XSI_VISIBLE

#define MAXFLOAT	3.40282347e+38F

#define M_E		2.7182818284590452354
#define M_LOG2E		1.4426950408889634074
#define M_LOG10E	0.43429448190325182765
#define M_LN2		_M_LN2
#define M_LN10		2.30258509299404568402
#define M_PI		3.14159265358979323846
#define M_PI_2		1.57079632679489661923
#define M_PI_4		0.78539816339744830962
#define M_1_PI		0.31830988618379067154
#define M_2_PI		0.63661977236758134308
#define M_2_SQRTPI	1.12837916709551257390
#define M_SQRT2		1.41421356237309504880
#define M_SQRT1_2	0.70710678118654752440

#endif

#if __BSD_VISIBLE

#define M_TWOPI         (M_PI * 2.0)
#define M_3PI_4		2.3561944901923448370E0
#define M_SQRTPI        1.77245385090551602792981
#define M_LN2LO         1.9082149292705877000E-10
#define M_LN2HI         6.9314718036912381649E-1
#define M_SQRT3	1.73205080756887719000
#define M_IVLN10        0.43429448190325182765 /* 1 / log(10) */
#define M_LOG2_E        _M_LN2
#define M_INVLN2        1.4426950408889633870E0  /* 1 / log(2) */

/* Global control over fdlibm error handling.  */

enum __fdlibm_version
{
  __fdlibm_ieee = -1,
  __fdlibm_svid,
  __fdlibm_xopen,
  __fdlibm_posix
};

#define _LIB_VERSION_TYPE enum __fdlibm_version
#define _LIB_VERSION __fdlib_version

extern __IMPORT _LIB_VERSION_TYPE _LIB_VERSION;

#define _IEEE_  __fdlibm_ieee
#define _SVID_  __fdlibm_svid
#define _XOPEN_ __fdlibm_xopen
#define _POSIX_ __fdlibm_posix

#endif /* __BSD_VISIBLE */

_END_STD_C

#ifdef __FAST_MATH__
#include <machine/fastmath.h>
#endif

#endif /* _MATH_H_ */
