# Build Process 
This folder contains all the scripts needed to bundle the bootloader and kernel code into a disk image. Below is a list that explains what each script is doing.
## Scripts
- [Assemble_Bootloader.sh] - assembles the bootloader code using the NASM assembler
- [Assemble_Asm.sh] - assembles other code related to the kernel using the NASM assembler
- [Execute_Kernel_Compiler.sh] - starts a docker image that mounts this project into the root of the docker container. The docker container has a i686-elf cross compiler to compile the kernel code. When done compiling, the container is deleted. The docker image I used for this can be found here https://github.com/kevincharm/i686-elf-gcc-toolchain 
- [Compile_Kernel.mk] - When the docker image is up, it uses this make file the compile the kernel. This make file concists of the commands to give to the i686-elf cross compiler. 
- [MKFlop.sh] - This script creates a floppy that is FAT 12 formatted. Keep in mind that the disk has 512 root entrys instead of 224. 
- [Bundler.sh] - This script takes all the kernel and bootloader bins and puts it onto the disk.