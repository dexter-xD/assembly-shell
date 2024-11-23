global cmdList

bits 64

extern argv
extern env
extern setPath
extern file

extern execveFailStr
extern execveFailStrLen

section .data
cmdList: 
	dq cmdCdStr, cmdCdLen, cmdCdFunc
	dq cmdAsdfStr, cmdAsdfLen, cmdAsdfFunc
	dq cmdExitStr, cmdExitLen, cmdExitFunc
	dq cmdExecStr, cmdExecLen, cmdExecFunc
	dq 0x0

section .text
cmdCdFunc:
	mov rax, 0x50 ; chdir
	mov rdi, [argv + 8]
	syscall
	ret

section .data
cmdCdStr:
	db "cd",0x0
cmdCdLen: equ $-cmdCdStr

section .text
cmdAsdfFunc:
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, cmdAsdfStr
	mov rdx, cmdAsdfLen
	syscall
	ret

section .data
cmdAsdfStr:
	db "asdf",0x0
cmdAsdfLen: equ $-cmdAsdfStr

section .text
cmdExitFunc:
	mov rax, 0x3c
	mov rdi, 69
	syscall

section .data
cmdExitStr:
	db "exit",0x0
cmdExitLen: equ $-cmdExitStr

section .data
cmdExecStr:
	db "exec",0x0
cmdExecLen: equ $-cmdExecStr

section .text
cmdExecFunc:
	mov rax, argv+8
	call setPath
	mov rax, 0x3b ; execve
	mov rdi, file
	mov rsi, argv+8
	mov rdx, env
	syscall
	; should only get past the syscall if execve failed
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, execveFailStr
	mov rdx, execveFailStrLen
	syscall
	ret
