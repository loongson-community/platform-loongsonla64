OUTPUT_FORMAT("elf64-loongarch", "elf64-loongarch",
              "elf64-loongarch")
OUTPUT_ARCH(loongarch)
ENTRY(_start)
SECTIONS
{
  . = 0x9000000000000000+0x90000000;
  .text :
  {
    _ftext = . ;
    *(.text)
    *(.rodata)
    *(.rodata1)
    *(.reginfo)
    *(.init)
    *(.stub)
    *(.gnu.warning)
  } =0
  _etext = .;
  PROVIDE (etext = .);
  .fini : { *(.fini) } =0
  .data :
  {
    _fdata = . ;
    *(.data)
   . = ALIGN(4);
     /* init data */
     PROVIDE_HIDDEN (__init_array_start = .);
     KEEP(*(SORT(.init_array.*)))
     KEEP(*(.init_array))
     PROVIDE_HIDDEN (__init_array_end = .);
   . = ALIGN(32);
   *(.data.align32)
   . = ALIGN(64);
   *(.data.align64)
   . = ALIGN(128);
   *(.data.align128)
   . = ALIGN(4096);
   *(.data.align4096)
    CONSTRUCTORS
  }
  .data1 : { *(.data1) }
  .ctors :
  {
                __CTOR_LIST__ = .;
                LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
               *(.init_array)
                LONG(0)
                __CTOR_END__ = .;
  }
  .dtors :
  {
                __DTOR_LIST__ = .;
                LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2)
               *(.fini_array)
                LONG(0)
                __DTOR_END__ = .;
  }
  _gp = ALIGN(16) + 0x7ff0;
  .got :
  {
    *(.got.plt) *(.got)
   }
  .sdata : { *(.sdata) }
  .lit8 : { *(.lit8) }
  .lit4 : { *(.lit4) }
  _edata = .;
  PROVIDE (edata = .);
  __bss_start = .;
  _fbss = .;
  .sbss : { *(.sbss) *(.scommon) }
  .bss :
  {
   *(.dynbss)
   *(.bss)
   . = ALIGN(32);
   *(.bss.align32)
   . = ALIGN(64);
   *(.bss.align64)
   . = ALIGN(128);
   *(.bss.align128)
   . = ALIGN(4096);
   *(.bss.align4096)
   *(COMMON)
  }
  _end = . ;
  PROVIDE (end = .);
  PROVIDE (bss_end = .);
  . = ALIGN(32);
  .biosdata : { *(.biosdata) }
  PROVIDE (biosdata_end = .);
  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  .debug 0 : { *(.debug) }
  .debug_srcinfo 0 : { *(.debug_srcinfo) }
  .debug_aranges 0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  .debug_sfnames 0 : { *(.debug_sfnames) }
  .line 0 : { *(.line) }
  .gptab.sdata : { *(.gptab.data) *(.gptab.sdata) }
  .gptab.sbss : { *(.gptab.bss) *(.gptab.sbss) }
}
