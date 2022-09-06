; not limited to 512 bytes

%define 	CODE_DESC 0x08
%define 	DATA_DESC 0x10
%define 	IMAGE_RMODE_BASE 0x3000
%define 	IMAGE_PMODE_BASE 0x100000

 
org 0x0500									; we are loaded at linear address 0x500
 
bits 	16									; we are still in real mode
 
; 0x500 is not used by anything else so we arent over writing important data


jmp 	main								; jump to main

;=======================================
;includes			
;=======================================

%include ".././BootLoader/Includes/A20.inc"
%include ".././BootLoader/Includes/GDT.inc"
%include ".././BootLoader/Includes/Lib.inc"
%include ".././BootLoader/Includes/Kernel_Loader.inc"
%include ".././BootLoader/Includes/Disk_Data.inc"





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
	mov 	si, GDTInstalled
	call 	Print
	call 	HandleA20 						; enable A20 Gate
	mov 	si, A20IsEnabled
	call 	Print
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
	div 	ebx 							; divide by 4 because we load 4 bytes
	cld
   	mov     esi, IMAGE_RMODE_BASE
   	mov		edi, IMAGE_PMODE_BASE
   	mov 	ecx, eax 						
   	rep 	movsd 							; loads a doubleword from ds:si to es:di, repeated cx times (128)

JumpToKernel:
    jmp 	CODE_DESC:IMAGE_PMODE_BASE

FATROOTLOC: 			DB 0x00