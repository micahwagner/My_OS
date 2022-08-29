#ifndef TIMER_H
#define TIMER_H

#include "lib.h"
#include "isr.h"

#define PIT_BIT_COUNT  0x0
#define PIT_MODE_3     0x06
#define PIT_RL_LSB_MSB 0x30
#define PIT_COUNTER0   0x0
#define PIT_ICW	       0x43

void init_timer(u32int frequency);
u32int timer_value();

#endif
