/*
 * Copyright (c) 2021 Loongson Technology Corporation Limited (www.loongson.cn)
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
 *	This product includes software developed by Opsycon AB, Sweden.
 * 4. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */


#include "asm.h"
#include "regnum.h"
#include "cpu.h"

#include "bonito.h"
#include "ls2k0300.h"

#include "cacheops.h"

#define DEBUG_LOCORE
#ifdef DEBUG_LOCORE
#define TTYDBG(x) \
	.section .rodata;98: .asciz x; .text; la a0, 98b; bl stringserial
#define TTYDBG_COM1(x) \
	.section .rodata;98: .asciz x; .text; la a0, 98b; bl stringserial_COM1
#else
#define TTYDBG(x)
#define TTYDBG_COM1(x)
#endif
#define	PRINTSTR TTYDBG
#define PRINT_CSR(offset)	\
	PRINTSTR("\r\ncsr 0x");	\
	li.w	a0, offset;	\
	bl	hexserial;	\
	PRINTSTR(" ->0x");	\
	csrrd	a0, offset;	\
	bl	hexserial64;	\
	PRINTSTR("\r\n");


#define CONFIG_CACHE_64K_4WAY 1
##define USEPCI

#define msize		s2

/*
 * Register usage:
 *
 * s0 link versus load offset, used to relocate absolute adresses.
 * s1 free
 * s2 memory size.
 * s3 st.dShape.
 * s4 Bonito base address.
 * s5 dbg.
 * s6 st.dCfg.
 * s7 rasave.
 * s8 L3 Cache size.
 */
    .globl	_start
    .globl	start
    .globl	__main
_start:
start:
	.globl	stack
stack = start + LOCK_CACHE_SIZE	 /* Place PMON stack in the end of 2M RAM */

	/* default mem config space: [5] default, [4] disable cfg space */
	li.w	t0, 0x16000100
	ld.w	t1, t0, 0x0
	li.w	t2, (1 << 5)
	or	t1, t1, t2
	st.w	t1, t0, 0x0

	/*close usb & ddr soft reset: [0] ddr, [7] usbm*/
	li.w  	t1, 0xffffff7e 
	st.w 	t1, t0, 0x1c

	/*unvalid ddr soft reset: [0] ddr*/
	ld.w	t1, t0, 0x1c
	ori     t1, t1, 0x1
	st.w 	t1, t0, 0x1c
	/* remove this code to C code */
	/*[103:96] en [111:104] coherent*/
	/*0:cpu    1:usb     2:gmac0    3:gmac1   4:dc   
		5:apb-dma(sdio spi can .etc)*/
	li.w	t0, 0x1600010c
	ld.w	t1, t0, 0x0
	li.w	t2, ((0x1f << 1) | (0x1f << 9))  //cache coherent for usb/gmac0/gmac1/dc
	or	t1, t1, t2
	st.w	t1, t0, 0x0

	li.d	t0, (1 << (24 + 32))	//set CPUCFG 0 bit24
	csrxchg	t0, t0, 0xc0

	li.d	t0, (0xa << (16 + 32))	//set CPUCFG 0x13 bit16-23
	li.d	t1, (0xff << (16 + 32))
	csrxchg	t0, t1, 0xc9

	/* enable perf counter as cp0 counter */
	li.w	t0, (0x1 << 16)
	csrxchg t0, t0, 0x200

	/* pll setting */
	li.d	t0, 0x0001000107270e00
	csrwr	t0, 0xc2
	li.d	t0, UNCACHED_MEMORY_ADDR | 0xf
	csrwr	t0, 0x180
	li.d	t0, CACHED_MEMORY_ADDR | 0x1f
	csrwr	t0, 0x181

    li.d    t0, 0x8000000016010000
    li.w    t1, 0x47
    st.b    t1, t0, 0x4

/*
 * should before execution jr shutdown slave core
 * otherwise speculative execution cause error
 */
	/* clear Vint cofigure */
	li.d	t0, (0x7 << 16)
	csrxchg zero, t0, 0x4
	/* set ebase address */
	li.d	t0, PHYS_TO_CACHED(0x1c001000)
	csrwr	t0, 0xc
	/* set TLB excption address */
	li.d	t0, 0x000000001c001000
	csrwr	t0, 0x88

	/* disable interrupt */
	li.d	t0, (1 << 2)
	csrxchg zero, t0, 0x0
	

	/* don't change this code,jumping to cached address */
	li.d	t1, CACHED_MEMORY_ADDR
	pcaddi	t0, 3
	or	t0, t1, t0
	jirl	zero, t0, 0
	/* now pc run to 0x90xxxxxxxxxxxxxx */
	/* change to PG-mode from DA-mode */
	li.w	t0, 0xb0
	csrwr	t0, 0x0

	bl watchdog_close
	/* calculate ASM stage print function s0 address */
	la	s0, start
	li.d	a0, PHYS_TO_CACHED(0x1c000000)
	/* if change locked cache address may need change the following code */
	sub.d	s0, s0, a0

	la	sp, stack
	la	gp, _gp

	/* config uart, use gpio[40 41] */
	li.d	t0, PHYS_TO_UNCACHED(0x16000498)
	ld.w	t1, t0, 0x0
	li.w	t2, 0xf0000
	or	t1, t1, t2
	st.w	t1, t0, 0x0

	li.d	a0, COM1_BASE_ADDR
	bl	initserial

