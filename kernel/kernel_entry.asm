bits 32

extern kernel_main
global entry


entry:
	cli
	call 	kernel_main
	jmp 	$

times 512-($ - $$) db 0