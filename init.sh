cd build
sh Assemble_Asm.sh
sh Execute_Kernel_Compiler.sh
sh Bundler.sh
cd ../
bochs -f BochsConfig.txt







# cd BootLoader
# nasm -f bin Stage1.asm -o Stage1.bin
# nasm -f bin Stage2.asm -o STAGE2.SYS
# cd ../
# cd kernel
# nasm -f bin kernel.asm -o MIDOSK.SYS
# cd ../
# sh MkFlop.sh
# var=$(hdiutil attach disks/a.dmg | awk -F'/Volumes/' '{print $2}')
# cd Bootloader
# cp STAGE2.SYS "/Volumes/$var"
# cd ../ 
# cd kernel
# cp MIDOSK.SYS "/Volumes/$var"
# cd ../ 
# hdiutil eject "/Volumes/$var"
# dd if=BootLoader/Stage1.bin of=disks/a.dmg conv=notrunc;
# bochs

