#ifndef _INLINE_AS225_H
#define _INLINE_AS225_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif

#ifndef AS225_BASE_NAME
#define AS225_BASE_NAME lss->lx_SocketBase
#endif

#define SOCK_accept(s, name, lenp) \
	LP3(0xba, int, SOCK_accept, int, s, d0, struct sockaddr *, name, a0, int *, lenp, a1, \
	, AS225_BASE_NAME)

#define SOCK_bind(s, name, namelen) \
	LP3(0xc0, int, SOCK_bind, int, s, d0, const struct sockaddr *, name, a1, int, namelen, d1, \
	, AS225_BASE_NAME)

#define SOCK_cleanup_sockets() \
	LP0NR(0x24, SOCK_cleanup_sockets, \
	, AS225_BASE_NAME)

#define SOCK_close(socket) \
	LP1(0x30, int, SOCK_close, int, socket, d0, \
	, AS225_BASE_NAME)

#define SOCK_connect(s, name, namelen) \
	LP3(0xc6, int, SOCK_connect, int, s, d0, const struct sockaddr *, name, a1, int, namelen, d1, \
	, AS225_BASE_NAME)

#define SOCK_dev_list(res, size) \
	LP2NR(0x1bc, SOCK_dev_list, u_long, res, d0, int, size, d1, \
	, AS225_BASE_NAME)

#define SOCK_endhostent() \
	LP0NR(0x7e, SOCK_endhostent, \
	, AS225_BASE_NAME)

#define SOCK_endnetent() \
	LP0NR(0x120, SOCK_endnetent, \
	, AS225_BASE_NAME)

#define SOCK_endprotoent() \
	LP0NR(0x13e, SOCK_endprotoent, \
	, AS225_BASE_NAME)

#define SOCK_endpwent() \
	LP0NR(0x18c, SOCK_endpwent, \
	, AS225_BASE_NAME)

#define SOCK_endservent() \
	LP0NR(0x15c, SOCK_endservent, \
	, AS225_BASE_NAME)

#define SOCK_get_tz() \
	LP0(0x5a, short, SOCK_get_tz, \
	, AS225_BASE_NAME)

#define SOCK_getdomainname(name, namelen) \
	LP2(0x60, int, SOCK_getdomainname, char *, name, a1, int, namelen, d1, \
	, AS225_BASE_NAME)

#define SOCK_getgid() \
	LP0(0x48, gid_t, SOCK_getgid, \
	, AS225_BASE_NAME)

#define SOCK_getgroups(num, gids) \
	LP2(0x4e, int, SOCK_getgroups, int, num, d0, int *, gids, a0, \
	, AS225_BASE_NAME)

#define SOCK_gethostbyaddr(addr, len, type) \
	LP3(0x90, struct hostent *, SOCK_gethostbyaddr, const char *, addr, a0, int, len, d0, int, type, d1, \
	, AS225_BASE_NAME)

#define SOCK_gethostbyname(name) \
	LP1(0x8a, struct hostent *, SOCK_gethostbyname, const char *, name, a0, \
	, AS225_BASE_NAME)

#define SOCK_gethostent() \
	LP0(0x84, struct hostent *, SOCK_gethostent, \
	, AS225_BASE_NAME)

#define SOCK_gethostname(name, length) \
	LP2(0x72, int, SOCK_gethostname, char *, name, a0, int, length, d0, \
	, AS225_BASE_NAME)

#define SOCK_getlogin() \
	LP0(0x54, char *, SOCK_getlogin, \
	, AS225_BASE_NAME)

#define SOCK_getnetbyaddr(net, type) \
	LP2(0x12c, struct netent *, SOCK_getnetbyaddr, long, net, d0, int, type, d1, \
	, AS225_BASE_NAME)

#define SOCK_getnetbyname(name) \
	LP1(0x132, struct netent *, SOCK_getnetbyname, const char *, name, a0, \
	, AS225_BASE_NAME)

#define SOCK_getnetent() \
	LP0(0x126, struct netent *, SOCK_getnetent, \
	, AS225_BASE_NAME)

#define SOCK_getpeername(s, name, lenp) \
	LP3(0x198, int, SOCK_getpeername, int, s, d0, struct sockaddr *, name, a0, int *, lenp, a1, \
	, AS225_BASE_NAME)

#define SOCK_getprotobyname(name) \
	LP1(0x14a, struct protoent *, SOCK_getprotobyname, const char *, name, a0, \
	, AS225_BASE_NAME)

#define SOCK_getprotobynumber(proto) \
	LP1(0x150, struct protoent *, SOCK_getprotobynumber, int, proto, d0, \
	, AS225_BASE_NAME)

