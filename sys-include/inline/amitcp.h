#ifndef _INLINE_AMITCP_H
#define _INLINE_AMITCP_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif

#ifndef AMITCP_BASE_NAME
#define AMITCP_BASE_NAME lss->lx_BsdSocketBase
#endif

#define TCP_Accept(s, addr, addrlen) \
	LP3(0x30, LONG, TCP_Accept, LONG, s, d0, struct sockaddr *, addr, a0, int *, addrlen, a1, \
	, AMITCP_BASE_NAME)

#define TCP_Bind(s, name, namelen) \
	LP3(0x24, LONG, TCP_Bind, LONG, s, d0, const struct sockaddr *, name, a0, LONG, namelen, d1, \
	, AMITCP_BASE_NAME)

#define TCP_CloseSocket(d) \
	LP1(0x78, LONG, TCP_CloseSocket, LONG, d, d0, \
	, AMITCP_BASE_NAME)

#define TCP_Connect(s, name, namelen) \
	LP3(0x36, LONG, TCP_Connect, LONG, s, d0, const struct sockaddr *, name, a0, LONG, namelen, d1, \
	, AMITCP_BASE_NAME)

#define TCP_Dup2Socket(fd1, fd2) \
	LP2(0x108, LONG, TCP_Dup2Socket, LONG, fd1, d0, LONG, fd2, d1, \
	, AMITCP_BASE_NAME)

#define TCP_Errno() \
	LP0(0xa2, LONG, TCP_Errno, \
	, AMITCP_BASE_NAME)

#define TCP_GetDTableSize() \
	LP0(0x8a, LONG, TCP_GetDTableSize, \
	, AMITCP_BASE_NAME)

#define TCP_GetHostByAddr(addr, len, type) \
	LP3(0xd8, struct hostent  *, TCP_GetHostByAddr, const UBYTE *, addr, a0, LONG, len, d0, LONG, type, d1, \
	, AMITCP_BASE_NAME)

#define TCP_GetHostByName(name) \
	LP1(0xd2, struct hostent  *, TCP_GetHostByName, const UBYTE *, name, a0, \
	, AMITCP_BASE_NAME)

#define TCP_GetHostId() \
	LP0(0x120, ULONG, TCP_GetHostId, \
	, AMITCP_BASE_NAME)

#define TCP_GetHostName(hostname, size) \
	LP2(0x11a, LONG, TCP_GetHostName, STRPTR, hostname, a0, LONG, size, d0, \
	, AMITCP_BASE_NAME)

#define TCP_GetNetByAddr(net, type) \
	LP2(0xe4, struct netent   *, TCP_GetNetByAddr, LONG, net, d0, LONG, type, d1, \
	, AMITCP_BASE_NAME)

#define TCP_GetNetByName(name) \
	LP1(0xde, struct netent   *, TCP_GetNetByName, const UBYTE *, name, a0, \
	, AMITCP_BASE_NAME)

#define TCP_GetPeerName(s, hostname, namelen) \
	LP3(0x6c, LONG, TCP_GetPeerName, LONG, s, d0, struct sockaddr *, hostname, a0, int *, namelen, a1, \
	, AMITCP_BASE_NAME)

#define TCP_GetProtoByName(name) \
	LP1(0xf6, struct protoent *, TCP_GetProtoByName, const UBYTE *, name, a0, \
	, AMITCP_BASE_NAME)

#define TCP_GetProtoByNumber(proto) \
	LP1(0xfc, struct protoent *, TCP_GetProtoByNumber, LONG, proto, d0, \
	, AMITCP_BASE_NAME)

#define TCP_GetServByName(name, proto) \
	LP2(0xea, struct servent  *, TCP_GetServByName, const UBYTE *, name, a0, const UBYTE *, proto, a1, \
	, AMITCP_BASE_NAME)

#define TCP_GetServByPort(port, proto) \
	LP2(0xf0, struct servent  *, TCP_GetServByPort, LONG, port, d0, const UBYTE *, proto, a0, \
	, AMITCP_BASE_NAME)

#define TCP_GetSockName(s, hostname, namelen) \
	LP3(0x66, LONG, TCP_GetSockName, LONG, s, d0, struct sockaddr *, hostname, a0, int *, namelen, a1, \
	, AMITCP_BASE_NAME)

#define TCP_GetSockOpt(s, level, optname, optval, optlen) \
	LP5(0x60, LONG, TCP_GetSockOpt, LONG, s, d0, LONG, level, d1, LONG, optname, d2, void *, optval, a0, int *, optlen, a1, \
	, AMITCP_BASE_NAME)

#define TCP_GetSocketEvents(eventmaskp) \
	LP1(0x12c, LONG, TCP_GetSocketEvents, ULONG *, eventmaskp, a0, \
	, AMITCP_BASE_NAME)

#define TCP_Inet_Addr(cp) \
	LP1(0xb4, ULONG, TCP_Inet_Addr, const UBYTE *, cp, a0, \
	, AMITCP_BASE_NAME)

#define TCP_Inet_LnaOf(in) \
	LP1(0xba, ULONG, TCP_Inet_LnaOf, LONG, in, d0, \
	, AMITCP_BASE_NAME)

#define TCP_Inet_MakeAddr(net, host) \
	LP2(0xc6, ULONG, TCP_Inet_MakeAddr, ULONG, net, d0, ULONG, host, d1, \
	, AMITCP_BASE_NAME)

#define TCP_Inet_NetOf(in) \
	LP1(0xc0, ULONG, TCP_Inet_NetOf, LONG, in, d0, \
	, AMITCP_BASE_NAME)

