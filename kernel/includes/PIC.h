#ifndef PIC_H
#define PIC_H

#include "type.h"
#include "io.h"


void init_pic();

#define PICM		0x20		// IO base address for master PIC 
#define PICS		0xA0		// IO base address for slave PIC 
#define PICM_COMMAND	PICM
#define PICM_DATA	(PICM+1)
#define PICS_COMMAND	PICS
#define PICS_DATA	(PICS+1)

//anything that isn't specified should always be 0

#define ICW1_ICW4	0x01		// (1) ICW4 needed (0) not needed 
#define ICW1_SINGLE	0x02		// (1)Single or (0)cascade mode 
#define ICW1_INTERVAL4	0x04	// Call address interval (1)4 or (0)8 
#define ICW1_LEVEL	0x08		// operation mode 
#define ICW1_INIT	0x10		// Initialization - always 1

#define ICW2_M	0x20			// Master PIC maps IRQ's to ints 32 - 39 (31 is the last cpu defined int)
#define ICW2_S	0x28			// Slave PIC maps IRQ's to ints 40 - 47

#define ICW3_M	0x04			// which of the Master PIC inputs are mapped to which slave PIC (IR 2) for communication
#define ICW3_S	0x02			// ID of slave PIC IRQ to communicate with master
 
#define ICW4_8086	0x01		// (1) 8086/88 or (0) MCS-80/85 mode 
#define ICW4_AUTO	0x02		// (1) Auto or (0) normal EOI 
#define ICW4_BUF_SLAVE	0x08	// Buffered mode/slave 
#define ICW4_BUF_MASTER	0x0C	// Buffered mode/master 
#define ICW4_SFNM	0x10		// Special fully nested 

#define EOI 0x20 				// signals PIC that interrupt has been handled 
#endif