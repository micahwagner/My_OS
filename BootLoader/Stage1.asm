
;=======================================
;Bootloader Pt. 1
;=======================================

bits	16									; 16 bit real mode

org		0x0									; changed later in main


Start:		jmp Main

;=======================================
;OEM Parameter block
;=======================================

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

;=======================================
;Prints a string 					
;DS=>SI: 0 terminated string
;=======================================

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
		ret 								; we are done, so return

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

; first two entries in FAT are reserved, data region starts counting from 2 - num of clusters

ClusterLBA:
	sub 	ax, 0x0002
	xor 	cx, cx
	mov 	cl, BYTE [bpbSectorsPerCluster]
	mul 	cx
	add 	ax, WORD [datasector] 			; base data sector
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
;Bootloader Entry Point
;=======================================

Main:

    ; code located at 0000:7C00, adjust segment registers

    ; NOTE: later make so we figure out where bios loaded us instead of hard coding the value 0x7c00 (if needed)

	cli										; disable interrupts
	mov     ax, 0x07C0						; setup registers to point to our segment
	mov     ds, ax
	mov     es, ax
	mov     fs, ax
	mov     gs, ax

	;setting up the stack

	mov     ax, 0x0000						; set the stack
	mov     ss, ax
	mov     sp, 0xFFFF
	sti										; restore interrupts

    ;Display loading message

	mov 	si, msgLoading					; our message to print
	call	Print							; call our print function

;=======================================
;Load root directory table
;=======================================

LoadRoot:
		; calculate size of root directory and store in cx

		xor 	cx, cx
		xor 	dx, dx
		mov 	ax, 0x0020						; use the value 32 to multiplay with the amount of root entries
		mul 	WORD [bpbRootEntries]			; because each root entry is 32 bytes long
		div 	WORD [bpbBytesPerSector]		; devide by bytes per sector so we get how many sectors the root directory is
		xchg 	ax, cx                      	; exchange values of ax with cs

		; compute starting location of root and store in ax

		mov 	al, BYTE [bpbNumberOfFATs] 		; get number of fats
		mul 	WORD [bpbSectorsPerFAT]			; multiply by sectors per fat
		add 	ax, WORD [bpbReservedSectors]	; account for reserved sectors
		mov 	WORD [datasector], ax       	; base of root directory
		add 	WORD [datasector], cx 			; add with size end of root for data region

		mov 	bx, 0x0200
		call 	LoadSectors	

;=======================================
;Find stage2 root entry
;browse root entry for binary image
;=======================================


		mov 	cx, WORD [bpbRootEntries] 	; counter
		mov 	di, 0x0200 					; location where root resides
	RootLoop:
		push 	cx
		mov 	cx, 0x000B 					; Character name is 11 bytes 
		mov 	si, ImageName 				; name to find
		push 	di 							; push di because it gets incremented from rep cmpsb 
	rep cmpsb 								; compare DS:SI and ES:DI by subtraction. rep repeats cmpsb cx times (11)
		pop 	di
		je 		LoadFat 					; if equal, jump to load fat
		pop 	cx
		add 	di, 0x0020 					; add 32 bytes for next entry
		loop 	RootLoop 					; decs cx reg and checks for 0, if 0, execute next line
		jmp 	Failure

;=======================================
;load fat 
;=======================================

LoadFat:
 	
	; di has start of root entry we want, add26 to get the 26th part of entry (starting cluster)

	mov 	si, msgCRLF
	call 	Print	
	mov 	dx, WORD [di + 0x001A] 			; starting cluster
	mov 	WORD [cluster], dx

	; compute size of FAT and store in "cx"

	xor 	ax, ax
	mov 	al, BYTE [bpbNumberOfFATs]
	mul 	WORD [bpbSectorsPerFAT]
	mov 	cx, ax
	mov 	ax, WORD [bpbReservedSectors] 	; remember FAT begins right after reserved sectors

	mov 	bx, 0x0200 						; put FAT above bootcode
	call 	LoadSectors

	; set destination for Stage2 to 0050:0000

	mov 	si, msgCRLF
	call 	Print
	mov 	ax, 0x0050
	mov 	es, ax
	mov 	bx, 0x0000
	push 	bx

;=======================================
;Load STAGE2
;=======================================

LoadStage2:

		mov     ax, WORD [cluster] 			; cluster to read
		pop     bx                          ; buffer to read into
		call    ClusterLBA                  ; convert cluster to LBA
		xor     cx, cx
		mov     cl, BYTE [bpbSectorsPerCluster]     ; sectors to read
		call    LoadSectors
		push    bx

	; calculate next cluster

		; devide by two, then add by original value because thats the
		; same as multiplying by 3/2 (1.5). Beause each cluster num
		; is 1.5 times bigger than a byte, we need to multiplay the
		; cluster num by 1.5 to access the byte we start refrencing from.

		mov 	ax, WORD [cluster] 			; copy currrent cluster because we need different valuse from it
		mov 	cx, ax
		mov 	dx, ax
		shr 	dx, 0x0001 							 
		add 	cx, dx								
		mov 	bx, 0x0200							


		add 	bx, cx 						; index into FAT
		mov 	dx, WORD [bx] 				; read two byted from FAT
		test 	ax, 0x0001					; AND to test if Odd
		jnz 	OddCluster

	EvenCluster:

		shr 	dx, 0x0004 					; take high 12 bits
		jmp 	CheckEndCluster

	OddCluster:

		and 	dx, 0000111111111111b 		; take low 12 bits

	CheckEndCluster:

		mov 	WORD [cluster], dx
		cmp 	dx, 0x0FF0
		jb  	LoadStage2

 	DONE:
     
		mov     si, msgCRLF
		call    Print
		push    WORD 0x0050
		push    WORD 0x0000
		retf 								; jump to execute Stage2

	Failure:
		mov     si, msgFailure
		call    Print
		mov     ah, 0x00
		int     0x16                                ; await keypress
		int     0x19

;=======================================
;DATA SECTION
;=======================================	
	
	absoluteSector	db 0x00
	absoluteHead	db 0x00
	absoluteCylinder	db 0x00

	datasector  dw 0x0000
	cluster     dw 0x0000
	ImageName   db "STAGE2  SYS"

	msgLoading  db 0x0D, 0x0A, "Loading Boot Image ", 0x0D, 0x0A, 0x00	
	msgProgress db ".", 0x00
	msgCRLF     db 0x0D, 0x0A, 0x00		
	msgFailure  db 0x0D, 0x0A, "ERROR : Press Any Key to Reboot", 0x0A, 0x00
	msgTest  db 0x0D, 0x0A, "0", 0x0A, 0x00
				

times 510 - ($-$$) db 0						; we have to be 512 bytes. add the rest of the bytes to be 0
dw 0xaa55