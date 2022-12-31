#ifndef _HEADERS_SELECT_H
#define _HEADERS_SELECT_H

#define SELCMD_PREPARE 0
#define SELCMD_CHECK   1
#define SELCMD_POLL    2

#define SELMODE_IN     0
#define SELMODE_OUT    1
#define SELMODE_EXC    2

#define SELPKT_IN_USE(fp) ((fp)->lx_packet->sp_Pkt.dp_Port != NULL)

#define SelLastResult(fp) ((fp)->lx_packet->sp_Pkt.dp_Res1)
#define SelLastError(fp)  ((fp)->lx_packet->sp_Pkt.dp_Res2)

#define PutPacket(port,pack) PutMsg((port),(pack))
#define GetPacket(port) ((struct StandardPacket *)GetMsg(port))
#define SelSendPacket1(fp,port,act,arg1) \
  do { \
    struct StandardPacket *sp = (fp)->lx_packet; \
    sp->sp_Pkt.dp_Port = (port); \
    sp->sp_Pkt.dp_Type = (act);  \
    sp->sp_Pkt.dp_Arg1 = (arg1); \
    PutPacket(((struct FileHandle *)BADDR((fp)->lx_fh))->fh_Type,&sp->sp_Msg); \
  } while(0)

#endif /* _HEADERS_SELECT_H */
