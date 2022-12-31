#ifdef __sysvnecv70_target
__stdargs double EXFUN(fast_sin,(double));
__stdargs double EXFUN(fast_cos,(double));
__stdargs double EXFUN(fast_tan,(double));

__stdargs double EXFUN(fast_asin,(double));
__stdargs double EXFUN(fast_acos,(double));
__stdargs double EXFUN(fast_atan,(double));

__stdargs double EXFUN(fast_sinh,(double));
__stdargs double EXFUN(fast_cosh,(double));
__stdargs double EXFUN(fast_tanh,(double));

__stdargs double EXFUN(fast_asinh,(double));
__stdargs double EXFUN(fast_acosh,(double));
__stdargs double EXFUN(fast_atanh,(double));

__stdargs double EXFUN(fast_abs,(double));
__stdargs double EXFUN(fast_sqrt,(double));
__stdargs double EXFUN(fast_exp2,(double));
__stdargs double EXFUN(fast_exp10,(double));
__stdargs double EXFUN(fast_expe,(double));
__stdargs double EXFUN(fast_log10,(double));
__stdargs double EXFUN(fast_log2,(double));
__stdargs double EXFUN(fast_loge,(double));


#define	sin(x)		fast_sin(x)
#define	cos(x)		fast_cos(x)
#define	tan(x)		fast_tan(x)
#define	asin(x)		fast_asin(x)
#define	acos(x)		fast_acos(x)
#define	atan(x)		fast_atan(x)
#define	sinh(x)		fast_sinh(x)
#define	cosh(x)		fast_cosh(x)
#define	tanh(x)		fast_tanh(x)
#define	asinh(x)	fast_asinh(x)
#define	acosh(x)	fast_acosh(x)
#define	atanh(x)	fast_atanh(x)
#define	abs(x)		fast_abs(x)
#define	sqrt(x)		fast_sqrt(x)
#define	exp2(x)		fast_exp2(x)
#define	exp10(x)	fast_exp10(x)
#define	expe(x)		fast_expe(x)
#define	log10(x)	fast_log10(x)
#define	log2(x)		fast_log2(x)
#define	loge(x)		fast_loge(x)

/* These functions are in assembler, they really do take floats. This
   can only be used with a real ANSI compiler */

__stdargs float EXFUN(fast_sinf,(float));
__stdargs float EXFUN(fast_cosf,(float));
__stdargs float EXFUN(fast_tanf,(float));

__stdargs float EXFUN(fast_asinf,(float));
__stdargs float EXFUN(fast_acosf,(float));
__stdargs float EXFUN(fast_atanf,(float));

__stdargs float EXFUN(fast_sinhf,(float));
__stdargs float EXFUN(fast_coshf,(float));
__stdargs float EXFUN(fast_tanhf,(float));

__stdargs float EXFUN(fast_asinhf,(float));
__stdargs float EXFUN(fast_acoshf,(float));
__stdargs float EXFUN(fast_atanhf,(float));

__stdargs float EXFUN(fast_absf,(float));
__stdargs float EXFUN(fast_sqrtf,(float));
__stdargs float EXFUN(fast_exp2f,(float));
__stdargs float EXFUN(fast_exp10f,(float));
__stdargs float EXFUN(fast_expef,(float));
__stdargs float EXFUN(fast_log10f,(float));
__stdargs float EXFUN(fast_log2f,(float));
__stdargs float EXFUN(fast_logef,(float));
#define	sinf(x)		fast_sinf(x)
#define	cosf(x)		fast_cosf(x)
#define	tanf(x)		fast_tanf(x)
#define	asinf(x)	fast_asinf(x)
#define	acosf(x)	fast_acosf(x)
#define	atanf(x)	fast_atanf(x)
#define	sinhf(x)	fast_sinhf(x)
#define	coshf(x)	fast_coshf(x)
#define	tanhf(x)	fast_tanhf(x)
#define	asinhf(x)	fast_asinhf(x)
#define	acoshf(x)	fast_acoshf(x)
#define	atanhf(x)	fast_atanhf(x)
#define	absf(x)		fast_absf(x)
#define	sqrtf(x)	fast_sqrtf(x)
#define	exp2f(x)	fast_exp2f(x)
#define	exp10f(x)	fast_exp10f(x)
#define	expef(x)	fast_expef(x)
#define	log10f(x)	fast_log10f(x)
#define	log2f(x)	fast_log2f(x)
#define	logef(x)	fast_logef(x)
/* Override the functions defined in math.h */
#endif /* __sysvnecv70_target */

