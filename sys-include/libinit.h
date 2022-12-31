#ifndef _HEADERS_LIBINIT_H
#define _HEADERS_LIBINIT_H

/******************************************************************************/
/*                                                                            */
/* special define(s)                                                          */
/*                                                                            */
/******************************************************************************/

#ifndef __stdargs
#define __stdargs
#endif

#if !defined(REG)
#define REG(reg,arg) arg __asm(#reg)
#endif

#include <exec/resident.h>
#include <exec/libraries.h>
#include <proto/exec.h>
#include "stabs.h"

/******************************************************************************/
/*                                                                            */
/* structure definition for a *** PRIVATE *** library/device base             */
/*                                                                            */
/******************************************************************************/

typedef struct libBase {
  struct Library  LibNode;
  UWORD           Pad;
  LONG            SegList;
  APTR            DataSeg,
                  SysBase;
#ifdef EXTENDED
  ULONG           DataSize;
  struct libBase *Parent;
#endif
} *__LIB, *__DEV;

/******************************************************************************/
/*                                                                            */
/* prototypes for basic library functions                                     */
/*                                                                            */
/******************************************************************************/

LONG LibExtFunc(VOID);
LONG LibExpunge(REG(a6,__LIB));
LONG LibClose(REG(a6,__LIB));
APTR LibOpen(REG(a6,__LIB));
APTR LibInit(REG(a0,LONG),REG(d0,__LIB),REG(a6,struct Library *));

/******************************************************************************/
/*                                                                            */
/* prototypes for basic device functions                                      */
/*                                                                            */
/******************************************************************************/

LONG DevExtFunc(VOID);
LONG DevExpunge(REG(a6,__DEV));
LONG DevClose(REG(a1,APTR),REG(a6,__DEV));
VOID DevOpen(REG(d0,ULONG),REG(a1,APTR),REG(d1,ULONG),REG(a6,__DEV));
APTR DevInit(REG(a0,LONG),REG(d0,__DEV),REG(a6,struct Library *));

/******************************************************************************/
/*                                                                            */
/* imports                                                                    */
/*                                                                            */
/******************************************************************************/

extern LONG __stdargs __UserLibInit(struct Library *,REG(a4,APTR));
extern VOID __stdargs __UserLibCleanup(REG(a4,APTR));

extern const UWORD LibVersion;
extern const UWORD LibRevision;
extern const char LibIdString[];
extern const char LibName[];

extern LONG __stdargs __UserDevInit(struct Library *,REG(a4,APTR));
extern LONG __stdargs __UserDevOpen(struct IORequest *,ULONG,ULONG,REG(a4,APTR));
extern VOID __stdargs __UserDevClose(struct IORequest *,REG(a4,APTR));
extern VOID __stdargs __UserDevCleanup(REG(a4,APTR));

extern const UWORD DevVersion;
extern const UWORD DevRevision;
extern const char DevIdString[];
extern const char DevName[];

extern APTR __LibTable__[];
extern APTR __FuncTable__[];

extern LONG __datadata_relocs[];

#endif /* _HEADERS_LIBINIT_H */
