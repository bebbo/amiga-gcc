#ifndef	_FNMATCH_H_
#define	_FNMATCH_H_

// The string does not match the specified pattern.
#define    FNM_NOMATCH	1

// Disable backslash escaping.
#define    FNM_NOESCAPE	1
// <slash> in string only matches <slash> in pattern.
#define    FNM_PATHNAME	2
// Leading <period> in string must be exactly matched by <period> in pattern.
#define    FNM_PERIOD	4

// ignore the case
#define    FNM_CASEFOLD 8

// The following shall be declared as a function and may also be defined as a macro. A function prototype shall be provided.
__stdargs	int fnmatch(const char *, const char *, int);

#endif // _FNMATCH_H_
