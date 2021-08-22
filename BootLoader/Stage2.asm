; not limited to 512 bytes
 
org 0x500									; we are loaded at linear address 0x500
 
bits 	16									; we are still in real mode
 
; 0x500 is not used by anything else so we arent over writing important data
	
jmp 	main								; jump to main
 
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
		ret									; we are done, so return
 
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

;=======================================
;Installing GDT using lgdt			
;=======================================
	
InstallGDT:
	cli 									; clear ints to ensure no tripple fault
	pusha 									; save registers
	lgdt 	[GDTR] 							; load GDT into GDTR
	sti 									; enable ints
	popa 									; restore registers
	ret 									; return
	

;=======================================
;Stage 2 entry point			
;=======================================
 
main:

	cli 									; clear interrupts
	xor 	ax, ax							; null data segments
	mov		ds, ax
	mov		es, ax
	mov 	ax, 0x9000 						; stack starts at 9000 - ffff
	mov 	ss, ax
	mov 	sp, 0xFFFF
	sti 									; enable interupts

	mov 	si, LoadMsg
	call 	Print

	call InstallGDT 						; instal GDT into GDTR

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
;Data			
;=======================================
 
LoadMsg db	"Preparing to load operating system...",13,10,0

;=======================================
;Stage 3 "kernel"
;=======================================

bits 32

Stage3:

	mov		ax, 0x10						; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h						; stack begins from 90000h

	cli
	hlt


