
cd BootLoader
nasm -f bin Stage1.asm -o Stage1.bin
nasm -f bin Stage2.asm -o STAGE2.SYS
cd ../  
sh MkFlop.sh
var=$(hdiutil attach disks/a.dmg | awk -F'/Volumes/' '{print $2}')
echo $var
cd Bootloader
echo $var
cp STAGE2.SYS "/Volumes/$var"
cd ../ 
dd if=BootLoader/Stage1.bin of=disks/a.dmg conv=notrunc;
bochs
