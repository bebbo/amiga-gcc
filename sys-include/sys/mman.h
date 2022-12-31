#ifndef __SYS_MMAN_H

#define __SYS_MMAN_H

#ifdef __cplusplus
extern "C"
{
#endif

#define	PROT_READ	0x04	
#define	PROT_WRITE	0x02	
#define	PROT_EXEC	0x01	

#define	MAP_FILE	0x0001	
#define	MAP_ANON	0x0002	
#define	MAP_TYPE	0x000f	

#define	MAP_COPY	0x0020	
#define	MAP_SHARED	0x0010	
#define	MAP_PRIVATE	0x0000	

#define	MAP_FIXED	0x0100	
#define	MAP_NOEXTEND	0x0200	
#define	MAP_HASSEMPHORE	0x0400	
#define	MAP_INHERIT	0x0800	 

#define	MADV_NORMAL	0	
#define	MADV_RANDOM	1	
#define	MADV_SEQUENTIAL	2	
#define	MADV_WILLNEED	3	
#define	MADV_DONTNEED	4	


void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
int munmap(void *addr, size_t length);

#ifdef __cplusplus
}
#endif
#endif
