#include "mem.h"

void copy_mem(uint8_t *source, uint8_t *dest, uint32_t nbytes) {
	int i;
	for(i = 0; i < nbytes; i++) {
		*(dest+i) = *(source+i); 
	}
}

void mem_set(uint8_t *dest, uint8_t val, uint32_t len) {
	int i;
	for(i = 0; i < len; i++) {
		*(dest+i) = val; 
	}
}