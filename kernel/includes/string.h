#ifndef STRING_H
#define STRING_H
#include "type.h"
char *strcpy(char *dest, const char *src);
int strcmp(char *str1, char *str2);
char *strcat(char *dest, const char *src);
int strlen(const char *ptr);
void int_to_ascii(int n, char str[]);
void reverse(char s[]);
void backspace(char s[]);
void hex_to_ascii(int n, char str[]);
#endif