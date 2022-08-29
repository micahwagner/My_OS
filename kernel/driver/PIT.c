#include "PIT.h"

u32int tick = 0;


//for more info, see http://www.brokenthorn.com/Resources/OSDevPit.html
void timer_callback(registers_t *regs)
{
    tick++;
    //print_int(tick);
}

u32int timer_value() {
    return tick;
}

void init_timer(u32int frequency)
{
    // Firstly, register our timer callback.
    register_interrupt_handler(IRQ0, &timer_callback);

    // The value we send to the PIT is the value to divide it's input clock
    // (1193180 Hz) by, to get our required frequency. Important to note is
    // that the divisor must be small enough to fit into 16-bits.
    u32int divisor = 1193180 / frequency;

    // Send the command byte. sets binary counting, mode 3 (square wave), Read or Load LSB first then MSB, Channel 0
    outb(PIT_ICW, PIT_BIT_COUNT | PIT_MODE_3 | PIT_RL_LSB_MSB | PIT_COUNTER0);

    // Send LSB of divisor first, then MSB of divisor
    u8int l = (u8int)(divisor & 0xFF);
    u8int h = (u8int)( (divisor>>8) & 0xFF );

    // Send the frequency divisor.
    outb(0x40, l);
    outb(0x40, h);
}


