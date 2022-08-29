#include "PIT.h"

uint32_t tick = 0;


//for more info, see http://www.brokenthorn.com/Resources/OSDevPit.html
void timer_callback(registers_t *regs)
{
    tick++;
    //print_int(tick);
}

uint32_t timer_value() {
    return tick;
}

void init_timer(uint32_t frequency)
{
    // Firstly, register our timer callback.
    register_interrupt_handler(IRQ0, &timer_callback);

    // The value we send to the PIT is the value to divide it's input clock
    // (1193180 Hz) by, to get our required frequency. Important to note is
    // that the divisor must be small enough to fit into 16-bits.
    uint32_t divisor = 1193180 / frequency;

    // Send the command byte. sets binary counting, mode 3 (square wave), Read or Load LSB first then MSB, Channel 0
    outb(PIT_ICW, PIT_BIT_COUNT | PIT_MODE_3 | PIT_RL_LSB_MSB | PIT_COUNTER0);

    // Send LSB of divisor first, then MSB of divisor
    uint8_t l = (uint8_t)(divisor & 0xFF);
    uint8_t h = (uint8_t)( (divisor>>8) & 0xFF );

    // Send the frequency divisor.
    outb(PIT_COUNTER0_DATA, l);
    outb(PIT_COUNTER0_DATA, h);
}


