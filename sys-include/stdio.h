#ifndef _STDIO_H
#define _STDIO_H
#include <string.h>
#include <stdarg.h>

/* Adjusted to be compatible with the bsd headers
 * (At least for normal ANSI stuff)
 * Member names are not the same, but they need not be :-)
 */

typedef long fpos_t;

#ifndef __SFILE_DEFINED__
#define __SFILE_DEFINED__

/*
 * Stdio buffers.
 *
 * This and __FILE are defined here because we need them for struct _reent,
 * but we don't want stdio.h included when stdlib.h is.
 */

struct __sbuf {
	unsigned char *_base;
	int _size;
};

struct __sFILE {
	unsigned char *_p; /* pointer to actual character */
	int _r; /* Bytes left in buffer for reading, writemode: 0 */
	int _w; /* Space left in buffer for writing + fp->linebufsize,
	 * readmode: 0
	 */
	short _flags;
#define __SLBF	0x0001	  /* line buffered */
#define __SNBF	0x0002	  /* unbuffered */
#define __SRD	0x0004	  /* read mode */
#define __SWR	0x0008	  /* write mode */
#define	__SRW   0x0010    /* read and write allowed */
#define __SEOF	0x0020	  /* EOF read */
#define __SERR	0x0040	  /* error encountered */
#define __SMBF	0x0080	  /* buffer malloc'ed by library */
#define __SSTR	0x0200	  /* sprintf/sscanf buffer */
#define __SWO	0x8000	  /* write-only mode */


#define __BPTRS 0x4000	/* tmpdir and name are BPTRS. */

	short file; /* The filehandle */
	struct __sbuf _bf;
//  unsigned char *buffer;  /* original buffer pointer */
//  int bufsize;		  /* size of the buffer */
	int linebufsize; /* 0 full buffered
	 * -bufsize line buffered&write mode
	 * readmode: undefined */
	/* from this point on not binary compatible to bsd headers */
	unsigned char unget[4]; /* ungetc buffer 4 bytes necessary (for -Na*)
	 * ANSI requires 3 bytes (for -.*), so one more
	 * doesn't matter
	 */
	unsigned char *tmpp; /* Stored p if ungetc pending, otherwise NULL */
	int tmpinc; /* Stored incount if ungetc pending, otherwise undefined */
	long tmpdir; /* lock to directory if temporary file */
	char *name; /* filename if temporary file */
#ifdef __posix_threads__
	unsigned __spinlock[2];
#endif
};

#ifdef __posix_threads__
extern void __regargs __spinLock(unsigned * l);
inline void __regargs __spinUnlock(unsigned * l) {
	if (--l[1] == 0)
		*l = 0;
}
#define __STDIO_LOCK(l) __spinLock(l->__spinlock)
#define __STDIO_UNLOCK(l) __spinUnlock(l->__spinlock)
#else
#define __spinLock(a)
#define __spinUnlock(a)
#define __STDIO_LOCK(l)
#define __STDIO_UNLOCK(l)
#endif

#if !defined(__FILE_defined)
typedef struct __sFILE __FILE;
typedef __FILE FILE;
# define __FILE_defined
#endif
#endif

#ifndef NULL
#define NULL ((void *)0l)
#endif
#define BUFSIZ 1024
#define EOF (-1)
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#define _IOFBF 0
#define _IOLBF 1
#define _IONBF 2

extern __stdargs FILE *fopen(const char *filename, const char *mode);
extern __stdargs FILE *freopen(const char *filename, const char *mode, FILE *stream);
extern __stdargs FILE *fdopen(int filedes, const char *mode);
extern __stdargs int fclose(FILE *stream);
extern __stdargs int ungetc(int c, FILE *stream);
extern __stdargs int vsprintf(char *s, const char *format, va_list args);
extern __stdargs int vfprintf(FILE *stream, const char *format, va_list args);
extern __stdargs int vsscanf(const char *s, const char *format, va_list args);
extern __stdargs int vfscanf(FILE *stream, const char *format, va_list args);
extern __stdargs int vsnprintf(char *s, size_t size, const char *format, va_list args);
extern __stdargs int fseek(FILE *stream, long int offset, int whence);
extern __stdargs char *fgets(char *s, int size, FILE *stream);
extern __stdargs int fputs(const char *s, FILE *stream);
extern __stdargs long ftell(FILE *stream);
extern __stdargs int setvbuf(FILE *stream, char *buf, int mode, size_t size);
extern __stdargs size_t fread(void *, size_t, size_t, FILE *);
extern __stdargs size_t fwrite(const void *, size_t, size_t, FILE *);
extern __stdargs char *tmpnam(char *buf);
extern __stdargs void perror(const char *string);
extern __stdargs int puts(const char *s);
extern __stdargs int remove(const char *filename);
extern __stdargs int rename(const char *old, const char *neww);
extern __stdargs FILE *tmpfile(void);

/* More bsd headers compatibility */

extern __stdargs int __swbuf(int c, FILE *stream);
extern __stdargs int __srget(FILE *stream);
extern FILE **__sF; /* Standard I/O streams */
#define stdin  (__sF[0]) /* Other streams are not in __sF */
#define stdout (__sF[1])
#define stderr (__sF[2])

extern __stdargs int fprintf(FILE *stream, const char *format, ...);
extern __stdargs int fscanf(FILE *stream, const char *format, ...);
extern __stdargs int printf(const char *format, ...);
extern __stdargs int scanf(const char *format, ...);
extern __stdargs int sscanf(const char *s, const char *format, ...);
extern __stdargs int snprintf(char *s, size_t size, const char *format, ...);
extern __stdargs int sprintf(char *s, const char *format, ...);

