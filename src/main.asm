global _start

bits 64

extern cmdList
extern setupSignalHandler
extern setPath

global argv
global shellLoop
global forkedPID
global inputBuf
global env
global file

global execveFailStr
global execveFailStrLen

section .bss
inputBuf: resb 256
argv: resq 64
env: resq 256
cwd: resb 256
file: resb 64
brkLocation: resq 1
forkedPID: resq 1 ; idk what the size of linux process ids are lmao

section .data
prompt: db ">"
execveFailStr: db "execve failed",0xa
execveFailStrLen: equ $-execveFailStr

section .text
; shift all the chars in a string one place to the left
; will be used for characters like \ and "
shiftStr:
	push rbx
	push rcx
	mov rbx, rax
shiftLoop:
	inc rbx
	mov cl, byte [rbx]
	mov byte [rax], cl
	cmp cl, 0
	je shiftEnd
	inc rax
	jmp shiftLoop
shiftEnd:
	pop rcx
	pop rbx
	ret

_start:
	call setupSignalHandler
; get brk location
	mov rax, 0xc ; brk
	mov rdi, 0
	syscall
	mov qword [brkLocation], rax

; skip args
	pop rcx ; argc
argLoop:
	cmp rcx, 0x0
	je argLoopEnd
	dec rcx
	pop rsi
	jmp argLoop
argLoopEnd:

; copy envp
	pop rsi
	lea rbx, [env]
	mov rdi, qword [brkLocation]
envLoop:
	pop rsi
	cmp rsi, 0x0
	je envLoopEnd
; get strlen of current env variable
	mov rcx, rsi
envLenLoop:
	inc rcx
	cmp byte [rcx], 0x0
	jne envLenLoop
	inc rcx ; for the last null byte
	sub rcx, rsi
	; allocate space for the env var
	add rdi, rcx
	mov rax, 0xc ; brk
	push rcx
	syscall
	pop rcx
	sub rdi, rcx
	; put the pointer to that into env
	mov qword [rbx], rdi
	; copy that into the new space
	repe movsb
	add rbx, 8
	jmp envLoop
envLoopEnd:

shellLoop:
; write cwd
	mov rax, 0x4f
	mov rdi, cwd
	mov rsi, 256
	syscall
	; rax should have the amount of bytes written
	mov rdx, rax
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, cwd
	syscall
; write prompt
	mov rax, 0x1 ; write
	mov rdi, 0x1 ; stdout
	mov rsi, prompt
	mov rdx, 1
	syscall

; read from stdin
	xor rax, rax
	xor rdi, rdi
	mov rsi, inputBuf
	mov rdx, 256
	syscall

	mov al, byte [inputBuf]
	cmp al, 0
	je shellLoop

; parse for argv
	lea rdi, [inputBuf]
	lea rcx, [argv]
	cmp byte [rdi], 0xa
	je shellLoop
nextArg:
	mov rdx, rdi
spaceCheck:
	inc rdi
	cmp byte [rdi], 0x0
	je endOfArgs
	cmp byte [rdi], 0xa ; \n
	jne notNewline
	mov byte [rdi], 0x0
	jmp endOfArgs
notNewline:

	cmp byte [rdi], '\'
	jne noBackslash
	mov rax, rdi
	call shiftStr
	inc rdi
	jmp spaceCheck
noBackslash:
	cmp byte [rdi], ' '
	jne spaceCheck

	mov byte [rdi], 0x0
	mov qword [rcx], rdx
	add rcx, 8
	inc rdi

	jmp nextArg
endOfArgs:
	mov qword [rcx], rdx
	add rcx, 8
	mov qword [rcx], 0x0

; check for builtin commands
	lea rbx, [cmdList]
commandCheck:
	mov rax, qword [rbx]
	cmp rax, 0x0
	je commandCheckEnd
	lea rdi, [inputBuf]
	lea rax, [rbx + 8]
	mov rsi, qword [rbx]
	movzx rcx, byte [rax]
	repe cmpsb
	je commandCheckSuccess
	add rbx, 24
	jmp commandCheck
commandCheckSuccess:
	lea rax, [rbx + 16]
	mov rbx, qword [rax]
	call rbx
	jmp shellLoop
commandCheckEnd:

	mov rax, argv
	call setPath

; fork
	mov rax, 0x39
	syscall

; if fork, execve to program specified by stdin
	cmp rax, 0x0
	jne notForked
forked:
	mov rax, 0x3b ; execve
	mov rdi, file
	mov rsi, argv
	mov rdx, env
	syscall
	; exit if execve fails
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, execveFailStr
	mov rdx, execveFailStrLen
	syscall
	mov rax, 0x3c
	mov rdi, 69
	syscall

notForked:
; wait 
	mov [forkedPID], rax
	mov rax, 0x3d ; wait4
	xor rdi, rdi ; pid
	xor rsi, rsi ; stat_addr
	xor rdx, rdx; options
	xor r10, r10 ; rusage
	syscall
	
	mov qword [forkedPID], 0
	
	jmp shellLoop



