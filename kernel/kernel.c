#include "lib/lib.h"
#include "interrupts/idt.h"
#include "driver/keyboard.h"

void kernel_main()
{
    // Initialise the screen (by clearing it)
    set_fore_back_colour(14,0);
    clear_screen();


    // Write out a sample string
    print_str("                                   - MIDOS -");
    print_str("\n                                 4GB AVAILABLE");
    print_str("\n================================================================================");
    print_str("\nCMD:");
	// initialize interrupts
	asm volatile("sti");
	init_interrupts();
	init_timer(50);
	init_keyboard();

    //asm volatile("sti");
    //init_timer(50);
    return;
}