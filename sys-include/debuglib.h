#ifndef _DEBUGLIB_H
#define _DEBUGLIB_H

#ifdef DEBUG_LIB
extern __stdargs int KPrintF(const char *, ...);
#define DB(x) x
#define BUG KPrintF
#define ASSERT(x) { if (!(x)) KPrintF("Assertion failed: " #x " at file " __FILE__ ", line %ld\n", __LINE__); }
#else
#define DB(x)
#define BUG
#define ASSERT(x)
#endif /* DEBUG_LIB */

#endif /* _DEBUGLIB_H */
