MODULES = Object/io.asm.o Object/kernel.o Object/print.o

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
	i686-elf-gcc -I ..././kernel $(FLAGS) -c .././kernel/kernel.c -o Object/kernel.o

Object/print.o: .././kernel/lib/print.c
	i686-elf-gcc -I ..././kernel .././kernel/lib $(FLAGS) -c $^ -o $@




