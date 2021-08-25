; not limited to 512 bytes
 
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
 
;---------------------------------------
;Pmode (32 - bit) functions 					
;---------------------------------------

bits 	32

%define		VIDMEM	0xB8000					; video memory
%define		COLS	80						; width and height of screen
%define		LINES	25
%define		CHAR_ATTRIB 00001110b			; character attribute (Magenta text on white background)

CurX 	db 0
CurY 	db 0

;---------------------------------------
;Puts a character on th screen		
;BL = character to print		
;---------------------------------------


PChar32:
	
	pusha
	mov 	edi, VIDMEM

	xor 	eax, eax
	mov 	ecx, COLS * 2 					; each char is 2 bytes, we are trying to find the linear address
	mov 	al, BYTE [CurY] 				; multiply y value by screen width
	mul 	ecx
	push 	eax 							; store multiplication

	mov 	al, BYTE [CurX]					; multiply CurX by 2 because it is 2 bytes
	mov 	cl, 2
	mul 	cl
	pop 	ecx
	add 	eax, ecx 						; add x with y * screenwidth

	xor 	ecx, ecx
	add 	edi, eax 						; since edi contains base address, add offset

	cmp 	bl, 0x0A 						; 0x0A is asscii for new line, so check for 0x0A
	je 		NewRow

	mov 	dl, bl 							; because of little endian format, dl is stored 
	mov 	dh, CHAR_ATTRIB					; at the data part, and dh is the char attribute
	mov 	WORD [edi], dx 

	inc 	BYTE [CurX] 					; go to next character
	cmp 	BYTE [CurX], COLS 				; are we at the end of the row?
	je 		NewRow							; yes, go to new line
	jmp 	PDone 							; no, were done

NewRow:
	
	mov 	BYTE [CurX], 0 					; were back at collum 0
	inc 	BYTE [CurY] 					; go to next row

PDone:

	popa
	ret

;---------------------------------------
;Prints a string on th screen	
;EBX = address of string to print		
;---------------------------------------

PString32:
	
	pusha
	push 	ebx 							; copy string address for later
	pop 	edi

SLoop32:
	
	mov 	bl, BYTE [edi] 					; get next character
	cmp 	bl, 0 							; test if done
	je 		SDone32 						; yes were done
	call 	PChar32 						; were not, so print char
	inc 	edi 							; get next char
	jmp 	SLoop32

SDone32:

	mov 	bh, BYTE [CurY]
	mov 	bl, BYTE [CurX]
	call 	MovCur

	popa
	ret


;---------------------------------------
;updates hardware cursor
;bh = Y pos
;bl = X pos
;0xf = cursor location low
;0xe = cursor location high
;0x3D4 = index register
;0x3D5 = data register 		
;---------------------------------------

MovCur:

	pusha

; Here, CurX and CurY are relitave to the current position on screen, not in memory.
; That is, we don't need to worry about the byte alignment when displaying characters,
; so just follow the forumla: location = CurX + CurY * COLS
	
	xor		eax, eax
	mov		ecx, COLS
	mov		al, bh			
	mul		ecx								
	add		al, bl						
	mov		ebx, eax

;two values are needed to write to the CRT controller. 
;One to the Index Register 0x3D4 (Containing the type of data we are writing), 
;and one to the Data Register 0x3D5 (Containing the data)

; set low byte of cursor 0x0f

	mov 	al, 0x0F
	mov 	dx, 0x03D4
	out 	dx, al

	mov 	al ,bl
	mov 	dx, 0x03D5
	out 	dx, al

; set high byte of cursor 0x0e

	xor 	eax, eax

	mov 	al, 0x0E
	mov 	dx, 0x03D4
	out 	dx, al

	mov 	al ,bh
	mov 	dx, 0x03D5
	out 	dx, al

	popa
	ret


;---------------------------------------
;clears the screen
;---------------------------------------

ClrScr32:
	pusha
	cld 									; set direction flag to 0
	mov 	edi, VIDMEM
	mov 	cx, 2000						; 2000 chars on screen (80 * 25)
	mov 	ah, CHAR_ATTRIB
	mov 	al, " "
	rep 	stosw 							; store " " at VIDMEM cx amount of times

	mov 	BYTE [CurX], 0
	mov 	BYTE [CurY], 0
	popa
	ret

;---------------------------------------
;Goes to specified location
;AL = x pos
;AH = Y pos
;---------------------------------------

GotoXY:
	pusha
	mov 	[CurX], al
	mov 	[CurY], ah
	popa
	ret


bits 	16	


;=======================================
;Set up GDT	(Global Descriptor Table)				
;=======================================

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

	call 	EnableA20_KBOutputPort 			; enable A20 Gate

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

;---------------------------------------
;Data			
;---------------------------------------

msg db  0x0A, 0x0A, "                              - Welcome to MiDOS -", 0 
LoadMsg db	"Preparing to load operating system...",13,10,0

;=======================================
;Stage 3 "kernel"
;=======================================

bits 32

Stage3:

	mov		ax, 0x10						; set data segments to data selector (0x10)
	mov		ds, ax
	mov		es, ax
	mov 	ss, ax
	mov		esp, 90000h						; stack begins from 90000h

	call 	ClrScr32
	mov 	ebx, msg
	call 	PString32

	cli 
	hlt





