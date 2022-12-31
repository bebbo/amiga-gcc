#ifndef _HEADERS_POOL_H
#define _HEADERS_POOL_H

#include <exec/types.h>

#if defined(__GNUC__)
#define ASM
#define REG(reg,arg) arg __asm(#reg)
#else
#define ASM __asm
#define REG(reg,arg) register __##reg arg
#endif

#include <exec/lists.h>
#include <exec/memory.h>
#include <proto/exec.h>

/*
**     our PRIVATE! memory pool structure 
** (_NOT_ compatible with original amiga.lib!)
*/

typedef struct Pool {
  struct MinList PuddleList;
  ULONG MemoryFlags;
  ULONG PuddleSize;
  ULONG ThreshSize;
} POOL;

/*
** required prototypes
*/

APTR ASM AsmCreatePool(REG(d0,ULONG),REG(d1,ULONG),REG(d2,ULONG),REG(a6,APTR));
APTR ASM AsmAllocPooled(REG(a0,POOL *),REG(d0,ULONG),REG(a6,APTR));
VOID ASM AsmFreePooled(REG(a0,POOL *),REG(a1,APTR),REG(d0,ULONG),REG(a6,APTR));
VOID ASM AsmDeletePool(REG(a0,POOL *),REG(a6,APTR));

#endif /* _HEADERS_POOL_H */
