#ifndef PRINT_H
#define PRINT_H

#include "type.h"
#include "io.h"
#include "string.h"
// Write a single character out to the screen.
void print_char(char c);

// Clear the screen to all black.
void clear_screen();

// Output a null-terminated ASCII string to the monitor.
void print_str(char *c);

// print an integer out to the screen
void print_int(int n);

// print hex value to screen
void print_hex(int n);

// sets the foreground and background colors
void set_fore_back_colour(uint8_t x, uint8_t y);

// set the cursor back 
void print_backspace();




#endif // PRINT