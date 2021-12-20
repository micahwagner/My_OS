#include "string.h"

// Compare two strings. Should return -1 if 
// str1 < str2, 0 if they are equal or 1 otherwise.
// int strcmp(char *str1, char *str2) {
    
// }

// Copy the NULL-terminated string src into dest, and
// return dest.
s8int *strcpy(s8int *dest, const s8int *src) {
	s8int *tmp = dest;
    while (*src != 0) {
        *tmp = *src;
        src++;
        tmp++;
    }
    *tmp = 0;
    return dest;
}

// Concatenate the NULL-terminated string src onto
// the end of dest, and return dest.
// char *strcat(char *dest, const char *src) {

// }
// return the length of string
int strlen(const s8int *ptr) {
    int i = 0;
    while(*ptr != 0) {
        i++;
        ptr++;
    }

    return i;
}