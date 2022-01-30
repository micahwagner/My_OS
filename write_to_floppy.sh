
#have it say "U sure?"
FloppyName=""
DiskDevLoc=""
SafteyCheck=""
RED='\033[0;31m'
NC='\033[0m' # No Color
echo "${RED}WANRING: use this with extreme causion, as writing to the wrong device will result in mass data loss${NC}"
echo "${NC}Name of disk to write to: ${NC}"
read FloppyName
echo "${NC}location of disk in /dev (answer must include /dev):${NC}"
read DiskDevLoc
echo "${RED}are you sure you want to write to this disk? y/n${NC}"
read SafteyCheck
if [ $SafteyCheck == "y" ] 
then 
	sudo diskutil unmount $FloppyName
	sudo dd if=disks/a.dmg of=$DiskDevLoc conv=sparse;
else
	exit
fi


#sudo diskutil unmount $(FloppyName)
#sudo dd if=bin/Stage1.bin of="disklocation" conv=notrunc;