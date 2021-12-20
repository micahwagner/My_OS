#include "string.h"

// Compare two strings. Should return -1 if 
// str1 < str2, 0 if they are equal or 1 otherwise.
s32int strcmp(s8int *str1, s8int *str2) {
    const u8int *s1 = (const u8int *) str1;
  	const u8int *s2 = (const u8int *) str2;
  	u8int c1, c2;

  	do {
  		c1 = (u8int) *s1++;
  		c2 = (u8int) *s2++;

  		if(c1 == 0) {
  			return c1 - c2;
  		}

  	} while(c1 == c2);

  	return c1 - c2;
}

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

s8int *strcat(s8int *dest, const s8int *src) {
	strcpy(dest + strlen(dest), src);
  	return dest;
}

// return the length of string
s32int strlen(const s8int *ptr) {
    s32int i = 0;
    while(*ptr != 0) {
        i++;
        ptr++;
    }

    return i;
}

void int_to_ascii(s32int n, s8int str[]) {
    s32int i, sign;
    if ((sign = n) < 0) n = -n;
    i = 0;
    do {
        str[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);

    if (sign < 0) str[i++] = '-';
    str[i] = '\0';

    reverse(str);
}

void reverse(s8int s[]) {
    s32int c, i, j;
    for (i = 0, j = strlen(s)-1; i < j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}