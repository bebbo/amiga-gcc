#ifndef _HEADERS_SOCKET_H
#define _HEADERS_SOCKET_H

/*
**
*/
#include <netdb.h>
#include <amitcp/usergroup.h>
#include <amitcp/socketbasetags.h>
#include "inline/usergroup.h"
#include <inline/amitcp.h>
#include <inline/as225.h>
#include "stdio.h"

#ifndef MAXLOGNAME
#define	MAXLOGNAME	12
#endif

/*
**
*/
typedef enum {LX_NONE, LX_AMITCP, LX_AS225} LX_NETWORK_TYPE;

/*
**
*/
struct SocketSettings {
  LX_NETWORK_TYPE lx_network_type;
  union {
    struct {
      struct Library *BsdSocketBase;
      struct Library *UserGroupBase;
    } AMITCP;
    struct {
      struct Library *SocketBase;
    } AS225;
  } lx_stack;
#define lx_BsdSocketBase lx_stack.AMITCP.BsdSocketBase
#define lx_UserGroupBase lx_stack.AMITCP.UserGroupBase
#define lx_SocketBase    lx_stack.AS225.SocketBase

  unsigned long     lx_sigurg;
  unsigned long     lx_sigio;
  int               lx_sockid;
  int               lx_isdaemon;

  /* Support for net functions */
  FILE             *lx_pwd_fp;      /* File pointer to the passwd file */
  char             *lx_pwd_line;    /* buffer for reading a line from the passwd file */
  struct passwd     lx_pwd;         /* static buffer to hold the data */
  int               lx_pwd_stayopen;/* TRUE if passwd file should stay open */

  FILE             *lx_grp_fp;      /* File pointer to the groups file */
  char             *lx_grp_line;    /* buffer for reading a line from the group file */
  struct group      lx_grp;         /* static buffer to hold the data */
  char            **lx_members;     /* array of group members */
  int               lx_grp_stayopen;/* TRUE if group file should stay open */

  FILE             *lx_net_fp;      /* File pointer to protocol file */
  char             *lx_net_line;    /* buffer for reading a line from the protocol file */
  struct netent     lx_net;
  char            **lx_net_aliases;
  int               lx_net_stayopen;

  FILE             *lx_serv_fp;     /* File pointer to services file */
  char             *lx_serv_line;   /* buffer for reading a line from the services file */
  struct servent    lx_serv;
  char            **lx_serv_aliases;
  int               lx_serv_stayopen;
  
  FILE             *lx_proto_fp;    /* File pointer to protocol file */
  char             *lx_proto_line;  /* buffer for reading a line from the protocol file */
  struct protoent   lx_proto;
  char            **lx_proto_aliases;
  int               lx_proto_stayopen;

  /* resolv state structure */
  struct __res_state *lx_res;
  int                *lx_res_socket;

  /* XXX unused XXX */
  int   lx_logname_valid;
  char  lx_logname[MAXLOGNAME + 1];
  char  lx_logname_buf[MAXLOGNAME + 1];

  /* XXX unused XXX */
  char  lx_ntoa_buf[18];  /* used by inet_ntoa */

  /* logfile handling */
  int   lx_LogFile;     /* fd for log */
  int   lx_LogStat;     /* status bits, set by openlog() */
  char *lx_LogTag;      /* string to tag the entry with */
  int   lx_LogFacility; /* default facility code */
  int   lx_LogMask;     /* mask of priorities to be logged */
  int   lx_setuid;      /* used for setuid() - have to remember to log out */
};

/*
**
*/
extern __stdargs struct SocketSettings *_lx_get_socket_settings(void);

/*
**
*/
extern __stdargs StdFileDes *_create_socket(int family, int type, int protocol);

#endif /* _HEADERS_SOCKET_H */
