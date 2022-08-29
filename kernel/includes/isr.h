#ifndef ISR_H
#define ISR_H

#include "lib.h"
#include "io.h"
#include "PIC.h"


#define IRQ0 32
#define IRQ1 33
#define IRQ2 34
#define IRQ3 35
#define IRQ4 36
#define IRQ5 37
#define IRQ6 38
#define IRQ7 39
#define IRQ8 40
#define IRQ9 41
#define IRQ10 42
#define IRQ11 43
#define IRQ12 44
#define IRQ13 45
#define IRQ14 46
#define IRQ15 47

//useless_esp is basically a useless value, see the links below 
// https://www.pagetable.com/?p=8, https://www.felixcloutier.com/x86/popa:popad.html, https://c9x.me/x86/html/file_module_x86_id_270.html
typedef struct registers
{
    uint32_t ds;                  // Data segment selector pushed from IR stub
    uint32_t edi, esi, ebp,  useless_esp, ebx, edx, ecx, eax; // Pushed by pusha in the IR stub
    uint32_t int_no, err_code;    // Interrupt number and error code (if applicable)
    uint32_t eip, cs, eflags, esp, ss; // Pushed by the processor automatically when interrupt happens
} registers_t;

// Enables registration of callbacks for interrupts or IRQs.
// For IRQs, to ease confusion, use the #defines above as the
// first parameter.
typedef void (*isr_t)(registers_t*);
void register_interrupt_handler(uint8_t n, isr_t handler);

#endif