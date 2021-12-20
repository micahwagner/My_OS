#include "lib/lib.h"

void kernel_main()
{
    // Initialise the screen (by clearing it)
    clear_screen();

    // make some variables to be used when testing functions
    s8int string[] = "string";
    s8int string1[7];
    u8int *video_memory = (u8int *)0xB8000;
    u8int *dest = (u8int *)0xB8500;
    u8int *dest1 = (u8int *)0xB8900;
    u32int num = 160;
    u8int val = 37;


    // Write out a sample string
    print_str("                                   - MIDOS -");
    print_str("\n                                 4GB AVAILABLE");
    print_str("\n================================================================================");
    print_str("\nCMD:");

    //preform memory copy operation
    copy_mem(video_memory, dest1, num);

    //preform memory set operation
    mem_set(dest, val, num);

    //preform string copy operation
    print_str(string);
    strcpy(string1, string);
    print_str(string1);

    return;
}