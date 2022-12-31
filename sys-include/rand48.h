#ifndef _HEADERS_RAND48_H
#define _HEADERS_RAND48_H

__stdargs void srand48(long);
__stdargs unsigned short *seed48(unsigned short *);
__stdargs void lcong48(unsigned short *);
__stdargs long lrand48(void);
__stdargs long nrand48(unsigned short *);
__stdargs long mrand48(void);
__stdargs long jrand48(unsigned short *);
__stdargs double drand48(void);
__stdargs double erand48(unsigned short *seed);

#endif /* _HEADERS_RAND48_H */
