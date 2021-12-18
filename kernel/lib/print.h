#ifndef PRINT_H
#define PRINT_H

#include "type.h"
#include ".././io/io.h"
// Write a single character out to the screen.
void print_char(char c);

// Clear the screen to all black.
void clear_screen();

// Output a null-terminated ASCII string to the monitor.
void print_str(char *c);

#endif // PRINT