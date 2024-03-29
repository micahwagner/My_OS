;=======================================
;Loads Kernel from Disc (same as stage 1)
;=======================================

bits 	16

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