#define SOCK_getprotoent() \
	LP0(0x144, struct protoent *, SOCK_getprotoent, \
	, AS225_BASE_NAME)

#define SOCK_getpwent() \
	LP0(0x180, struct AS225_passwd *, SOCK_getpwent, \
	, AS225_BASE_NAME)

#define SOCK_getpwnam(name) \
	LP1(0x17a, struct AS225_passwd *, SOCK_getpwnam, char *, name, a0, \
	, AS225_BASE_NAME)

#define SOCK_getpwuid(uid) \
	LP1(0x174, struct AS225_passwd *, SOCK_getpwuid, uid_t, uid, d1, \
	, AS225_BASE_NAME)

#define SOCK_getservbyname(name, proto) \
	LP2(0x168, struct servent *, SOCK_getservbyname, const char *, name, a0, const char *, proto, a1, \
	, AS225_BASE_NAME)

#define SOCK_getservbyport(port, proto) \
	LP2(0x16e, struct servent *, SOCK_getservbyport, u_short, port, d0, const char *, proto, a0, \
	, AS225_BASE_NAME)

#define SOCK_getservent() \
	LP0(0x162, struct servent *, SOCK_getservent, \
	, AS225_BASE_NAME)

#define SOCK_getsignal(type) \
	LP1(0x36, BYTE, SOCK_getsignal, UWORD, type, d1, \
	, AS225_BASE_NAME)

#define SOCK_getsockname(s, name, lenp) \
	LP3(0x19e, int, SOCK_getsockname, int, s, d0, struct sockaddr *, name, a0, int *, lenp, a1, \
	, AS225_BASE_NAME)

#define SOCK_getsockopt(s, level, optname, optval, optlenp) \
	LP5(0x114, int, SOCK_getsockopt, int, s, d0, int, level, d1, int, optname, d2, char *, optval, a0, int *, optlenp, a1, \
	, AS225_BASE_NAME)

#define SOCK_getuid() \
	LP0(0x42, uid_t, SOCK_getuid, \
	, AS225_BASE_NAME)

#define SOCK_getumask() \
	LP0(0x66, mode_t, SOCK_getumask, \
	, AS225_BASE_NAME)

#define SOCK_inet_addr(cp) \
	LP1(0x96, u_long, SOCK_inet_addr, char *, cp, a1, \
	, AS225_BASE_NAME)

#define SOCK_inet_lnaof(in) \
	LP1(0xa2, int, SOCK_inet_lnaof, struct, in, d1, \
	, AS225_BASE_NAME)

#define SOCK_inet_makeaddr(net, lna) \
	LP2(0x9c, struct in_addr, SOCK_inet_makeaddr, int, net, d0, int, lna, d1, \
	, AS225_BASE_NAME)

#define SOCK_inet_netof(in) \
	LP1(0xa8, int, SOCK_inet_netof, struct, in, d1, \
	, AS225_BASE_NAME)

#define SOCK_inet_network(str) \
	LP1(0xae, int, SOCK_inet_network, char *, str, a1, \
	, AS225_BASE_NAME)

#define SOCK_inet_ntoa(in) \
	LP1(0xb4, char *, SOCK_inet_ntoa, struct, in, d1, \
	, AS225_BASE_NAME)

#define SOCK_inherit(sp) \
	LP1(0x1b6, int, SOCK_inherit, void *, sp, d1, \
	, AS225_BASE_NAME)

#define SOCK_ioctl(s, cmd, data) \
	LP3(0xcc, int, SOCK_ioctl, int, s, d0, int, cmd, d1, char *, data, a0, \
	, AS225_BASE_NAME)

#define SOCK_listen(s, backlog) \
	LP2(0xd2, int, SOCK_listen, int, s, d0, int, backlog, d1, \
	, AS225_BASE_NAME)

#define SOCK_rcmd(ahost, inport, luser, ruser, cmd, fd2p) \
	LP6(0x192, int, SOCK_rcmd, char **, ahost, d0, u_short, inport, d1, char *, luser, a0, char *, ruser, a1, char *, cmd, a2, int *, fd2p, d2, \
	, AS225_BASE_NAME)

#define SOCK_reconfig() \
	LP0(0x1aa, int, SOCK_reconfig, \
	, AS225_BASE_NAME)

#define SOCK_recv(s, buf, len, flags) \
	LP4(0xd8, int, SOCK_recv, int, s, d0, char *, buf, a0, int, len, d1, int, flags, d2, \
	, AS225_BASE_NAME)

