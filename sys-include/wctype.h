#ifndef _WCTYPE_H_
#define _WCTYPE_H_

#include <_ansi.h>
#include <sys/_types.h>

#define __need_wint_t
#include <stddef.h>

#if __POSIX_VISIBLE >= 200809
#include <xlocale.h>
#endif

#ifndef WEOF
# define WEOF ((wint_t)-1)
#endif

_BEGIN_STD_C

#ifndef _WCTYPE_T
#define _WCTYPE_T
typedef int wctype_t;
#endif

#ifndef _WCTRANS_T
#define _WCTRANS_T
typedef int wctrans_t;
#endif

#ifndef __stdargs
#define __stdargs
#endif

__stdargs int	iswalpha (wint_t);
__stdargs int	iswalnum (wint_t);
#if __ISO_C_VISIBLE >= 1999
__stdargs int	iswblank (wint_t);
#endif
__stdargs int	iswcntrl (wint_t);
__stdargs int	iswctype (wint_t, wctype_t);
__stdargs int	iswdigit (wint_t);
__stdargs int	iswgraph (wint_t);
__stdargs int	iswlower (wint_t);
__stdargs int	iswprint (wint_t);
__stdargs int	iswpunct (wint_t);
__stdargs int	iswspace (wint_t);
__stdargs int	iswupper (wint_t);
__stdargs int	iswxdigit (wint_t);
__stdargs wint_t	towctrans (wint_t, wctrans_t);
__stdargs wint_t	towupper (wint_t);
__stdargs wint_t	towlower (wint_t);
__stdargs wctrans_t wctrans (const char *);
__stdargs wctype_t wctype (const char *);

#if __POSIX_VISIBLE >= 200809
extern __stdargs int	iswalpha_l (wint_t, locale_t);
extern __stdargs int	iswalnum_l (wint_t, locale_t);
extern __stdargs int	iswblank_l (wint_t, locale_t);
extern __stdargs int	iswcntrl_l (wint_t, locale_t);
extern __stdargs int	iswctype_l (wint_t, wctype_t, locale_t);
extern __stdargs int	iswdigit_l (wint_t, locale_t);
extern __stdargs int	iswgraph_l (wint_t, locale_t);
extern __stdargs int	iswlower_l (wint_t, locale_t);
extern __stdargs int	iswprint_l (wint_t, locale_t);
extern __stdargs int	iswpunct_l (wint_t, locale_t);
extern __stdargs int	iswspace_l (wint_t, locale_t);
extern __stdargs int	iswupper_l (wint_t, locale_t);
extern __stdargs int	iswxdigit_l (wint_t, locale_t);
extern __stdargs wint_t	towctrans_l (wint_t, wctrans_t, locale_t);
extern __stdargs wint_t	towupper_l (wint_t, locale_t);
extern __stdargs wint_t	towlower_l (wint_t, locale_t);
extern __stdargs wctrans_t wctrans_l (const char *, locale_t);
extern __stdargs wctype_t wctype_l (const char *, locale_t);
#endif

_END_STD_C

#endif /* _WCTYPE_H_ */