bsp_start:
	PRINTSTR("\r\nPMON2000 LOONGARCH Initializing. Standby...\r\n")
	dbar 0
	ibar 0

	bl	locate			/* Get current execute address */

	/* all exception entry */
	.org 0x1000
1:
	b	1b
	/* s0 in different stage should fixup */
	la	a0, start
	li.d	a1, PHYS_TO_UNCACHED(0x1c000000)
	sub.d	a0, a0, a1
	li.d	a1, 0x00000000ffff0000
	and	a0, a0, a1
	beq	a0, s0, 1f
	move	s0, zero
1:
	and	s0, s0, a0
	csrrd	t0, 0x8a
	andi	t0, t0, 0x1
	bnez	t0, 2f

	PRINTSTR("\r\nCPU Trigger exception!\r\n")
	PRINT_CSR(0x4);
	PRINT_CSR(0x5);
	PRINT_CSR(0x6);
	PRINT_CSR(0x7);
	PRINT_CSR(0x8);
1:
	b	1b
2:
	li.d	t1, CACHED_MEMORY_ADDR
	bl	1f
1:
	addi.d	t0, ra, 12
	or	t0, t1, t0
	jirl	zero, t0, 0

	li.d	t0, 0xb0
	csrwr	t0, 0
	PRINTSTR("\r\nTLB exception!\r\n");
	PRINT_CSR(0x89);
	PRINT_CSR(0x8a);
1:
	b	1b

locate:

	TTYDBG ("Soft CLK SEL adjust begin\r\n")
	TTYDBG ("\r\nNODE	:")
	
	li.d	t0, PHYS_TO_UNCACHED(0x16000400)
	li.w	t1, (0x1 << 5)	//power down pll L1 first
	st.w	t1, t0, 0
	li.w	t4, (NODE_DIV << 24) | (NODE_LOOPC << 15) | (NODE_REFC << 8)
	st.w	t4, t0, 0

	ld.w	t1, t0, 4
	li.w	t2, ~((0x7f << 8) | 0x7f)
	and	t1, t1, t2
	li.w	t2, (I2S_DIV << 8) | (GMAC_DIV)
	or	t2, t2, t1
	st.w	t2, t0, 0x4
	
	
	ori	t4, t4, PLL_L1_ENA
	st.w	t4, t0, 0

11:
	ld.w	a0, t0, 0
	li.w	a1, PLL_L1_LOCKED
	and	a0, a1, a0
	beqz	a0, 11b //wait_locked_sys

	ld.w	a0, t0, 0
	ori	a0, a0, SEL_PLL0 | SEL_PLL1 | SEL_PLL2
	st.w	a0, t0, 0

	bl	hexserial

#if 0
/*switch uart to 100M */
	li.d	a0, COM1_BASE_ADDR
	li.w	a1, 0x80
	st.b	a1, a0, 3

	li.d    a1, 0x36
	st.b    a1, a0, 0

	li.d    a1, 3
	st.b    a1, a0, 3
	bl	hexserial
#endif
	TTYDBG ("\r\nPLL CONFIGURE DONE!\r\n")
start_now:
	PRINTSTR("\r\nPMON2000 LOONGARCH Initializing. Standby...\r\n")

	PRINTSTR("\r\nlock scache ")
	li.d	a0, LOCK_CACHE_BASE
	bl	hexserial
	PRINTSTR(" - ")
	li.d	a0, LOCK_CACHE_BASE + LOCK_CACHE_SIZE
	bl	hexserial

	li.d	t0, PHYS_TO_UNCACHED(0x16000200)
	li.d	t1, ~(LOCK_CACHE_SIZE - 1)
	st.d	t1, t0, 0x40
	li.d	t1, (LOCK_CACHE_BASE & 0xffffffffffff) | (1 << 63)
	st.d	t1, t0, 0x0

	dbar 0x0

	PRINTSTR("\r\nLock Scache Done.\r\n")

	/* copy flash code to scache */
	li.d	a1, PHYS_TO_CACHED(0x1c000000)
	la	a0, start
	la	a2, edata
1:
	ld.d	a3, a1, 0
	st.d	a3, a0, 0
	addi.d	a0, a0, 8
	addi.d	a1, a1, 8
	bne	a2, a0, 1b

	PRINTSTR("copy text section to lock cache done.\r\n")
	/*clear cache mem BSS in this space*/
	la	a0, _edata
	la	a1, _end
