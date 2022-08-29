#ifndef TIMER_H
#define TIMER_H

#include "lib.h"
#include "isr.h"

#define PIT_BIT_COUNT     0x0
#define PIT_MODE_3        0x06
#define PIT_RL_LSB_MSB    0x30
#define PIT_COUNTER0      0x0
#define PIT_ICW	          0x43
#define PIT_COUNTER0_DATA 0x40

void init_timer(uint32_t frequency);
uint32_t timer_value();

#endif
