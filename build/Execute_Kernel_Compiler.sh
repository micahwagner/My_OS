docker run --rm -v /Users/micahwagner/Projects/asm/OS:/OS kevincharm/i686-elf-gcc-toolchain:5.5.0 bash -c 'cd OS/build/ && make -f Compile_Kernel.mk'
#docker run -it --rm -v /Users/micahwagner/Projects/asm/OS:/OS kevincharm/i686-elf-gcc-toolchain:5.5.0 /bin/bash