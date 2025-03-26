/*	$OpenBSD: cpu.h,v 1.4 1998/09/15 10:50:12 pefo Exp $	*/

/*-
 * Copyright (c) 1992, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Ralph Campbell and Rick Macklem.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	Copyright (C) 1989 Digital Equipment Corporation.
 *	Permission to use, copy, modify, and distribute this software and
 *	its documentation for any purpose and without fee is hereby granted,
 *	provided that the above copyright notice appears in all copies.
 *	Digital Equipment Corporation makes no representations about the
 *	suitability of this software for any purpose.  It is provided "as is"
 *	without express or implied warranty.
 *
 *	from: @(#)cpu.h	8.4 (Berkeley) 1/4/94
 */

#ifndef _LOONGARCH_CPU_H_
#define _LOONGARCH_CPU_H_

#include <psl.h>

#define KUSEG_ADDR		0x0
#define CACHED_MEMORY_ADDR	0x9000000000000000
#define UNCACHED_MEMORY_ADDR	0x8000000000000000
#define MAX_MEM_ADDR		PHYS_TO_UNCACHED(0x1e000000)
#define	RESERVED_ADDR		PHYS_TO_UNCACHED(0x1fc80000)
#define IS_CACHED_ADDR(x)	(!!(((x) & 0xff00000000000000ULL) == CACHED_MEMORY_ADDR))

#define CACHED_TO_PHYS(x)	VA_TO_PHYS(x)
#define UNCACHED_TO_PHYS(x)	VA_TO_PHYS(x)
#define PHYSADDR(x)		VA_TO_PHYS(x)
#define	PHYS_TO_CACHED(x)	((x) | CACHED_MEMORY_ADDR)
#define	PHYS_TO_UNCACHED(x) 	((x) | UNCACHED_MEMORY_ADDR)
#define	CACHED_TO_UNCACHED(x)	(PHYS_TO_UNCACHED(VA_TO_PHYS(x)))
#define UNCACHED_TO_CACHED(x)	(PHYS_TO_CACHED(VA_TO_PHYS(x)))
#define VA_TO_PHYS(x)		((x) & 0xffffffffffff)
#endif /* !_LOONGARCH_CPU_H_ */
