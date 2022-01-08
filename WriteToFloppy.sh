
#have it say "U sure?"
FloppyName=""
SafteyCheck=""
RED='\033[0;31m'
NC='\033[0m' # No Color
echo "${RED}WANRING: use this with extreme causion, as writing to the wrong device will result in mass data loss${NC}"
echo "${RED}make sure no other device's are plugged into computer in the /dev folder${NC}"
echo "are you sure you want to write to the 1.44 mb Floppy you inserted? y/n"
read SafteyCheck
if [ $SafteyCheck == "y" ] 
then 
	echo "balls"
else
	exit
fi
#sudo diskutil unmount "diskname"
#sudo dd if=bin/Stage1.bin of="disklocation" conv=notrunc;
#