#include "lib/lib.h"

void kernel_main()
{
    // Initialise the screen (by clearing it)
    clear_screen();
    // Write out a sample string
    u8int *video_memory = (u8int *)0xB8000;
    u8int *dest = (u8int *)0xB8500;
    u32int num = 160;
    u8int val = 37;
    print_str("                                   - MIDOS -");
    print_str("\n                                 4GB AVAILABLE");
    print_str("\n================================================================================");
    print_str("\nCMD:");
    mem_set(dest, val, num);
    return;
}