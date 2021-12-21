nasm -f bin .././BootLoader/Stage1.asm -o .././build/bin/Stage1.bin
nasm -f bin .././BootLoader/Stage2.asm -o .././build/bin/STAGE2.SYS
nasm -f elf -g .././kernel/io/io.asm -o Object/io.asm.o
nasm -f elf -g .././kernel/kernel_entry.asm -o Object/kernel_entry.asm.o
nasm -f elf -g .././kernel/interrupts/interrupt.asm -o Object/interrupt.asm.o
