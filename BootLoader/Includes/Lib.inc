;=======================================
;LIB (common functions for boot loader)			
;=======================================

bits 	16
 
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
 