;=======================================
;Set up GDT	(Global Descriptor Table)				
;=======================================

bits 	16

; The GDT marks portions of the memory as readable/writeable/executable. 
;GDT tells the CPU which parts of the block can have particular permissions, so for all the requests that fall in the address range specified, those permissions must be respected. 
; the GDT does not provide a way to actually manage those portions.
; I will later use paging to actually manage manage those portions of memory
; this GDT is refered to as a flat memory model. Since I intend to not actually use segmentation, I will instead have a flat 32bit address space for both the kernel and user programs and rely on paging instead (as most systems do), I will just create dummy segments in it, spanning the whole address space (base 0, limit 0xffffffff).
; we need to set up the gdt because pmode requirse the gdt to be set up.


GDTData:
	dq		0

;start of GDT Code segment
	
	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		10011010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (4k pages, see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

;start of GDT Data Segment

	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		10010010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (4k pages, see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

;start of GDT User Code segment
	
	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		11111010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (4k pages, see GDT for break down) and bits 16-19 of limit
	db 		0 								; high byte for base address

;start of GDT User Data Segment

	dw		0x0FFFF 						; 0 - 15 length for segment (limit)
	dw		0 								; low 16 bits for base address
	db 		0 								; middle byte for base address
	db 		11110010b 						; access (see GDT for the break down)
	db 		11001111b 						; granularity (4k pages, see GDT for break down) and bits 16-19 of limit
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