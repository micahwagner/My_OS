#include "string.h"

// Compare two strings. Should return -1 if 
// str1 < str2, 0 if they are equal or 1 otherwise.
int strcmp(char *str1, char *str2) {
    
}

// Copy the NULL-terminated string src into dest, and
// return dest.
char *strcpy(char *dest, const char *src) {

}

// Concatenate the NULL-terminated string src onto
// the end of dest, and return dest.
char *strcat(char *dest, const char *src) {

}
// return the length of string
int strlen(const char *ptr) {
    int i = 0;
    while(*ptr != 0) {
        i++;
        ptr++;
    }

    return i;
}