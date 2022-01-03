; not limited to 512 bytes

%define 	CODE_DESC 0x08
%define 	DATA_DESC 0x10
%define 	IMAGE_RMODE_BASE 0x3000
%define 	IMAGE_PMODE_BASE 0x100000

 
org 0x500									; we are loaded at linear address 0x500
 
bits 	16									; we are still in real mode
 
; 0x500 is not used by anything else so we arent over writing important data
	
jmp 	main								; jump to main


;=======================================
;LIB (common functions)			
;=======================================
 
;---------------------------------------
;Prints a string 					
;DS=>SI: 0 terminated string
;---------------------------------------

Print:
	pusha
PLoop:	
	lodsb								; load next byte from string from SI to AL
	or 		al, al 						; does AL = 0?
	jz		PrintDone					; Yep, null terminator found, bail out
	mov 	ah, 0eh						; No, print Character
	int 	10h 						
	jmp 	PLoop 						; repeat until null terminator found
PrintDone:
	popa
	ret									; we are done, so return
 

;=======================================
;Set up GDT	(Global Descriptor Table)				
;=======================================

; this GDT is refered to as a flat memory model. 
; we basically just set up the gdt because pmode requirse the gdt to be set up.
; later we switch to paging.

GDTData:
	dq		0

;start of GDT Code segment
	
	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		10011010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

;start of GDT Data Segment

	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		10010010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

;start of GDT User Code segment
	
	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		11111010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

;start of GDT User Data Segment

	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		11110010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

GDTR:
	dw GDTR - GDTData - 1 					; limit (Size of GDT)
	dd GDTData 								; base of GDT

;---------------------------------------
;Installing GDT using lgdt			
;---------------------------------------
	
InstallGDT:
	cli 									; clear ints to ensure no tripple fault
	pusha 									; save registers
	lgdt 	[GDTR] 							; load GDT into GDTR
	sti 									; enable ints
	popa 									; restore registers
	ret 									; return
	

;=======================================
;Enable A20 Gate
;0x60 R/W: Data port
;0x64 R: Status  register
;0x64 W: Command register
;0x92: system control port A
;=======================================

CheckA20:
    pushf 									; save flags
    push 	ds 								; push data segment registers 
    push 	es
    push 	di
    push 	si
 
    cli
 
    xor 	ax, ax 
    mov 	es, ax 							; set es to 0
 
    not 	ax
    mov 	ds, ax 							; set ds to 0xFFFF
 
    mov 	di, 0x0500
    mov 	si, 0x0510

    mov 	al, byte [es:di] 					; save whats in 0000:0500
    push 	ax
 
    mov 	al, byte [ds:si] 					; save whats in FFFF:0510
    push 	ax
 
    mov 	BYTE [es:di], 0x00 				; if A20 is set, then es:di will contain 0
    mov 	BYTE [ds:si], 0xFF 				; if A20 isn't set, then es:di will contain 0xFF 
 	cmp 	BYTE [es:di], 0xFF 				; because the address 0x100500 (ds:si) will just be
 											; 0x500 on the address bus, lines 21 and up are disabled


    pop 	ax 									; restore what was in locations es:di, ds:si
    mov 	byte [ds:si], al
 
    pop 	ax
    mov 	byte [es:di], al
 
    mov 	ax, 0
    je 		CheckA20Exit
 
    mov 	ax, 1
 
CheckA20Exit:
    pop 	si
    pop 	di
    pop 	es
    pop 	ds
    popf
    sti
 
    ret


;---------------------------------------
;Enable through Bios	
;---------------------------------------

EnableA20_Bios:
	pusha
	mov 	ax, 0x2401 						; command bios uses to enable A20
	int 	0x15
	popa
	ret

;---------------------------------------
;Enable through system control port A
;---------------------------------------

EnableA20_SysControlA:
	push 	ax
	mov 	al, 2
	out 	0x92, al 						; second bit is enable A20
	pop 	ax
	ret

;---------------------------------------
;Enable through keyboard command
;---------------------------------------


