#include "mem.h"

void copy_mem(u8int *source, u8int *dest, u32int nbytes) {
	int i;
	for(i = 0; i < nbytes; i++) {
		*(dest+i) = *(source+i); 
	}
}

void mem_set(u8int *dest, u8int val, u32int len) {
	int i;
	for(i = 0; i < len; i++) {
		*(dest+i) = val; 
	}
}