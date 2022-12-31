#ifndef _HEADERS_REGPARM_H
#define _HEADERS_REGPARM_H

#define ___PUSH(a) "movel\t" #a ",sp@-\n"
#define ___POP(a)  "movel\tsp@+," #a "\n"

#ifndef SMALL_DATA

#define __REGP(functype,funcname,pushlist,popval) \
asm(".even\n" ".globl _" #funcname "\n" "_" #funcname ":\n" \
pushlist "jbsr\t___" #funcname "\n" "addqw\t#" #popval ",sp\n" \
"rts\n"); functype __##funcname

#else

#define __REGP(functype,funcname,pushlist,popval) \
asm(".even\n" ".globl _" #funcname "\n" "_" #funcname ":\n" ___PUSH(a4) \
pushlist "jbsr\t_geta4\n" "jbsr\t___" #funcname "\n" "addqw\t#" #popval ",sp\n" \
___POP(a4) "rts\n"); functype __##funcname

#endif

#define REGPARM1(functype,funcname,a1,r1) \
__REGP(functype,funcname,___PUSH(r1),4) (a1)

#define REGPARM2(functype,funcname,a1,r1,a2,r2) \
__REGP(functype,funcname,___PUSH(r2)___PUSH(r1),8) (a1,a2)

#define REGPARM3(functype,funcname,a1,r1,a2,r2,a3,r3) \
__REGP(functype,funcname,___PUSH(r3)___PUSH(r2)___PUSH(r1),12) (a1,a2,a3)

#define REGPARM4(functype,funcname,a1,r1,a2,r2,a3,r3,a4,r4) \
__REGP(functype,funcname,___PUSH(r4)___PUSH(r3)___PUSH(r2)___PUSH(r1),16) (a1,a2,a3,a4)

#endif /* _HEADERS_REGPARM_H */