EnableA20_KBCommand:
	cli
	push 	ax
	call 	Wait_Input 						; wait until input was delt with
	mov 	al, 0xdd 						; 0xdd is command to enable A20
	out 	0x64, al
	call 	Wait_Input
	pop 	ax
	sti
	ret

;---------------------------------------
;Enable through keyboard output port
;---------------------------------------

EnableA20_KBOutputPort:

	cli
	pusha

	call 	Wait_Input
	mov 	al, 0xAD
	out 	0x64, al 						; command to disable keyboard

	call 	Wait_Input
	mov 	al, 0xD0
	out  	0x64, al 						; command to read output port
	call 	Wait_Output						; wait until output port has data

	in 		al, 0x60
	push 	eax 							; store output port data
	call 	Wait_Input

	mov 	al, 0xD1
	out 	0x64, al 						; command to tell controller to write to output port
	call 	Wait_Input

	pop  	eax
	or 		al, 2 							; set bit 2 of output port to 1 to enable A20
	out 	0x60, al 						; write data back to output port

	call 	Wait_Input
	mov 	al, 0xAE
	out 	0x64, al 						; enable keyboard controller
	call  	Wait_Input

	popa
	sti
	ret 


; wait for input buffer to be clear
; bit 1 must be clear before attempting to write data to IO port 0x60 or IO port 0x64

Wait_Input:
	in 		al, 0x64
	test 	al, 2 							; will set ZF to 1 if AND result is 0
	jnz 	Wait_Input 						; jumps if ZF is 0, returns if ZF is 1
	ret

; wait for output buffer to have data
; bit 0 must be set before attempting to read data from IO port 0x60

Wait_Output:
	in 		al, 0x64
	test 	al, 1 							; will set ZF to 1 if AND result is 0
	jz 		Wait_Output 					; jumps if ZF is 1, returns if ZF is 0
	ret


HandleA20:

	call 	CheckA20
	and 	ax, 1
	jnz 	A20Enabled

	call 	EnableA20_Bios
	call 	CheckA20
	and 	ax, 1
	jnz 	A20Enabled

	call 	EnableA20_SysControlA
	call 	CheckA20
	and 	ax, 1
	jnz 	A20Enabled

	call 	EnableA20_KBCommand
	call 	CheckA20
	and 	ax, 1
	jnz 	A20Enabled

	call 	EnableA20_KBOutputPort
	call 	CheckA20
	and 	ax, 1
	jnz 	A20Enabled

A20Failed:
	mov 	si, A20FailedMsg
	call 	Print
	mov		ah, 0
	int     0x16                    ; await keypress
	int     0x19 
	cli								; if we get to this point, something really bad happened
	hlt

A20Enabled:
	ret


;=======================================
;Loads Kernel from Disc (same as stage 1)
;=======================================

LoadKernel:

LoadFatRoot:

	; get size of FAT and store in cx

	xor 	ax, ax
	mov 	al, BYTE [bpbNumberOfFATs]
	mul 	WORD [bpbSectorsPerFAT]
	mov 	cx, ax

	; get starting location of Root Entry in RAM

	mul 	WORD [bpbBytesPerSector] 		; mul FAT sector size to get bytes
	add 	ax, FATROOTLOC 					; add with where we are loaded into
	mov 	WORD [rootregion], ax 			; store for later

	; calculate size of root directory and add with FAT and reserved sectors 
	; store in cx

	xor 	dx, dx 							; prepare dx for div
	mov 	ax, 0x0020						; use the value 32 to multiplay with the amount of root entries
	mul 	WORD [bpbRootEntries]			; because each root entry is 32 bytes long
	div 	WORD [bpbBytesPerSector]		; devide by bytes per sector so we get how many sectors the root directory is
	add 	cx, ax                      	; add size of FAT with size of root
	mov 	ax, WORD [bpbReservedSectors] 	; set ax to starting location of FAT
	mov 	WORD [dataregion], cx 			; store to get the start of data region
	add 	WORD [dataregion], ax 			; account for reserved sectors

	mov 	bx, FATROOTLOC
	call 	LoadSectors	

