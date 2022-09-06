#include "string.h"

// Compare two strings. Should return -1 if 
// str1 < str2, 0 if they are equal or 1 otherwise.
int strcmp(char *str1, char *str2) {
    const uint8_t *s1 = (const uint8_t *) str1;
    const uint8_t *s2 = (const uint8_t *) str2;
    uint8_t c1, c2;

    do {
        c1 = (uint8_t) *s1++;
        c2 = (uint8_t) *s2++;

        if(c1 == 0) {
            return c1 - c2;
        }

    } while(c1 == c2);

    return c1 - c2;
}

// Copy the NULL-terminated string src into dest, and
// return dest.
char *strcpy(char *dest, const char *src) {
    char *tmp = dest;
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

char *strcat(char *dest, const char *src) {
    strcpy(dest + strlen(dest), src);
    return dest;
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


//turns an integer into a string
void int_to_ascii(int n, char str[]) {
    int i, sign;

    //check if n is negative. if so, make it positive.
    if ((sign = n) < 0) n = -n;

    i = 0;
    do {

    //modding n with 10 returns the digit in the 1's place
    //add with "0" to correctly offset into ascii table
        str[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);

    //check is sign was negative. if so, add a negative sign.
    if (sign < 0) str[i++] = '-';

    //add null terminator
    str[i] = '\0';

    //reverse string
    reverse(str);
}

void hex_to_ascii(int n, char str[]) {
    int tmp;
    char noZeroes = 1;

    int j = 0;
    int i;
    for (i = 28; i > 0; i -= 4)
    {

        tmp = (n >> i) & 0xF;
        if (tmp == 0 && noZeroes != 0)
        {
            continue;
        }
    
        if (tmp >= 0xA)
        {
            noZeroes = 0;
            str[j] = tmp-0xA+'A';
        }
        else
        {
            noZeroes = 0;
            str[j] = tmp+'0';
        }
        j++;
    }

    tmp = n & 0xF;
    if (tmp >= 0xA)
    {
        str[j] = tmp-0xA+'A';
    }
    else
    {
        str[j] = tmp+'0';
    }
}

void backspace(char s[]) {
    int len = strlen(s);
    s[len - 1] = 0; 
}



void reverse(char s[]) {
    int c, i, j;
    for (i = 0, j = strlen(s)-1; i < j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}