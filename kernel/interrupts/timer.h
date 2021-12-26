#ifndef TIMER_H
#define TIMER_H

#include ".././lib/lib.h"
#include "isr.h"

void init_timer(u32int frequency);
u32int timer_value();

#endif