;=======================================
;finds a file's location from the root, and returns starting cluster
;=======================================

FindFileLocation:
	mov 	cx, WORD [bpbRootEntries] 	; counter
	mov 	di, WORD [rootregion] 		; location where root resides in RAM (after FAT)

RootLoop:
	push 	cx
	mov 	cx, 0x000B 					; Character name is 11 bytes 
	mov 	si, ImageName 				; name to find
	push 	di 							; push di because it gets incremented from rep cmpsb 
	rep cmpsb 							; compare DS:SI and ES:DI by subtraction. rep repeats cmpsb cx times (11)
	pop 	di
	pop 	cx
	je 		ReturnCluster				; if equal, jump to load fat
	add 	di, 0x0020 					; add 32 bytes for next entry
	loop 	RootLoop 					; decs cx (512 entrys) reg and checks for 0, if 0, execute next line
	jmp 	FindFailed
ReturnCluster:
	mov 	dx, WORD [di + 0x001A] 		; starting cluster
	mov 	WORD [cluster], dx
	push 	0x3000 						; where to write the file
	jmp 	LoadFile

FindFailed:
	mov     si, FindFailure
	call    Print
	mov     ah, 0x00
	int     0x16                         ; await keypress
	int     0x19
	cli
	hlt

;=======================================
;Load the file
;=======================================

LoadFile:
	mov     ax, WORD [cluster] 			; cluster to read
	pop 	bx                  		; buffer to read into
	call    ClusterLBA                  ; convert cluster to LBA
	xor     cx, cx
	mov     cl, BYTE [bpbSectorsPerCluster]     ; sectors to read
	call    LoadSectors
	push    bx

	mov 	ax, WORD [cluster] 			; copy currrent cluster because we need different valuse from it
	mov 	cx, ax
	mov 	dx, ax
	shr 	dx, 0x0001 	 				; math to get correct FAT index						 
	add 	cx, dx								
	mov 	bx, FATROOTLOC

	add 	bx, cx 						; index into FAT

	mov 	dx, WORD [bx] 				; read two bytes from FAT
	add 	WORD [KernelSize], 1
	test 	ax, 0x0001					; AND to test if Odd	
	jnz 	OddCluster

EvenCluster:

	and 	dx, 0000111111111111b 		; take low 12 bits because of little endian
	jmp 	CheckEndCluster

OddCluster:

	shr 	dx, 0x0004 					; take high 12 bits because of little endian

CheckEndCluster:

	mov 	WORD [cluster], dx
	cmp 	dx, 0x0FF0
	jb  	LoadFile

DONE:
 	pop 	bx
 	ret


;=======================================
;Load Sectors function
;AX = starting cluster
;CX = Number of clusters to read
;ES:BX = offset to load to
;=======================================

LoadSectors:
	ErrorDecloration:
		mov 	di, 0x0005					; 5 tries to work
	LoadSectorLoop:
		push 	ax 							; push values because LBACHS changes them
		push 	bx
		push 	cx
		call 	LBACHS 						; convert starting cluster to CHS  
		mov 	ah, 0x02 					; set Bios to read sectors
		mov 	al, 0x01 					; amount of sectors we want to read (1)
		mov 	ch, BYTE [absoluteCylinder]	; which Cylinder to read from
		mov 	cl, BYTE [absoluteSector]	; which Sector to read from
		mov 	dh, BYTE [absoluteHead]		; which Head to use
		mov 	dl, BYTE [bsDriveNumber] 	; specified drive to read from
		int 	0x13 						; execute bios interupt routine
		jnc 	Success
		xor 	ax, ax 						; set ah to 0 to Reset Disk System
		int 	0x13 						; Execute bios int
		dec 	di 							; decrement error counter
		pop 	cx 							; pop original params for LBACHS
		pop 	bx
		pop 	ax
		jnz     LoadSectorLoop 				; if the error counter isnt 0, try loading again
		int 	0x18 						; if error counter is 0, then display error
	Success:
		mov 	si, msgProgress
		call 	Print
		pop 	cx 							; pop to change values for next LoadSectorLoop call
		pop 	bx
		pop 	ax
		add 	bx, WORD [bpbBytesPerSector] 	; load next sector
		inc 	ax 							; change starting cluster
		loop 	ErrorDecloration 			; loop until num of clusters to read (cx) is 0
		ret