1:
	st.d	zero, a0, 0
	addi.d	a0, a0, 8
	blt	a0, a1, 1b

	ibar 0

#if 0
	li.d	a0, LOCK_CACHE_BASE
	li.d	a1, LOCK_CACHE_BASE + LOCK_CACHE_SIZE
1:
	/* ensure locked cache address accessible so this code can`t remove*/
	ld.d	zero, a0, 0
	addi.d	a0, a0, 0x40
	bne	a1, a0, 1b
#endif

	/* jump to locked cache address */
	la.abs  t0, LC
	jirl    zero, t0, 0
LC:
	move	s0, zero
	PRINTSTR("run in cache.\r\n")

	//la      ra, cache_main
	la      ra, main
	jirl	zero, ra, 0

LEAF(get_cpuprid)
	csrrd	a0, 0xc0
	jirl	zero, ra, 0
END(get_cpuprid)

/*
 * Simple character printing routine used before full initialization
 */
/* baud rate definitions, matching include/termios.h */
#define B0	0
#define B50	50
#define B75	75
#define B110	110
#define B134	134
#define B150	150
#define B200	200
#define B300	300
#define B600	600
#define B1200	1200
#define B1800	1800
#define B2400	2400
#define B4800	4800
#define B9600	9600
#define B19200	19200
#define B38400	38400
#define B57600	57600
#define B115200	115200

#define UART_REF_CLK	100000000
#define UART_DIV_HI	(((UART_REF_CLK + (115200*8)) / (115200*16)) >> 8)
#define UART_DIV_LO	(((UART_REF_CLK + (115200*8)) / (115200*16)) & 0xff)
/*************************************
 *used: a0~a1
 *************************************/
LEAF(initserial)
	li.d	a0, COM1_BASE_ADDR
	li.w	a1, 0x80
	st.b	a1, a0, 3

	/*120M*/
	li.d    a1, 0x41
	st.b    a1, a0, 0
	/* divider, highest possible baud rate*/
	li.d    a1, 0x0
	st.b    a1, a0, 1
	li.d    a1, 3
	st.b    a1, a0, 3

	li.d    a1, 0
	st.b    a1, a0, 1

	li.d    a1, 71
	st.b    a1, a0, 2
	jirl    zero, ra, 0
END(initserial)

/******************************************************
 *used: a0~a2
 ******************************************************/
LEAF(tgt_putchar)
	li.d	a1, COM1_BASE_ADDR
1:
	ld.bu	a2, a1, 0x5
	andi	a2, a2, 0x20
	beqz	a2, 1b

	st.b	a0, a1, 0
	//	or	a2, zero, a1

	jirl	zero, ra, 0
END(tgt_putchar)

/******************************************************
 *used: a0~a4, s0
 ******************************************************/
LEAF(stringserial)
	or	a4, ra, zero
	sub.d	a3, a0, s0
	ld.bu	a0, a3, 0
1:
	beqz	a0, 2f

	bl	tgt_putchar

	addi.d	a3, a3, 1
	ld.bu	a0, a3, 0
	b	1b

2:
	ori	ra, a4, 0
	jirl	zero, ra, 0
END(stringserial)

/*****************************************************
 *used: a0~a5, s0
 *****************************************************/
LEAF(hexserial)
	ori	a4, ra, 0
	ori	a3, a0, 0
	li.d	a5, 8
1:
	rotri.w a0, a3, 28
	or	a3, a0, zero
	andi	a0, a0, 0xf

	la	a1, hexchar
	sub.d	a1, a1, s0

	add.d	a1, a1, a0
	ld.bu	a0, a1, 0

	bl	tgt_putchar

	addi.d	a5, a5, -1
	bnez	a5, 1b

	ori	ra, a4, 0
	jirl	zero, ra, 0
END(hexserial)


/*****************************************************
 *used: a0~a5, s0
 *****************************************************/
LEAF(hexserial64)
	ori	a4, ra, 0
	ori	a3, a0, 0
	li.d	a5, 16
1:
	rotri.d a0, a3, 60
	or	a3, a0, zero
	andi	a0, a0, 0xf

	la	a1, hexchar
	sub.d	a1, a1, s0

	add.d	a1, a1, a0
	ld.bu	a0, a1, 0

	bl	tgt_putchar

	addi.d	a5, a5, -1
	bnez	a5, 1b

	ori	ra, a4, 0
	jirl	zero, ra, 0
END(hexserial64)

	.section .rodata
hexchar:
	.ascii	"0123456789abcdef"
	.text
	.align 5

LEAF(watchdog_close)
	li.d	t1, PHYS_TO_UNCACHED(0x16124000)
	ld.w	t2, t1, 0x0
	li.w	t3, ~0x2
	and	t2, t2, t3
	st.w	t2, t1, 0x0
	jirl	zero, ra, 0
END(watchdog_close)

// todo ?????
#if 1
    .text
    .global  nvram_offs
    .align 12
nvram_offs:
    .dword 0x0
    .align 12
#endif
