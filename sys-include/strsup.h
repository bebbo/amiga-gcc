#ifndef _STRSUP_H
#define _STRSUP_H

#include <sys/types.h>

#ifndef __NO_INLINE__

#if defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 199901L) && !defined(__MY_INLINE__)
#define __MY_INLINE__ static inline
#else
#define __MY_INLINE__ extern inline
#endif

__MY_INLINE__ __stdargs void *memmove(void *s1,const void *s2,size_t n)
{	extern __stdargs void bcopy(const void *, void *, size_t);

	bcopy(s2,s1,n); return s1;
}

__MY_INLINE__ __stdargs int memcmp(const void *s1,const void *s2,size_t n)
{
	const unsigned char *p1, *p2;

	p1 = (const unsigned char *) s1;
	p2 = (const unsigned char *) s2;
	while(n-- > 0) {
		unsigned char a, b;

		if (*p1++ == *p2++)
		continue;

		a = *--p1;
		b = *--p2;
		return (short)a - b;
	}
	return 0;
}

__MY_INLINE__ __stdargs void *memchr(const void *s,int c,size_t n)
{
	if (n) {
		unsigned char *p=(unsigned char *)s;
		do {
			if (*p++==(unsigned char)c)
			return --p;
		}while(--n);
	}
	return (void *)n;
}

__MY_INLINE__ __stdargs size_t strlen(const char *string)
{	const char *s=string;

	while(*s++) {}return ~(string-s);
}

__MY_INLINE__ __stdargs size_t strlen_plus_one(const char *string)
{	const char *s=string;

	while(*s++) {}return (s-string);
}

__MY_INLINE__ __stdargs char *strcpy(char *s1,const char *s2)
{	char *s=s1;
	while((*s1++=*s2++)) {}
	return s;
}

__MY_INLINE__ __stdargs char *strlwr(char *s)
{	unsigned char *s1=(unsigned char *)s;

	while(*s1) {
		if ((*s1>('A'-1)) && (*s1<('Z'+1)))
		*s1+='a'-'A';
		s1++;
	}
	return s;
}

__MY_INLINE__ __stdargs char *stpcpy(char *dst,const char *src)
{
	while((*dst++=*src++)){} return(--dst);
}

__MY_INLINE__ __stdargs void *mempcpy(void *to, const void *from, size_t sz) {
	return sz + (char *)memcpy(to, from, sz);
}

#endif /* __NO_inline__ */

#endif /* _STRSUP_H */