;=======================================
;Cluster to LBA
;cluster being the cluster in the data
;region and in the FAT
;
;LBA = (cluster - 2) * sectors per cluster
;AX = cluster
;=======================================

; first two entries in FAT are reserved, data region starts counting from 2 

ClusterLBA:
	sub 	ax, 0x0002
	xor 	cx, cx
	mov 	cl, BYTE [bpbSectorsPerCluster]
	mul 	cx
	add 	ax, WORD [dataregion] 			; base data sector
	ret

;=======================================
;LBA to CHS conversion
;AX = LBA
;Cylinder = LBA / (SPT * HPC)
;Head = (LBA / SPT ) mod HPC
;Sector = LBA mod SPT + 1
;=======================================

; the dividend has to be twice the size (32 bit) of the divisor when using div
; dx contains the upper half of our dividend
; ax contains the lower half of our dividend
; ax contains quotient and dl contains remainder

LBACHS:
	xor 	dx, dx							; prepare dx:ax for operation
	div 	WORD [bpbSectorsPerTrack] 		
	inc 	dl 								; adjust for sector 0
	mov 	BYTE [absoluteSector], dl
	xor 	dx, dx 							; prepare dx:ax for operation
	div 	WORD [bpbHeadsPerCylinder] 		
	mov     BYTE [absoluteHead], dl 		
	mov     BYTE [absoluteCylinder], al
	ret 	



;=======================================
;Stage 2 entry point			
;=======================================
 

main:

	cli 									; clear interrupts (dont re-enable)
	xor 	ax, ax							; null data segments
	mov		ds, ax
	mov		es, ax
	mov 	ax, 0x9000 						; stack starts at 9000 - ffff
	mov 	ss, ax
	mov 	sp, 0xFFFF
	sti 									; enable interupts

	mov 	si, LoadMsg
	call 	Print

	call 	InstallGDT 						; instal GDT into GDTR
	call 	HandleA20 						; enable A20 Gate
	call 	LoadKernel  					; loads kernel from disc into mem location 0x3000

	cli 									; disbale interupts (do not enable because we cant use interrupts when in pmode)
	mov 	eax, cr0						; set cr0 first bit to 1 so we can "go into pmode"
	or 		eax, 1
	mov 	cr0, eax 



;This reloads the CS register and flushes the
;real-mode instructions from the prefetch queue. CS is the segment
;register used for instruction fetches, so this is where the switch
;from 16-bit instructions (real-mode) to 32-bit instructions
;(protected-mode) takes place. CS holds an index into the GDT.
;the segment registers now become descriptor:offsets.

	jmp 	0x08:Stage3						; 0x08 because thats the code descriptor	



;=======================================
;Stage 3 
;=======================================

bits 32

Stage3:

	mov		ax, DATA_DESC					; set data segments to data selector (0x10)
	mov		ds, ax
	mov		es, ax
	mov 	ss, ax
	mov 	fs, ax
	mov 	gs, ax
	mov		esp, 90000h						; stack begins from 90000h

CopyKernelImage:

	movzx 	eax, WORD [KernelSize]
	movzx 	ebx, WORD [bpbBytesPerSector] 
	mul 	ebx
	mov 	ebx, 4
	div 	ebx 							; devide by 4 because we load 4 bytes
	cld
   	mov     esi, IMAGE_RMODE_BASE
   	mov		edi, IMAGE_PMODE_BASE
   	mov 	ecx, eax 						
   	rep 	movsd 							; loads a doubleword from ds:si to es:di, repeated cx times (128)

JumpToKernel:

    jmp 	CODE_DESC:IMAGE_PMODE_BASE


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

LoadMsg db	"Preparing to load operating system...",13,10,0
TestMsg db "testing", 0
A20FailedMsg db "The A20 gate failed to open", 0
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


FATROOTLOC: 			DB 0x00




