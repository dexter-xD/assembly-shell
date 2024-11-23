global setPath

extern file
extern inputBuf
extern argv

section .data
path: db "/bin/", 0x0

section .text
; I feel like I could probably name this better
setPath:
; if starting with / or . skip path check
	lea rdi, [file] ; loading file address since it needs to be set for both paths
	mov rdx, qword [rax]
	mov bl, byte [rdx]
	cmp bl, '/'
	je skipPath
	cmp bl, '.'
	je skipPath

; strcat path and argv[0]
	lea rsi, [path]
	mov rcx, 5
	repe movsb

skipPath:
	; get length of argv[0]
	mov rsi, qword [rax]
	xor rcx, rcx
argvSizeLoop:
	mov bl, byte [rsi]
	inc rsi
	inc cl
	cmp bl, 0x0
	jne argvSizeLoop


	mov rsi, qword [rax]
	repe movsb

	mov byte [rdi], 0x0
	ret
