#ifndef PRINT_H
#define PRINT_H

#include "type.h"
#include ".././io/io.h"
#include "string.h"
// Write a single character out to the screen.
void print_char(s8int c);

// Clear the screen to all black.
void clear_screen();

// Output a null-terminated ASCII string to the monitor.
void print_str(s8int *c);

// print an integer out to the screen
void print_int(s32int n);

// sets the foreground and background colors
void set_fore_back_colour(u8int x, u8int y);

#endif // PRINT