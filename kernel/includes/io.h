#ifndef IO_H
#define IO_H

// Read one byte from the port 
unsigned char inb(unsigned short port);

// Read one word from the port 
unsigned short inw(unsigned short port);

// output byte val to port 
void outb(unsigned short port, unsigned char val);

// output word val to port 
void outw(unsigned short port, unsigned char val);

//wait for io device to finish
void iowait();

#endif