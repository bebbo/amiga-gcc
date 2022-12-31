#ifndef _UMATH_H
#define _UMATH_H

#include <stdlib.h>
#include <proto/utility.h>

#include <proto/mathieeedoubtrans.h>
#include <proto/mathieeedoubbas.h>

#ifndef PI
# define PI 3.14159265358979323846
#endif

#define acos(_x)   IEEEDPAcos(_x)
#define asin(_x)   IEEEDPAsin(_x)
#define atan(_x)   IEEEDPAtan(_x)
#define atan(_x)   IEEEDPAtan(_x)
#define ceil(_x)   IEEEDPCeil(_x)
#define cos(_x)    IEEEDPCos(_x)
#define cosh(_x)   IEEEDPCosh(_x)
#define exp(_x)    IEEEDPExp(_x)
#define fabs(_x)   IEEEDPAbs(_x)
#define floor(_x)  IEEEDPFloor(_x)
#define log(_x)    IEEEDPLog(_x)
#define log10(_x)  IEEEDPLog10(_x)
#define pow(_x,_y) IEEEDPPow(_y,_x)
#define sin(_x)    IEEEDPSin(_x)
#define sinh(_x)   IEEEDPSinh(_x)
#define sqrt(_x)   IEEEDPSqrt(_x)
#define tan(_x)    IEEEDPTan(_x)
#define tanh(_x)   IEEEDPTanh(_x)

#define atan2(_y,_x)  \
({typeof(_y) y = (_y); \
  typeof(_x) x = (_x);  \
  (x>=y?(x>=-y?atan(y/x):-PI/2-atan(x/y)): \
  (x>=-y?PI/2-atan(x/y):(y>=0?PI+atan(y/x):-PI+atan(y/x)))); \
})

#define fmod(_x,_y)  \
({typeof(_x) x = (_x);\
  typeof(_y) y = (_y); \
  double a=x/y; \
  ((a>=0) ? (x-y*floor(a)):(x-y*ceil(a))); \
})

#define modf(_x,_p) \
({double x = (_x); \
  double *p = (_p); \
  ((x<0)?((*p=ceil(x))-x):(x-(*p=floor(x)))); \
})

#define round(_x) \
({typeof(_x) x = (_x); \
  (( x > 0.0 )?floor(x+0.5):ceil(x-0.5)); \
})



#endif /* _UMATH_H */
