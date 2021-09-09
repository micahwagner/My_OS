;---------------------------------------
;Pmode (32 - bit) functions 					
;---------------------------------------
org 	0x100000
bits 	32


jmp 	KernelStub

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


;=======================================
;Stage 3 
;=======================================


KernelStub:

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

;=======================================
;DATA
;=======================================

msg db  0x0A, 0x0A, "                                   - MiDOS -", 0 
