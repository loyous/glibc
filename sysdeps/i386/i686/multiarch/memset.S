/* Multiple versions of memset
   All versions must be listed in ifunc-impl-list.c.
   Copyright (C) 2010-2016 Free Software Foundation, Inc.
   Contributed by Intel Corporation.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>
#include <init-arch.h>

/* Define multiple versions only for the definition in lib.  */
#if IS_IN (libc)
	.text
ENTRY(memset)
	.type	memset, @gnu_indirect_function
	LOAD_GOT_AND_RTLD_GLOBAL_RO
	LOAD_FUNC_GOT_EAX (__memset_ia32)
	HAS_CPU_FEATURE (SSE2)
	jz	2f
	LOAD_FUNC_GOT_EAX (__memset_sse2)
	HAS_CPU_FEATURE (Fast_Rep_String)
	jz	2f
	LOAD_FUNC_GOT_EAX (__memset_sse2_rep)
2:	ret
END(memset)

# undef ENTRY
# define ENTRY(name) \
	.type __memset_ia32, @function; \
	.globl __memset_ia32; \
	.p2align 4; \
	__memset_ia32: cfi_startproc; \
	CALL_MCOUNT
# undef END
# define END(name) \
	cfi_endproc; .size __memset_ia32, .-__memset_ia32

# undef ENTRY_CHK
# define ENTRY_CHK(name) \
	.type __memset_chk_ia32, @function; \
	.globl __memset_chk_ia32; \
	.p2align 4; \
	__memset_chk_ia32: cfi_startproc; \
	CALL_MCOUNT
# undef END_CHK
# define END_CHK(name) \
	cfi_endproc; .size __memset_chk_ia32, .-__memset_chk_ia32

# ifdef SHARED
#  undef libc_hidden_builtin_def
/* IFUNC doesn't work with the hidden functions in shared library since
   they will be called without setting up EBX needed for PLT which is
   used by IFUNC.  */
#  define libc_hidden_builtin_def(name) \
	.globl __GI_memset; __GI_memset = __memset_ia32
# endif

# undef strong_alias
# define strong_alias(original, alias)
#endif

#include "../memset.S"
