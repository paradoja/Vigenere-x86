section .data
	e_num_pars              db ': must be called with 2 parameters', 10
	e_num_pars_l            equ $ - e_num_pars
        e_write                 db 'There was an error writing', 10
        e_write_l               equ $ - e_write

section	.text
        global _start

_start:
	pop	ebx		; argc (number of parameters)
        cmp     ebx, 3          ; 2 (+ 1) par.

	pop	ebx		; argv[0] (0th parameter, the program's name)
        jz      main_program

	;; The executable was called incorrectly
        mov     ecx, ebx        ; We'll write the program's name
        ;; XXX Cogemos longitud de ristra, que me la voy a inventar
        mov     edx, 5          ; length to write
        mov     eax, 4          ; write
        mov     ebx, 1          ; file descriptor; 1 = stdout
        int     80h             ; calling the Kernel, int. 80

	;; now common error subroutine
        mov     ecx, e_num_pars
        mov     edx, e_num_pars_l
        push    1
        jmp     error

main_program:
	pop	ebx		; The first real arg, a filename
        mov     eax, 5          ; open
        int     80h
        push    eax

	; imprimir por pantalla un poco
        mov     edx, 100        ; length to write
        mov     eax, 4          ; write
	mov     ebx, 1
        int     80h

	pop	ebx		; El segundo parámetro
	mov	eax,8		; The syscall number for creat() (we already have the filename in ebx)
	mov	ecx,00644Q	; Read/write permissions in octal (rw_rw_rw_)
	int	80h		; Call the kernel
				; Now we have a file descriptor in eax

	test	eax,eax		; Lets make sure the file descriptor is valid
	js	skipWrite	; If the file descriptor has the sign flag
				;  (which means it's less than 0) there was an oops,
				;  so skip the writing. Otherwise call the fileWrite "procedure"
	call	fileWrite
        jmp     fin

skipWrite:
	push	eax		; If there was an error, save the errno in the stack
        jmp     error

; proc fileWrite - write a string to a file
fileWrite:
	mov	ebx,eax		; sys_creat returned file descriptor into eax, now move into ebx
	mov	eax,4		; sys_write
				; ebx is already set up
	pop     ecx
        mov     edx,10
	;; mov	ecx,hello	; We are putting the ADDRESS of hello in ecx
	;; mov	edx,helloLen	; This is the VALUE of helloLen because it's a constant (defined with equ)
	int	80h

	mov	eax,6		; sys_close (ebx already contains file descriptor)
	int	80h
	ret
; endp fileWrite

; the stack will have the errno
error:
        mov     eax, 4          ; write
        mov     ebx, 1          ; desc. fichero
        int     80h

	mov     eax,1           ; exit
        pop     ebx             ; exit with the errno already given
	int     80h

fin:
	mov     eax,1           ; exit
	mov     ebx,0           ; exit with a 0 (no problem)
	int     80h
