/*  mconf.h  */

#ifndef _MCONF_H
#define _MCONF_H

/* Constant definitions for math error conditions
 */

#define DOMAIN		1	/* argument domain error */
#define SING		2	/* argument singularity */
#define OVERFLOW	3	/* overflow range error */
#define UNDERFLOW	4	/* underflow range error */
#define TLOSS		5	/* total loss of precision */
#define PLOSS		6	/* partial loss of precision */

#define EDOM		33
#define ERANGE		34

#define MIEEE 1
#define ANSIC 1

#define mtherr(a,b) errno=(b),perror(a)

#include <stdio.h>
#include <string.h>
#include "umath.h"
#include "stabs.h"

extern int errno;


#define MAXLOGF	(88.02969187150841f)
#define MINLOGF	(-103.278929903431851103f) /* log(2^-149) */
#define MAXNUMF	(1.7014117331926442990585209174225846272e38f)
#define LOG2EF	(1.44269504088896341f)
#define LOGE2F	(0.693147180559945309f)
#define SQRTHF	(0.707106781186547524f)
#define PIF	(3.141592653589793238f)
#define PIO2F	(1.5707963267948966192f)
#define PIO4F	(0.7853981633974483096f)
#define MACHEPF	(5.9604644775390625E-8f)

#define MFALIAS(_t,_f) \
  ALIAS(_f##f,_f); \
  ALIAS(_f##l,_f); \
  _t _f

#endif /* _MCONF_H */
