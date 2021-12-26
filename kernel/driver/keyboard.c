#include "keyboard.h"

#define BACKSPACE 0x0E
#define ENTER 0x1C

static char key_buffer[256];
static void user_input(char *input);

#define SC_MAX 57

const char *sc_name[] = { "ERROR", "Esc", "1", "2", "3", "4", "5", "6", 
    "7", "8", "9", "0", "-", "=", "Backspace", "Tab", "Q", "W", "E", 
        "R", "T", "Y", "U", "I", "O", "P", "[", "]", "Enter", "Lctrl", 
        "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "`", 
        "LShift", "\\", "Z", "X", "C", "V", "B", "N", "M", ",", ".", 
        "/", "RShift", "Keypad *", "LAlt", "Spacebar"};
const char sc_ascii[] = { '?', '?', '1', '2', '3', '4', '5', '6',     
    '7', '8', '9', '0', '-', '=', '?', '?', 'Q', 'W', 'E', 'R', 'T', 'Y', 
        'U', 'I', 'O', 'P', '[', ']', '?', '?', 'A', 'S', 'D', 'F', 'G', 
        'H', 'J', 'K', 'L', ';', '\'', '`', '?', '\\', 'Z', 'X', 'C', 'V', 
        'B', 'N', 'M', ',', '.', '/', '?', '?', '?', ' '};

static void keyboard_callback(registers_t *regs) {
    /* The PIC leaves us the scancode in port 0x60 */
    u8int scancode = inb(0x60);


    if (scancode > SC_MAX) return;
    if (scancode == BACKSPACE) {
        backspace(key_buffer);
        print_backspace();
    } else if (scancode == ENTER) {
        print_str("\n");
        user_input(&key_buffer); 
        key_buffer[0] = '\0';
    } else {
        char letter = sc_ascii[(int)scancode];
        char str[2] = {letter, '\0'};
        strcat(&key_buffer, &str);
        print_str(&str);
    }
}

static void user_input(char *input) {
	if (strcmp(input, "HALT") == 0) {
        print_str("Halting system\n");
        asm volatile("hlt");
    }
	else if (strcmp(input, "HELP") == 0) {
        print_str("LIST OF COMMANDS (case sensitive):\n");
    	set_fore_back_colour(2,0);
        print_str("CLEAR\n");
        print_str("PRINT\n");
        print_str("HALT\n");
        print_str("SYSINFO\n");
        print_str("SETCOLOR\n");
    	set_fore_back_colour(14,0);
        print_str("\nCMD: ");
    } 
    else if (strcmp(input, "CLEAR") == 0) {
    	clear_screen();
    	print_str("CMD:");
    }
    else {
    	print_str("Invalid Command: ");
    	set_fore_back_colour(4,0);
    	print_str(input);
    	set_fore_back_colour(14,0);
    	print_str("\nCMD: ");
    }
}

void init_keyboard() {
	register_interrupt_handler(IRQ1, &keyboard_callback);
}