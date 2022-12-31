#ifndef _STRING_H_
#define	_STRING_H_

/*
 * string.h
 *
 * Definitions for memory and string functions.
 */

#include <sys/cdefs.h>
#include <sys/types.h>
#include <stddef.h>

#ifndef	NULL
#define	NULL	0
#endif

__stdargs void *memset(void *, int, size_t);
__stdargs void *memcpy(void *, const void *, size_t);
__stdargs char *strchr(const char *, int);
__stdargs int strcoll(const char *, const char *);
__stdargs size_t strcspn(const char *, const char *);
__stdargs char *strerror(int);
__stdargs char *strcat(char *, const char *);
__stdargs char *strncat(char *, const char *, size_t);
__stdargs int strcmp(const char *, const char *);
__stdargs int strncmp(const char *, const char *, size_t);
__stdargs char *strncpy(char *, const char *, size_t);
__stdargs char *strpbrk(const char *, const char *);
__stdargs char *strrchr(const char *, int);
__stdargs size_t strspn(const char *, const char *);
__stdargs char *strstr(const char *, const char *);
__stdargs char *strtok(char *, const char *);
__stdargs char* strtok_r(char *str, const char *delim, char **nextp);
__stdargs size_t strxfrm(char *, const char *, size_t);
__stdargs char *strupr(char *s);

/* Nonstandard routines */
#ifndef _ANSI_SOURCE
__stdargs int bcmp(const void *, const void *, size_t);
__stdargs void bcopy(const void *, void *, size_t);
__stdargs void bzero(void *, size_t);
__stdargs int ffs(int);
__stdargs char *index(const char *, int);
__stdargs void *memccpy(void *, const void *, int, size_t);
__stdargs char *rindex(const char *, int);
__stdargs int strcasecmp(const char *, const char *);
__stdargs char *strdup(const char *);
__stdargs void strmode(int, char *);
__stdargs int strncasecmp(const char *, const char *, size_t);
__stdargs char *strsep(char **, const char *);
__stdargs void swab(const void *, void *, ssize_t);
__stdargs int stricmp(const char *, const char *);
__stdargs int strnicmp(const char *, const char *, size_t);

__stdargs char *strerror_r(int errnum, char *buf, size_t buflen);
#endif 

#ifdef __NO_INLINE__
__stdargs void *memmove(void *, const void *, size_t);
__stdargs int memcmp(const void *, const void *, size_t);
__stdargs void *memchr(const void *, int, size_t);
__stdargs size_t strlen(const char *);
__stdargs size_t strlen_plus_one(const char *string);
__stdargs char *strcpy(char *, const char *);
__stdargs char *strlwr(char *s);
__stdargs char *stpcpy(char *dst, const char *src);
__stdargs void *mempcpy(void *, const void *, size_t);
#else
#include "strsup.h"
#endif

#endif // _STRING_H_
