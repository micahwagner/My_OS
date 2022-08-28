#include "idt.h"

// interrupt gates disable interrupts when they are running there handlers, trap gates don't do that
#define _32INT_GATE 0x8E  // p=1, DPL=00, reserved 0, 0xE: 32-bit Interrupt Gate, 1000 1110
#define KERNEL_CODE_SEG 0x08 //0x08 is the kernel code selector in our GDT


// Lets us access our ASM functions from our C code.
extern void idt_flush(u32int);
extern isr_t interrupt_handlers[256];


// Internal function prototypes.
void init_idt();
void idt_set_gate(u8int,u32int,u16int,u8int);

idt_entry_t idt_entries[256];
idt_ptr_t   idt_ptr;

void init_interrupts() {
	init_idt();
    mem_set((unsigned char *)interrupt_handlers, 0, sizeof(isr_t)*256);

}

void init_idt()
{
    idt_ptr.limit = sizeof(idt_entry_t) * 256 - 1;
    idt_ptr.base  = (u32int)idt_entries;

    mem_set((unsigned char *)idt_entries, 0, sizeof(idt_entry_t)*256);

    init_pic();

    idt_set_gate( 0, (u32int)isr0 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 1, (u32int)isr1 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 2, (u32int)isr2 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 3, (u32int)isr3 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 4, (u32int)isr4 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 5, (u32int)isr5 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 6, (u32int)isr6 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 7, (u32int)isr7 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 8, (u32int)isr8 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate( 9, (u32int)isr9 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(10, (u32int)isr10, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(11, (u32int)isr11, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(12, (u32int)isr12, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(13, (u32int)isr13, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(14, (u32int)isr14, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(15, (u32int)isr15, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(16, (u32int)isr16, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(17, (u32int)isr17, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(18, (u32int)isr18, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(19, (u32int)isr19, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(20, (u32int)isr20, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(21, (u32int)isr21, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(22, (u32int)isr22, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(23, (u32int)isr23, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(24, (u32int)isr24, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(25, (u32int)isr25, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(26, (u32int)isr26, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(27, (u32int)isr27, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(28, (u32int)isr28, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(29, (u32int)isr29, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(30, (u32int)isr30, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(31, (u32int)isr31, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(32, (u32int)irq0 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(33, (u32int)irq1 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(34, (u32int)irq2 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(35, (u32int)irq3 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(36, (u32int)irq4 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(37, (u32int)irq5 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(38, (u32int)irq6 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(39, (u32int)irq7 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(40, (u32int)irq8 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(41, (u32int)irq9 , KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(42, (u32int)irq10, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(43, (u32int)irq11, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(44, (u32int)irq12, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(45, (u32int)irq13, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(46, (u32int)irq14, KERNEL_CODE_SEG, _32INT_GATE);
    idt_set_gate(47, (u32int)irq15, KERNEL_CODE_SEG, _32INT_GATE);

    idt_flush((u32int)&idt_ptr);
}

void idt_set_gate(u8int num, u32int base, u16int sel, u8int flags)
{
    idt_entries[num].base_lo = base & 0xFFFF;
    idt_entries[num].base_hi = (base >> 16) & 0xFFFF;

    idt_entries[num].sel     = sel;
    idt_entries[num].always0 = 0;
    // We must uncomment the OR below when we get to using user-mode.
    // It sets the interrupt gate's privilege level to 3.
    idt_entries[num].flags   = flags /* | 0x60 */;
}