MODULES = Object/kernel_entry.asm.o Object/kernel.o \
		Object/io.asm.o Object/print.o \
		Object/mem.o Object/string.o \
		Object/interrupt.asm.o Object/isr.o Object/idt.o \
		Object/keyboard.o Object/PIC.o Object/PIT.o\
		Object/paging.o Object/memory.o

INCLUDES = .././kernel/includes

FLAGS := -O0 -Wall -g -ffreestanding \
	-nostartfiles -nodefaultlibs \
	-lgcc -fno-exceptions \
	-falign-jumps -falign-functions \
	-falign-labels -falign-loops \
	-fomit-frame-pointer -fno-builtin 

bin/MIDOS.SYS: $(MODULES)
	i686-elf-ld -g -relocatable $(MODULES) -o Object/kernelfull.o
	i686-elf-gcc $(FLAGS) -T .././kernel/linker.ld -o bin/MIDOS.SYS -ffreestanding -O0 -nostdlib Object/kernelfull.o

Object/kernel.o: .././kernel/kernel.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c .././kernel/kernel.c -o Object/kernel.o

Object/print.o: .././kernel/lib/print.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/mem.o: .././kernel/lib/mem.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/string.o: .././kernel/lib/string.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/idt.o: .././kernel/interrupts/idt.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/PIC.o: .././kernel/driver/PIC.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/isr.o: .././kernel/interrupts/isr.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/PIT.o: .././kernel/driver/PIT.c 
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/keyboard.o: .././kernel/driver/keyboard.c 
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/paging.o: .././kernel/memory/paging.c 
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

Object/memory.o: .././kernel/memory/memory.c
	i686-elf-gcc -I $(INCLUDES) $(FLAGS) -c $^ -o $@

