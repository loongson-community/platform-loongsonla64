#include <types.h>
#include "ls2k0300.h"
#include "bonito.h"

#define  pr_info(fmt, args...) early_printf(fmt, ##args)
void main(unsigned long long msize)
{
	pr_info("mem init done!\n");
	while(1);
}
