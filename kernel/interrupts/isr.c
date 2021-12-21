#include "isr.h"

// This gets called from our ASM interrupt handler stub.
// the argument for this function has already been set in the stack in interrupt.asm
void isr_handler(registers_t regs)
{	
	print_str("\n");
	print_str("\n");
    print_str("recieved interrupt: ");
    print_int(regs.int_no);
}