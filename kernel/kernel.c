#include "lib/lib.h"
#include "interrupts/idt.h"
#include "driver/keyboard.h"
#include "memory/paging.h"

void kernel_main()
{
    // Initialise the screen (by clearing it)
    set_fore_back_colour(14,0);
    clear_screen();


    // Write out a sample string
    print_str("                                   - MIDOS -");
    print_str("\n                             Type HELP for more info");
    print_str("\n================================================================================");
    print_str("\nCMD:");
	// initialize interrupts
	init_interrupts();


	// initialize paging
	initialise_paging();


	// init interrupt requests and drivers
	asm volatile ("sti");
	init_timer(10);
	init_keyboard();




	// do a page fault
	u32int *ptr = (u32int*)0xA0000000;
    u32int do_page_fault = *ptr;

    return;
}

