#ifndef __LIBNIX_SYS_REENT_H
#define __LIBNIX_SYS_REENT_H

#if !defined(__FILE_defined)
typedef struct __sFILE __FILE;
typedef __FILE FILE;
# define __FILE_defined
#endif

struct _reent;

#endif // __LIBNIX_SYS_REENT_H
