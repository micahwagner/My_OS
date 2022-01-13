#include "idt.h"

#define PICM		0x20		// IO base address for master PIC 
#define PICS		0xA0		// IO base address for slave PIC 
#define PICM_COMMAND	PICM
#define PICM_DATA	(PICM+1)
#define PICS_COMMAND	PICS
#define PICS_DATA	(PICS+1)

/* existing IRQ's (interrupt requests from external devices such as a keyboard)
are mapped to interrupt numbers 0x8 - 0xf. these mappings conflict with the
mappings our CPU has. To fix this, we need to remap the PIC (programmable interrupt controller).
To reset the PIC, the PIC expects an ICW (intialize control word). The ICW is 4 bytes.
The first byte (ICW1) must be written out to the command IO address (0x20 and 0xA0). The rest
of the bytes are written to the data IO address (0x21 and 0xA1).
*/

//anything that isn't specified should always be 0

#define ICW1_ICW4	0x01		// (1) ICW4 needed (0) not needed 
#define ICW1_SINGLE	0x02		// (1)Single or (0)cascade mode 
#define ICW1_INTERVAL4	0x04	// Call address interval (1)4 or (0)8 
#define ICW1_LEVEL	0x08		// operation mode 
#define ICW1_INIT	0x10		// Initialization - always 1

#define ICW2_M	0x20			// Master PIC maps IRQ's to ints 32 - 39 (31 is the last cpu defined int)
#define ICW2_S	0x28			// Slave PIC maps IRQ's to ints 40 - 47

#define ICW3_M	0x04			// which of the Master PIC inputs are mapped to which slave PIC
#define ICW3_S	0x02			// ID of slave PIC
 
#define ICW4_8086	0x01		// (1) 8086/88 or (0) MCS-80/85 mode 
#define ICW4_AUTO	0x02		// (1) Auto or (0) normal EOI 
#define ICW4_BUF_SLAVE	0x08	// Buffered mode/slave 
#define ICW4_BUF_MASTER	0x0C	// Buffered mode/master 
#define ICW4_SFNM	0x10		// Special fully nested 

// Lets us access our ASM functions from our C code.
extern void idt_flush(u32int);
extern isr_t interrupt_handlers[];


// Internal function prototypes.
static void init_idt();
static void idt_set_gate(u8int,u32int,u16int,u8int);

idt_entry_t idt_entries[256];
idt_ptr_t   idt_ptr;

void init_interrupts() {
	init_idt();
    mem_set(&interrupt_handlers, 0, sizeof(isr_t)*256);

}

