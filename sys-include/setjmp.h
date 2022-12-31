/*
	setjmp.h
	stubs for future use.
*/

#ifndef _SETJMP_H_
#define _SETJMP_H_

#include "_ansi.h"
#include <machine/setjmp.h>

_BEGIN_STD_C

#ifndef __stdargs
#define __stdargs
#endif

#ifdef __GNUC__
__stdargs void	longjmp (jmp_buf __jmpb, int __retval)
			__attribute__ ((__noreturn__));
#else
__stdargs void	longjmp (jmp_buf __jmpb, int __retval);
#endif
__stdargs int	setjmp (jmp_buf __jmpb);

_END_STD_C

#endif /* _SETJMP_H_ */

