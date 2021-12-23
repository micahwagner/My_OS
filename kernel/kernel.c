#include "lib/lib.h"
#include "interrupts/idt.h"

void kernel_main()
{
    // Initialise the screen (by clearing it)
    clear_screen();

    // make some variables to be used when testing functions
    s8int string[] = "string";
    s8int string1[7];
    s8int string2[25];
    s8int string3[25];
    s8int string4[] = "stupid ";
    u8int *video_memory = (u8int *)0xB8000;
    u8int *dest = (u8int *)0xB8500;
    u8int *dest1 = (u8int *)0xB8900;
    u32int num = 160;
    s32int num1 = -160;
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
    print_str(&string);
    strcpy(&string1, &string);
    print_str(&string1);

    //preform string compare operation
    print_str("\n");
    s32int a = strcmp(&string, &string1);
    int_to_ascii(a, string2);
    print_str(&string2);

    //preform int to ascii
    print_str("\n");
    print_int(num1);

    //preform string concatenation
    print_str("\n");
	strcat(&string4, &string1);
	print_str(&string4);

	// initialize interrupts
	init_interrupts();
	asm volatile("int $0x4");
    asm volatile("int $0x3");

    asm volatile("sti");
    init_timer(50);
    return;
}