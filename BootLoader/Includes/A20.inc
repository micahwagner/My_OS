;=======================================
;Enable A20 Gate
;0x60 R/W: Data port
;0x64 R: Status  register
;0x64 W: Command register
;0x92: system control port A
;=======================================

bits 	16

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