#define TCP_Inet_Network(cp) \
	LP1(0xcc, ULONG, TCP_Inet_Network, const UBYTE *, cp, a0, \
	, AMITCP_BASE_NAME)

#define TCP_Inet_NtoA(in) \
	LP1(0xae, char *, TCP_Inet_NtoA, ULONG, in, d0, \
	, AMITCP_BASE_NAME)

#define TCP_IoctlSocket(d, request, argp) \
	LP3(0x72, LONG, TCP_IoctlSocket, LONG, d, d0, ULONG, request, d1, char *, argp, a0, \
	, AMITCP_BASE_NAME)

#define TCP_Listen(s, backlog) \
	LP2(0x2a, LONG, TCP_Listen, LONG, s, d0, LONG, backlog, d1, \
	, AMITCP_BASE_NAME)

#define TCP_ObtainSocket(id, domain, type, protocol) \
	LP4(0x90, LONG, TCP_ObtainSocket, LONG, id, d0, LONG, domain, d1, LONG, type, d2, LONG, protocol, d3, \
	, AMITCP_BASE_NAME)

#define TCP_Recv(s, buf, len, flags) \
	LP4(0x4e, LONG, TCP_Recv, LONG, s, d0, UBYTE *, buf, a0, LONG, len, d1, LONG, flags, d2, \
	, AMITCP_BASE_NAME)

#define TCP_RecvFrom(s, buf, len, flags, from, fromlen) \
	LP6(0x48, LONG, TCP_RecvFrom, LONG, s, d0, UBYTE *, buf, a0, LONG, len, d1, LONG, flags, d2, struct sockaddr *, from, a1, int *, fromlen, a2, \
	, AMITCP_BASE_NAME)

#define TCP_RecvMsg(s, msg, flags) \
	LP3(0x114, LONG, TCP_RecvMsg, LONG, s, d0, struct msghdr *, msg, a0, LONG, flags, d1, \
	, AMITCP_BASE_NAME)

#define TCP_ReleaseCopyOfSocket(fd, id) \
	LP2(0x9c, LONG, TCP_ReleaseCopyOfSocket, LONG, fd, d0, LONG, id, d1, \
	, AMITCP_BASE_NAME)

#define TCP_ReleaseSocket(fd, id) \
	LP2(0x96, LONG, TCP_ReleaseSocket, LONG, fd, d0, LONG, id, d1, \
	, AMITCP_BASE_NAME)

#define TCP_Send(s, msg, len, flags) \
	LP4(0x42, LONG, TCP_Send, LONG, s, d0, const UBYTE *, msg, a0, LONG, len, d1, LONG, flags, d2, \
	, AMITCP_BASE_NAME)

#define TCP_SendMsg(s, msg, flags) \
	LP3(0x10e, LONG, TCP_SendMsg, LONG, s, d0, const struct msghdr *, msg, a0, LONG, flags, d1, \
	, AMITCP_BASE_NAME)

#define TCP_SendTo(s, msg, len, flags, to, tolen) \
	LP6(0x3c, LONG, TCP_SendTo, LONG, s, d0, const UBYTE *, msg, a0, LONG, len, d1, LONG, flags, d2, const struct sockaddr *, to, a1, LONG, tolen, d3, \
	, AMITCP_BASE_NAME)

#define TCP_SetErrnoPtr(errno_p, size) \
	LP2(0xa8, LONG, TCP_SetErrnoPtr, void *, errno_p, a0, LONG, size, d0, \
	, AMITCP_BASE_NAME)

#define TCP_SetSockOpt(s, level, optname, optval, optlen) \
	LP5(0x5a, LONG, TCP_SetSockOpt, LONG, s, d0, LONG, level, d1, LONG, optname, d2, const void *, optval, a0, LONG, optlen, d3, \
	, AMITCP_BASE_NAME)

#define TCP_SetSocketSignals(SIGINTR, SIGIO, SIGURG) \
	LP3NR(0x84, TCP_SetSocketSignals, ULONG, SIGINTR, d0, ULONG, SIGIO, d1, ULONG, SIGURG, d2, \
	, AMITCP_BASE_NAME)

#define TCP_ShutDown(s, how) \
	LP2(0x54, LONG, TCP_ShutDown, LONG, s, d0, LONG, how, d1, \
	, AMITCP_BASE_NAME)

#define TCP_Socket(domain, type, protocol) \
	LP3(0x1e, LONG, TCP_Socket, LONG, domain, d0, LONG, type, d1, LONG, protocol, d2, \
	, AMITCP_BASE_NAME)

#define TCP_SocketBaseTagList(taglist) \
	LP1(0x126, LONG, TCP_SocketBaseTagList, struct TagItem *, taglist, a0, \
	, AMITCP_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define TCP_SocketBaseTags(tags...) \
	({ULONG _tags[] = { tags }; TCP_SocketBaseTagList((struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define TCP_SyslogA(level, format, ap) \
	LP3NR(0x102, TCP_SyslogA, ULONG, level, d0, const char *, format, a0, va_list, ap, a1, \
	, AMITCP_BASE_NAME)

#define TCP_WaitSelect(nfds, readfds, writefds, execptfds, timeout, maskp) \
	LP6(0x7e, LONG, TCP_WaitSelect, LONG, nfds, d0, fd_set *, readfds, a0, fd_set *, writefds, a1, fd_set *, execptfds, a2, struct timeval *, timeout, a3, ULONG *, maskp, d1, \
	, AMITCP_BASE_NAME)

#endif /* _INLINE_AMITCP_H */
