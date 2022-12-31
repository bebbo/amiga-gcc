#ifndef _HEADERS_DIRENT_H
#define _HEADERS_DIRENT_H

#include <dos/exall.h>
#include <dos/dosextens.h>

struct dirent {
  ULONG d_fileno;
  USHORT d_reclen;
  UBYTE d_type;
  USHORT d_namlen;
  char d_name[256];
};

typedef struct _dirdesc {
  int dd_fd;
  struct dirent dd_ent;
  BPTR d_lock;
  ULONG d_count;
  LONG d_more;
  struct ExAllControl *d_eac;
  struct ExAllData *current;
  union {
    char ead[2048];
    struct FileInfoBlock fib;
  } _dirun;
} DIR;

#define d_ead _dirun.ead
#define d_info _dirun.fib

/*
 * File types
 */
#define	DT_UNKNOWN	 0
#define	DT_FIFO		 1
#define	DT_CHR		 2
#define	DT_DIR		 4
#define	DT_BLK		 6
#define	DT_REG		 8
#define	DT_LNK		10
#define	DT_SOCK		12
#define	DT_WHT		14

/*
** prototypes
*/
#ifndef __stdargs
#define __stdargs
#endif

__stdargs DIR *opendir(const char *dirname);
__stdargs struct dirent *readdir(DIR *dirp);
__stdargs void rewinddir(DIR *dirp);
__stdargs int closedir(DIR *dirp);

#endif /* _HEADERS_DIRENT_H */
