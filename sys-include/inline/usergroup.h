#ifndef _INLINE_USERGROUP_H
#define _INLINE_USERGROUP_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif

#ifndef USERGROUP_BASE_NAME
#define USERGROUP_BASE_NAME lss->lx_UserGroupBase
#endif

#define UG_crypt(key, salt) \
	LP2(0xae, char *, UG_crypt, const char *, key, a0, const char *, salt, a1, \
	, USERGROUP_BASE_NAME)

#define UG_endgrent() \
	LP0NR(0xa8, UG_endgrent, \
	, USERGROUP_BASE_NAME)

#define UG_endpwent() \
	LP0NR(0x8a, UG_endpwent, \
	, USERGROUP_BASE_NAME)

#define UG_endutent() \
	LP0NR(0xf0, UG_endutent, \
	, USERGROUP_BASE_NAME)

#define UG_getcredentials(task) \
	LP1(0x102, struct UserGroupCredentials *, UG_getcredentials, struct Task *, task, a0, \
	, USERGROUP_BASE_NAME)

#define UG_getegid() \
	LP0(0x4e, gid_t, UG_getegid, \
	, USERGROUP_BASE_NAME)

#define UG_geteuid() \
	LP0(0x36, uid_t, UG_geteuid, \
	, USERGROUP_BASE_NAME)

#define UG_getgid() \
	LP0(0x48, gid_t, UG_getgid, \
	, USERGROUP_BASE_NAME)

#define UG_getgrent() \
	LP0(0xa2, struct group *, UG_getgrent, \
	, USERGROUP_BASE_NAME)

#define UG_getgrgid(gid) \
	LP1(0x96, struct group *, UG_getgrgid, gid_t, gid, d0, \
	, USERGROUP_BASE_NAME)

#define UG_getgrnam(name) \
	LP1(0x90, struct group *, UG_getgrnam, const char *, name, a1, \
	, USERGROUP_BASE_NAME)

#define UG_getgroups(ngroups, groups) \
	LP2(0x60, int, UG_getgroups, int, ngroups, d0, int *, groups, a1, \
	, USERGROUP_BASE_NAME)

#define UG_getlastlog(uid) \
	LP1(0xf6, struct lastlog *, UG_getlastlog, uid_t, uid, d0, \
	, USERGROUP_BASE_NAME)

#define UG_getlogin() \
	LP0(0xd8, char *, UG_getlogin, \
	, USERGROUP_BASE_NAME)

#define UG_getpass(prompt) \
	LP1(0xba, char *, UG_getpass, const char *, prompt, a1, \
	, USERGROUP_BASE_NAME)

#define UG_getpgrp() \
	LP0(0xd2, pid_t, UG_getpgrp, \
	, USERGROUP_BASE_NAME)

#define UG_getpwent() \
	LP0(0x84, struct TCP_passwd *, UG_getpwent, \
	, USERGROUP_BASE_NAME)

#define UG_getpwnam(name) \
	LP1(0x72, struct TCP_passwd *, UG_getpwnam, const char *, name, a1, \
	, USERGROUP_BASE_NAME)

#define UG_getpwuid(uid) \
	LP1(0x78, struct TCP_passwd *, UG_getpwuid, uid_t, uid, d0, \
	, USERGROUP_BASE_NAME)

#define UG_getuid() \
	LP0(0x30, uid_t, UG_getuid, \
	, USERGROUP_BASE_NAME)

#define UG_getumask() \
	LP0(0xc6, mode_t, UG_getumask, \
	, USERGROUP_BASE_NAME)

#define UG_getutent() \
	LP0(0xea, struct utmp *, UG_getutent, \
	, USERGROUP_BASE_NAME)

#define UG_initgroups(name, basegroup) \
	LP2(0x6c, int, UG_initgroups, const char *, name, a1, gid_t, basegroup, d0, \
	, USERGROUP_BASE_NAME)

#define UG_setgid(id) \
	LP1(0x5a, int, UG_setgid, gid_t, id, d0, \
	, USERGROUP_BASE_NAME)

#define UG_setgrent() \
	LP0NR(0x9c, UG_setgrent, \
	, USERGROUP_BASE_NAME)

#define UG_setgroups(ngroups, groups) \
	LP2(0x66, int, UG_setgroups, int, ngroups, d0, const int *, groups, a1, \
	, USERGROUP_BASE_NAME)

#define UG_setlastlog(uid, name, host) \
	LP3(0xfc, int, UG_setlastlog, uid_t, uid, d0, char *, name, a0, char *, host, a1, \
	, USERGROUP_BASE_NAME)

#define UG_setlogin(buffer) \
	LP1(0xde, int, UG_setlogin, const char *, buffer, a1, \
	, USERGROUP_BASE_NAME)

#define UG_setpwent() \
	LP0NR(0x7e, UG_setpwent, \
	, USERGROUP_BASE_NAME)

#define UG_setregid(real, eff) \
	LP2(0x54, int, UG_setregid, gid_t, real, d0, gid_t, eff, d1, \
	, USERGROUP_BASE_NAME)

#define UG_setreuid(real, eff) \
	LP2(0x3c, int, UG_setreuid, uid_t, real, d0, uid_t, eff, d1, \
	, USERGROUP_BASE_NAME)

#define UG_setsid() \
	LP0(0xcc, pid_t, UG_setsid, \
	, USERGROUP_BASE_NAME)

#define UG_setuid(id) \
	LP1(0x42, int, UG_setuid, uid_t, id, d0, \
	, USERGROUP_BASE_NAME)

#define UG_setutent() \
	LP0NR(0xe4, UG_setutent, \
	, USERGROUP_BASE_NAME)

#define UG_umask(mask) \
	LP1(0xc0, mode_t, UG_umask, mode_t, mask, d0, \
	, USERGROUP_BASE_NAME)

#define ug_GetErr() \
	LP0(0x24, int, ug_GetErr, \
	, USERGROUP_BASE_NAME)

#define ug_GetSalt(user, buffer, size) \
	LP3(0xb4, char *, ug_GetSalt, const struct TCP_passwd *, user, a0, char *, buffer, a1, ULONG, size, d0, \
	, USERGROUP_BASE_NAME)

#define ug_SetupContextTagList(pname, taglist) \
	LP2(0x1e, int, ug_SetupContextTagList, const UBYTE*, pname, a0, struct TagItem *, taglist, a1, \
	, USERGROUP_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ug_SetupContextTags(a0, tags...) \
	({ULONG _tags[] = { tags }; ug_SetupContextTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define ug_StrError(code) \
	LP1(0x2a, const char *, ug_StrError, LONG, code, d1, \
	, USERGROUP_BASE_NAME)

#endif /* _INLINE_USERGROUP_H */