static void init_idt()
{
    idt_ptr.limit = sizeof(idt_entry_t) * 256 - 1;
    idt_ptr.base  = (u32int)&idt_entries;

    mem_set(&idt_entries, 0, sizeof(idt_entry_t)*256);

    u8int a1, a2;
 
    a1 = inb(PICM_DATA);                        // save masks
    a2 = inb(PICS_DATA);
    
    // remap PIC IRQ's

    // (ICW1) Starts initialize sequence, specifying to expect ICW4 and start in 
    outb(PICM_COMMAND, ICW1_INIT | ICW1_ICW4);
    outb(PICS_COMMAND, ICW1_INIT | ICW1_ICW4);

    // (ICW2) set IRQ's to int 32 - 47
    outb(PICM_DATA, ICW2_M);
    outb(PICS_DATA, ICW2_S);

    // (ICW3) set Master PIC input to Slave with ID of 2
    outb(PICM_DATA, ICW3_M);
    outb(PICS_DATA, ICW3_S);

    // (ICW4) set 8086 mode
    outb(PICM_DATA, ICW4_8086);
    outb(PICS_DATA, ICW4_8086);

    outb(PICM_DATA, a1);   // restore saved masks.
    outb(PICS_DATA, a2);


    idt_set_gate( 0, (u32int)isr0 , 0x08, 0x8E);
    idt_set_gate( 1, (u32int)isr1 , 0x08, 0x8E);
    idt_set_gate( 2, (u32int)isr2 , 0x08, 0x8E);
    idt_set_gate( 3, (u32int)isr3 , 0x08, 0x8E);
    idt_set_gate( 4, (u32int)isr4 , 0x08, 0x8E);
    idt_set_gate( 5, (u32int)isr5 , 0x08, 0x8E);
    idt_set_gate( 6, (u32int)isr6 , 0x08, 0x8E);
    idt_set_gate( 7, (u32int)isr7 , 0x08, 0x8E);
    idt_set_gate( 8, (u32int)isr8 , 0x08, 0x8E);
    idt_set_gate( 9, (u32int)isr9 , 0x08, 0x8E);
    idt_set_gate(10, (u32int)isr10, 0x08, 0x8E);
    idt_set_gate(11, (u32int)isr11, 0x08, 0x8E);
    idt_set_gate(12, (u32int)isr12, 0x08, 0x8E);
    idt_set_gate(13, (u32int)isr13, 0x08, 0x8E);
    idt_set_gate(14, (u32int)isr14, 0x08, 0x8E);
    idt_set_gate(15, (u32int)isr15, 0x08, 0x8E);
    idt_set_gate(16, (u32int)isr16, 0x08, 0x8E);
    idt_set_gate(17, (u32int)isr17, 0x08, 0x8E);
    idt_set_gate(18, (u32int)isr18, 0x08, 0x8E);
    idt_set_gate(19, (u32int)isr19, 0x08, 0x8E);
    idt_set_gate(20, (u32int)isr20, 0x08, 0x8E);
    idt_set_gate(21, (u32int)isr21, 0x08, 0x8E);
    idt_set_gate(22, (u32int)isr22, 0x08, 0x8E);
    idt_set_gate(23, (u32int)isr23, 0x08, 0x8E);
    idt_set_gate(24, (u32int)isr24, 0x08, 0x8E);
    idt_set_gate(25, (u32int)isr25, 0x08, 0x8E);
    idt_set_gate(26, (u32int)isr26, 0x08, 0x8E);
    idt_set_gate(27, (u32int)isr27, 0x08, 0x8E);
    idt_set_gate(28, (u32int)isr28, 0x08, 0x8E);
    idt_set_gate(29, (u32int)isr29, 0x08, 0x8E);
    idt_set_gate(30, (u32int)isr30, 0x08, 0x8E);
    idt_set_gate(31, (u32int)isr31, 0x08, 0x8E);
    idt_set_gate(32, (u32int)irq0 , 0x08, 0x8E);
    idt_set_gate(33, (u32int)irq1 , 0x08, 0x8E);
    idt_set_gate(34, (u32int)irq2 , 0x08, 0x8E);
    idt_set_gate(35, (u32int)irq3 , 0x08, 0x8E);
    idt_set_gate(36, (u32int)irq4 , 0x08, 0x8E);
    idt_set_gate(37, (u32int)irq5 , 0x08, 0x8E);
    idt_set_gate(38, (u32int)irq6 , 0x08, 0x8E);
    idt_set_gate(39, (u32int)irq7 , 0x08, 0x8E);
    idt_set_gate(40, (u32int)irq8 , 0x08, 0x8E);
    idt_set_gate(41, (u32int)irq9 , 0x08, 0x8E);
    idt_set_gate(42, (u32int)irq10, 0x08, 0x8E);
    idt_set_gate(43, (u32int)irq11, 0x08, 0x8E);
    idt_set_gate(44, (u32int)irq12, 0x08, 0x8E);
    idt_set_gate(45, (u32int)irq13, 0x08, 0x8E);
    idt_set_gate(46, (u32int)irq14, 0x08, 0x8E);
    idt_set_gate(47, (u32int)irq15, 0x08, 0x8E);

    idt_flush((u32int)&idt_ptr);
}

static void idt_set_gate(u8int num, u32int base, u16int sel, u8int flags)
{
    idt_entries[num].base_lo = base & 0xFFFF;
    idt_entries[num].base_hi = (base >> 16) & 0xFFFF;

    idt_entries[num].sel     = sel;
    idt_entries[num].always0 = 0;
    // We must uncomment the OR below when we get to using user-mode.
    // It sets the interrupt gate's privilege level to 3.
    idt_entries[num].flags   = flags /* | 0x60 */;
}