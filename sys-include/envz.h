/* Copyright (C) 2002 by  Red Hat, Incorporated. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software
 * is freely granted, provided that this notice is preserved.
 */

#include <errno.h>
#include <sys/types.h>

/* The newlib implementation of these functions assumes that sizeof(char) == 1. */
__stdargs char * envz_entry (const char *envz, size_t envz_len, const char *name);
__stdargs char * envz_get (const char *envz, size_t envz_len, const char *name);
__stdargs error_t envz_add (char **envz, size_t *envz_len, const char *name, const char *value);
__stdargs error_t envz_merge (char **envz, size_t *envz_len, const char *envz2, size_t envz2_len, int override);
__stdargs void envz_remove(char **envz, size_t *envz_len, const char *name);
__stdargs void envz_strip (char **envz, size_t *envz_len);
