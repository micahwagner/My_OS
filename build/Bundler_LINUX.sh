sudo mkdir /media/floppy1/
dd bs=512 count=2880 if=/dev/zero of=.././disks/imagefile.img 
mkfs.msdos -r 512 .././disks/imagefile.img
sudo mount -o loop .././disks/imagefile.img /media/floppy1/
sudo cp bin/MIDOS.SYS /media/floppy1
sudo cp bin/STAGE2.SYS /media/floppy1
sudo umount /media/floppy1
dd if=bin/Stage1.bin of=.././disks/imagefile.img conv=notrunc; 
sudo rm -r /media/floppy1