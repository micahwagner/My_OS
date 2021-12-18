sh MkFlop.sh
var=$(hdiutil attach .././disks/a.dmg | awk -F'/Volumes/' '{print $2}')
cd bin
cp STAGE2.SYS "/Volumes/$var"
cp MIDOS.SYS "/Volumes/$var"
cd ../
hdiutil eject "/Volumes/$var"
dd if=bin/Stage1.bin of=.././disks/a.dmg conv=notrunc;