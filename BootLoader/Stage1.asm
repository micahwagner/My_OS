
;=======================================
;Bootloader Pt. 1
;=======================================

bits	16									; 16 bit real mode

org		0x0									; changed later in main


Start:		jmp main

;=======================================
;OEM Parameter block
;=======================================

bpbOEM					db "MiDOS   " 		; cant be more than 8 bytes because  OEM starts on 11th byte

bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	    DB 2
bpbRootEntries: 	    DW 224
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

		lodsb								; load next byte from string from SI to AL
		or 		al, al 						; does AL = 0?
		jz		PrintDone					; Yep, null terminator found, bail out
		mov 	ah, 0eh						; No, print Character
		int 	10h 						
		jmp 	Print 						; repeat until null terminator found
	PrintDone:
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
		pop		cx 							; pop original params for LBACHS
		pop 	bx
		pop 	ax
		jnz     LoadSectorLoop 				; if the error counter isnt 0, try loading again
		int 	0x18 						; if error counter is 0, then display error
	Success:
		mov		si, msgProgress
		call 	Print
		pop 	cx 							; pop to change values for next LoadSectorLoop call
		pop 	bx
		pop 	ax
		add 	bx, WORD [bpbBytesPerSector] 	; load next sector
		inc 	ax 							; change starting cluster
		loop 	ErrorDecloration 			; loop until num of clusters to read (cx) is 0
		ret


;=======================================
;LBACHS conversion
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

main:

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

	mov		si, msgLoading					; our message to print
	call	Print							; call our print function

;=======================================
;Load root directory table
;=======================================

LOAD_ROOT:
	
	; calculate size of root directory and store in cx

	xor 	dx, dx
	xor		cx, cx
	mov		ax, 0x0020						; use the value 32 to multiplay with the amount of root entries
	mul 	WORD [bpbRootEntries]			; because each root entry is 32 bytes long
	div 	WORD [bpbBytesPerSector]		; devide by bytes per sector so we get how many sectors the root directory is
	xchg    ax, cx                      	; exchange values of ax with cs

	; compute starting location of root and store in ax

	mov		al, BYTE [bpbNumberOfFATs] 		; get number of fats
	mul 	WORD [bpbSectorsPerFAT]			; multiply by sectors per fat
	add     ax, WORD [bpbReservedSectors]	; account for reserved sectors
	mov     WORD [datasector], ax       	; base of root directory
    add     WORD [datasector], cx 			; add with size end of root for data region

    mov 	bx, 0x0200
    call 	LoadSectors	

    cli
    hlt


.Reset:
	mov		ah, 0							; reset floppy disk function
	mov		dl, 0							; drive 0 is floppy drive
	int		0x13							; call BIOS
	jc		.Reset							; If Carry Flag (CF) is set, there was an error. Try resetting again
 
	mov		ax, 0x1000						; we are going to read sector to into address 0x1000:0
	mov		es, ax
	xor		bx, bx
 
	mov		ah, 0x02						; read floppy sector function
	mov		al, 1							; read 1 sector
	mov		ch, 1							; we are reading the second sector past us, so its still on track 1
	mov		cl, 2							; sector to read (The second sector)
	mov		dh, 0							; head number
	mov		dl, 0							; drive number. Remember Drive 0 is floppy drive.
	int		0x13							; call BIOS - Read the sector
	
 
	jmp		0x1000:0x0					; jump to execute the sector!

;=======================================
;DATA SECTION
;=======================================	
	
	absoluteSector	db 0x00
	absoluteHead	db 0x00
	absoluteCylinder	db 0x00

	datasector  dw 0x0000

	msgLoading  db 0x0D, 0x0A, "Loading Boot Image ", 0x0D, 0x0A, 0x00	
	msgProgress db ".", 0x00						

times 510 - ($-$$) db 0						; we have to be 512 bytes. add the rest of the bytes to be 0
dw 0xaa55