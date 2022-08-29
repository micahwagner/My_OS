#include "PIC.h"

/* existing IRQ's (interrupt requests from external devices such as a keyboard)
are mapped to interrupt numbers 0x8 - 0xf. these mappings conflict with the
mappings our CPU has from the BIOS. To fix this, we need to remap the PIC (programmable interrupt controller).
To reset the PIC, the PIC expects an ICW (intialize control word). The ICW is 4 bytes.
The first byte (ICW1) must be written out to the command IO address (0x20 and 0xA0). The rest
of the bytes are written to the data IO address (0x21 and 0xA1). see below for a more thorough explanation.

for more info, check out http://www.brokenthorn.com/Resources/OSDevPic.html

*/




void init_pic() {
	u8int a1, a2;

 	// save masks
    a1 = inb(PICM_DATA); 
    a2 = inb(PICS_DATA);
    
    // remap PIC IRQ's 
    // (ICW1) Starts initialize sequence, specifying to expect ICW4 and setting initialization bit 
    outb(PICM_COMMAND, ICW1_INIT | ICW1_ICW4);
    outb(PICS_COMMAND, ICW1_INIT | ICW1_ICW4);

    // (ICW2) set IRQ's to int 32 - 47
    outb(PICM_DATA, ICW2_M);
    outb(PICS_DATA, ICW2_S);

    // (ICW3) set IRQ 2 for communication between slave and master PIC
    outb(PICM_DATA, ICW3_M);
    outb(PICS_DATA, ICW3_S);

    // (ICW4) set 8086 mode
    outb(PICM_DATA, ICW4_8086);
    outb(PICS_DATA, ICW4_8086);

    outb(PICM_DATA, a1);   // restore saved masks.
    outb(PICS_DATA, a2);
}