extern __stdargs int asprintf(char **__restrict strp, const char *__restrict fmt, ...);

extern __stdargs int getc(FILE *fp);
extern __stdargs int putc(int c, FILE * fp);

extern __stdargs FILE *popen(const char *command, const char *type);
extern __stdargs int pclose(FILE *stream);

/* Inline functions or protos. */
#ifdef __NO_INLINE__
extern __stdargs void clearerr(FILE *stream);
extern __stdargs int feof(FILE * fp);
extern __stdargs int ferror(FILE *fp);
extern __stdargs int fgetc(FILE *stream);
extern __stdargs int fgetpos(FILE *stream, fpos_t *pos);
extern __stdargs int fileno(FILE *file);
extern __stdargs int fputc(int c, FILE *stream);
extern __stdargs int fsetpos(FILE *stream, fpos_t *pos);
extern __stdargs int getchar();
extern __stdargs char *gets(char *s);
extern __stdargs int vprintf(const char *format, va_list args);
extern __stdargs int putchar(int c);
extern __stdargs int vscanf(const char *format, va_list args);
extern __stdargs void rewind(FILE *stream);
extern __stdargs int setbuf(FILE *stream, char *buf);
#else

#if defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 199901L)
#define __MY_INLINE__ static inline
#else
#define __MY_INLINE__ extern inline
#endif

__MY_INLINE__ __stdargs void clearerr(FILE *stream)
{	stream->_flags&=~(__SERR|__SEOF);}

__MY_INLINE__ __stdargs int feof(FILE * fp)
{	return ((fp)->_flags&__SEOF);}

__MY_INLINE__ __stdargs int ferror(FILE *fp)
{	return ((fp)->_flags&__SERR);}

__MY_INLINE__ __stdargs int fgetc(FILE *stream)
{	return getc(stream);}

__MY_INLINE__ __stdargs int fgetpos(FILE *stream,fpos_t *pos)
{	*pos=ftell(stream); return 0;}

__MY_INLINE__ __stdargs int fileno(FILE *file)
{	return file->file;}

__MY_INLINE__ __stdargs int fputc(int c,FILE *stream)
{	return putc(c,stream);}

__MY_INLINE__ __stdargs int fsetpos(FILE *stream,fpos_t *pos)
{	return fseek(stream,*pos,SEEK_SET);}

__MY_INLINE__ __stdargs int getchar()
{	return getc(stdin);}

__MY_INLINE__ __stdargs char *gets(char *s)
{	return fgets(s, 0, stdin);}

__MY_INLINE__ __stdargs int vprintf(const char *format,va_list args)
{	return vfprintf(stdout,format,args);}

__MY_INLINE__ __stdargs int putchar(int c)
{	return putc(c, stdout);}

__MY_INLINE__ __stdargs int vscanf(const char *format,va_list args)
{	return vfscanf(stdin,format,args);}

__MY_INLINE__ __stdargs void rewind(FILE *stream)
{	fseek(stream,0,SEEK_SET);}

__MY_INLINE__ __stdargs int setbuf(FILE *stream,char *buf)
{	return setvbuf(stream,buf,buf?_IOFBF:_IONBF,BUFSIZ);}
#endif

/* own stuff */
extern struct MinList __filelist; /* List of all fopen'ed files */
extern struct MinList __memorylist; /* List of memory puddles */

extern __stdargs int fflush(FILE *stream); /* fflush single file */
extern __stdargs void __chkabort(void); /* check for SIGABRT */

/*
 ** FILE/SOCKET abstraction layer
 */

struct stat;
struct StandardPacket;

#define LX_FILE   0x01
#define LX_SOCKET 0x80
#define LX_SYS    0x04
#define LX_ATTY   0x02

struct _StdFileDes;
struct _StdFileFx {
	ssize_t __stdargs (*lx_read)(struct _StdFileDes *, void *, size_t);
	ssize_t __stdargs (*lx_write)(struct _StdFileDes *, const void *, size_t);
	int __stdargs (*lx_close)(struct _StdFileDes *);
	int __stdargs (*lx_dup)(struct _StdFileDes *);
	int __stdargs (*lx_fstat)(struct _StdFileDes *, struct stat *);
	int __stdargs (*lx_select)(struct _StdFileDes *sfd, int select_cmd, int io_mode, struct fd_set *, unsigned long *);
};

typedef struct _StdFileDes {
	unsigned short lx_pos; /* __stdfiledes[lx_pos]; */
	unsigned char  lx_flags; /* LX_FILE, LX_SOCKET, LX_ATTY, LX_SYS*/
	unsigned char  lx_inuse; /* use counter */
#if __STDC_VERSION__ >= 199901L
	union {
		struct {
			int lx_fh;
			int lx_oflags;
			struct StandardPacket *lx_packet;
		};
		struct {
			int lx_sock;
			int lx_family;
			int lx_protocol;
			int lx_domain;
		};
	};
#else
	int lx_fh;
	int lx_oflags;
	struct StandardPacket *lx_packet;
	int lx_domain;
#define lx_sock    lx_fh
#define lx_family  lx_oflags
#define lx_protocol lx_packet
#endif

	struct _StdFileFx * lx_fx;
} StdFileDes;

extern __stdargs StdFileDes *_lx_fhfromfd(int fd);

#define L_tmpnam 8

#ifdef __FILENAME_MAX__
#define FILENAME_MAX    __FILENAME_MAX__
#else
#define	FILENAME_MAX	1024
#endif

#endif /* _STDIO_H */
