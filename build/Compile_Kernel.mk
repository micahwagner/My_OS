MODULES = Object/kernel_entry.asm.o Object/kernel.o \
		Object/io.asm.o Object/print.o \
		Object/mem.o Object/string.o \
		Object/interrupt.asm.o Object/isr.o Object/idt.o

INCLUDES = .././kernel

FLAGS := -O0 -Wall -g -ffreestanding \
	-nostartfiles -nodefaultlibs \
	-nostdlib -lgcc -fno-exceptions \
	-falign-jumps -falign-functions \
	-falign-labels -falign-loops \
	-fomit-frame-pointer -fno-builtin 

bin/MIDOS.SYS: $(MODULES)
	i686-elf-ld -g -relocatable $(MODULES) -o Object/kernelfull.o
	i686-elf-gcc $(FLAGS) -T .././kernel/linker.ld -o bin/MIDOS.SYS -ffreestanding -O0 -nostdlib Object/kernelfull.o

Object/kernel.o: .././kernel/kernel.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c .././kernel/kernel.c -o Object/kernel.o

Object/print.o: .././kernel/lib/print.c
	i686-elf-gcc -I $(INCLUDES) .././kernel/lib $(FLAGS) -c $^ -o $@

Object/mem.o: .././kernel/lib/mem.c
	i686-elf-gcc -I $(INCLUDES) .././kernel/lib $(FLAGS) -c $^ -o $@

Object/string.o: .././kernel/lib/string.c
	i686-elf-gcc -I $(INCLUDES) .././kernel/lib $(FLAGS) -c $^ -o $@

Object/idt.o: .././kernel/interrupts/idt.c
	i686-elf-gcc -I $(INCLUDES) .././kernel/interrupts $(FLAGS) -c $^ -o $@

Object/isr.o: .././kernel/interrupts/isr.c
	i686-elf-gcc -I $(INCLUDES) .././kernel/interrupts $(FLAGS) -c $^ -o $@



