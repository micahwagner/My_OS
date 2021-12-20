#ifndef STRING_H
#define STRING_H
#include "type.h"
s8int *strcpy(s8int *dest, const s8int *src);
s32int strcmp(s8int *str1, s8int *str2);
void int_to_ascii(s32int n, s8int str[]);
void reverse(s8int s[]);
#endif