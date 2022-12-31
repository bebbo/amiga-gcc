#ifndef __SYS_UN_H

struct sockaddr_un {
               sa_family_t sun_family;               /* AF_UNIX */
               char        sun_path[108];            /* Pathname */
           };
		   
#define __SYS_UN_H
#endif
