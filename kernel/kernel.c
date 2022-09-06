#include "lib.h"
#include "idt.h"
#include "keyboard.h"
#include "paging.h"


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
	init_timer(10);
	init_keyboard();
	asm volatile ("sti");






	//do a page fault
	// uint32_t *ptr = (uint32_t*)0xA00FFC0B;
 // 	uint32_t do_page_fault = *ptr;

    return;
}
