;=======================================
;Data			
;=======================================


absoluteSector	db 0x00
absoluteHead	db 0x00
absoluteCylinder	db 0x00

rootregion 	dw 0x0000
dataregion  dw 0x0000
cluster     dw 0x0000
KernelSize 	dw 0x0000

LoadMsg db	0x0D, 0x0A, "Preparing to load operating system...",13,10,0
TestMsg db "testing", 0
A20FailedMsg db "The A20 gate failed to open", 0
A20IsEnabled db "A20 enabled",13,10,0
GDTInstalled db "GDT installed",13,10,0
msgProgress db ".", 0
ImageName db "MIDOS   SYS",0
FindFailure db "failed to find Kernel",0


bpbOEM					db "MiDOS   " 		; cant be more than 8 bytes because  OEM starts on 11th byte

bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	    DB 2
bpbRootEntries: 	    DW 512
bpbTotalSectors: 	    DW 2880
bpbMedia: 	            DB 0xF0
bpbSectorsPerFAT: 	    DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors: 	    DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	            DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "DOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "


