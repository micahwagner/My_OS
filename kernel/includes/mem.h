#ifndef MEM_H
#define MEM_H
#include "type.h"
void copy_mem(u8int *source, u8int *dest, u32int nbytes);
void mem_set(u8int *dest, u8int val, u32int len);
#endif