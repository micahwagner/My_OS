#ifndef MEM_H
#define MEM_H
#include "type.h"
void copy_mem(uint8_t *source, uint8_t *dest, uint32_t nbytes);
void mem_set(uint8_t *dest, uint8_t val, uint32_t len);
#endif