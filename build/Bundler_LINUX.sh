mkdir MiDOS
hdiutil create -size 1440k -fs "MS-DOS FAT12" -layout NONE -srcfolder MiDOS -format UDRW -ov .././disks/a.dmg
rm -r MiDOS
var=$(hdiutil attach .././disks/a.dmg | awk -F'/Volumes/' '{print $2}')
cd bin
cp STAGE2.SYS "/Volumes/$var"
cp MIDOS.SYS "/Volumes/$var"
cd ../
hdiutil eject "/Volumes/$var"
dd if=bin/Stage1.bin of=.././disks/a.dmg conv=notrunc;