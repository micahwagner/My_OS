; Note: Here, we are executed like a normal
; COM program, but we are still in Ring 0.
; We will use this loader to set up 32 bit
; mode and basic exception handling
 
; This loaded program will be our 32 bit Kernel.
 
; We do not have the limitation of 512 bytes here,
; so we can add anything we want here!
 
org 0x0										; offset to 0, we will set segments later
 
bits 	16									; we are still in real mode
 
; we are loaded at linear address 0x500
	
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
;Installing GDT uing lgdt			
;=======================================
	
InstallGDT:
	cli 									; clear ints to ensure no tripple fault
	pusha 									; save registers
	lgdt 	[GDTR] 							; load GDT into GDTR
	sti 									; enable ints
	popa 									; restore registers
	ret 									; return
	

;*************************************************;
;	Second Stage Loader Entry Point
;************************************************;
 
main:
	cli										; clear interrupts
	push	cs								; Insure DS=CS
	pop		ds
 
	mov		si, Msg
	call	Print
 
	cli										; clear interrupts to prevent triple faults
	hlt										; hault the system
 
;*************************************************;
;	Data Section
;************************************************;
 
Msg	db	"Preparing to load operating system...",13,10,0