#define SOCK_recvfrom(s, buf, len, flags, from, fromlen) \
	LP6(0xde, int, SOCK_recvfrom, int, s, d0, char *, buf, a0, int, len, d1, int, flags, d2, struct sockaddr *, from, a1, int *, fromlen, a2, \
	, AS225_BASE_NAME)

#define SOCK_recvmsg(s, msg, flags) \
	LP3(0xe4, int, SOCK_recvmsg, int, s, d0, struct msghdr *, msg, a0, int, flags, d1, \
	, AS225_BASE_NAME)

#define SOCK_release(s) \
	LP1(0x1b0, void *,SOCK_release, int, s, d1, \
	, AS225_BASE_NAME)

#define SOCK_select(numfds, rfds, wfds, efds, timeout) \
	LP5(0xea, int, SOCK_select, int, numfds, d0, fd_set *, rfds, a0, fd_set *, wfds, a1, fd_set *, efds, a2, struct timeval *, timeout, d1, \
	, AS225_BASE_NAME)

#define SOCK_selectwait(numfds, rfds, wfds, efds, timeout, umask) \
	LP6(0xf0, int, SOCK_selectwait, int, numfds, d0, fd_set *, rfds, a0, fd_set *, wfds, a1, fd_set *, efds, a2, struct timeval *, timeout, d1, long *, umask, d2, \
	, AS225_BASE_NAME)

#define SOCK_send(s, buf, len, flags) \
	LP4(0xf6, int, SOCK_send, int, s, d0, const char *, buf, a0, int, len, d1, int, flags, a1, \
	, AS225_BASE_NAME)

#define SOCK_sendmsg(s, msg, flags) \
	LP3(0x102, int, SOCK_sendmsg, int, s, d0, const struct msghdr *, msg, a0, int, flags, d1, \
	, AS225_BASE_NAME)

#define SOCK_sendto(s, buf, len, flags, to, to_len) \
	LP6(0xfc, int, SOCK_sendto, int, s, d0, const char *, buf, a0, int, len, d1, int, flags, d2, const struct sockaddr *, to, a1, int, to_len, d3, \
	, AS225_BASE_NAME)

#define SOCK_sethostent(flag) \
	LP1NR(0x78, SOCK_sethostent, int, flag, d1, \
	, AS225_BASE_NAME)

#define SOCK_setnetent(flag) \
	LP1NR(0x11a, SOCK_setnetent, int, flag, d1, \
	, AS225_BASE_NAME)

#define SOCK_setprotoent(flag) \
	LP1NR(0x138, SOCK_setprotoent, int, flag, d1, \
	, AS225_BASE_NAME)

#define SOCK_setpwent(flag) \
	LP1NR(0x186, SOCK_setpwent, int, flag, d1, \
	, AS225_BASE_NAME)

#define SOCK_setservent(flag) \
	LP1NR(0x156, SOCK_setservent, int, flag, d1, \
	, AS225_BASE_NAME)

#define SOCK_setsockopt(s, level, optname, optval, optlen) \
	LP5(0x10e, int, SOCK_setsockopt, int, s, d0, int, level, d1, int, optname, d2, const char *, optval, a0, int, optlen, d3, \
	, AS225_BASE_NAME)

#define SOCK_setup_sockets(max_socks, errno_ptr) \
	LP2(0x1e, ULONG, SOCK_setup_sockets, UWORD, max_socks, d1, int *, errno_ptr, a0, \
	, AS225_BASE_NAME)

#define SOCK_shutdown(s, how) \
	LP2(0x108, int, SOCK_shutdown, int, s, d0, int, how, d1, \
	, AS225_BASE_NAME)

#define SOCK_socket(family, type, protocol) \
	LP3(0x2a, int, SOCK_socket, int, family, d0, int, type, d1, int, protocol, d2, \
	, AS225_BASE_NAME)

#define SOCK_strerror(num) \
	LP1(0x3c, char *, SOCK_strerror, int, num, d1, \
	, AS225_BASE_NAME)

#define SOCK_syslog(pri, msg) \
	LP2(0x1a4, int, SOCK_syslog, int, pri, d0, char *, msg, a0, \
	, AS225_BASE_NAME)

#define SOCK_umask(cmask) \
	LP1(0x6c, mode_t, SOCK_umask, mode_t, cmask, d0, \
	, AS225_BASE_NAME)

#define SOCK_dup(fd) \
	LP1(0x2b2, int, SOCK_dup, int, fd, d0, \
	, AS225_BASE_NAME)

#endif /* _INLINE_AS225_H */
