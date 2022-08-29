#include "isr.h"


isr_t interrupt_handlers[256];


void register_interrupt_handler(uint8_t n, isr_t handler)
{
    interrupt_handlers[n] = handler;
}

// This gets called from our ASM interrupt handler stub.
// the argument for this function has already been set in the stack in interrupt.asm
void isr_handler(registers_t *regs)
{	
    if (interrupt_handlers[regs->int_no] != 0)
    {
		interrupt_handlers[regs->int_no](regs);
    } else {
    	print_str("\n");
    	print_str("unhandled interrupt: ");
    	print_int(regs->int_no);
    }
}

// This gets called from our ASM interrupt handler stub.
void irq_handler(registers_t *regs)
{
    // Send an EOI (end of interrupt) signal to the PICs.
    // If this interrupt involved the slave.
    if (regs->int_no >= 40)
    {
        // Send reset signal to slave.
        outb(PICS_COMMAND, EOI);
    }
    // Send reset signal to master and slave
    outb(PICM_COMMAND, EOI);

    if (interrupt_handlers[regs->int_no] != 0)
    {
        interrupt_handlers[regs->int_no](regs);
    }

}