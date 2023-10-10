; PROGRAM 2
dane1 segment	
;wartości sinusów i cosinusów
	angle_sin1     dw     0, 344, 688, 1032, 1377, 1721, 2065, 2409, 2753, 3097, 3441, 3785, 4128, 4472, 4815, 5159, 5502, 5845, 6188, 6530
	angle_sin2     dw     6873, 7215, 7557, 7899, 8241, 8582, 8923, 9264, 9605, 9945, 10286, 10625, 10965, 11304, 11643, 11982, 12320, 12658, 12996, 13333
	angle_sin3     dw     13670, 14007, 14343, 14679, 15014, 15349, 15683, 16017, 16351, 16684, 17017, 17349, 17681, 18012, 18343, 18673, 19003, 19332, 19661, 19989
	angle_sin4     dw     20317, 20644, 20970, 21296, 21621, 21946, 22270, 22594, 22917, 23239, 23560, 23881, 24202, 24521, 24840, 25159, 25476, 25793, 26109, 26425
	angle_sin5     dw     26739, 27053, 27366, 27679, 27991, 28301, 28612, 28921, 29230, 29537, 29844, 30150, 30456, 30760, 31064, 31366, 31668, 31969, 32269, 32569
	angle_sin6     dw     32867, 33164, 33461, 33756, 34051, 34345, 34637, 34929, 35220, 35510, 35799, 36087, 36374, 36659, 36944, 37228, 37511, 37793, 38074, 38353
	angle_sin7     dw     38632, 38910, 39186, 39461, 39736, 40009, 40281, 40552, 40822, 41091, 41358, 41625, 41890, 42155, 42418, 42679, 42940, 43200, 43458, 43715
	angle_sin8     dw     43971, 44226, 44479, 44731, 44982, 45232, 45481, 45728, 45974, 46219, 46462, 46704, 46945, 47185, 47423, 47660, 47896, 48130, 48363, 48595
	angle_sin9     dw     48825, 49054, 49282, 49508, 49733, 49956, 50178, 50399, 50619, 50837, 51053, 51268, 51482, 51694, 51905, 52115, 52323, 52529, 52734, 52938
	angle_sin10    dw     53140, 53341, 53540, 53738, 53935, 54129, 54323, 54515, 54705, 54894, 55081, 55267, 55451, 55634, 55815, 55995, 56173, 56349, 56524, 56698
	angle_sin11    dw     56870, 57040, 57209, 57376, 57542, 57706, 57868, 58029, 58188, 58346, 58502, 58656, 58809, 58960, 59109, 59257, 59403, 59548, 59691, 59832
	angle_sin12    dw     59972, 60110, 60246, 60381, 60514, 60645, 60775, 60903, 61029, 61154, 61277, 61398, 61518, 61635, 61752, 61866, 61979, 62090, 62199, 62307
	angle_sin13    dw     62413, 62517, 62619, 62720, 62819, 62916, 63011, 63105, 63197, 63288, 63376, 63463, 63548, 63631, 63713, 63792, 63870, 63947, 64021, 64094
	angle_sin14    dw     64165, 64234, 64301, 64367, 64431, 64493, 64553, 64612, 64668, 64723, 64776, 64828, 64877, 64925, 64971, 65015, 65058, 65098, 65137, 65174
	angle_sin15    dw     65209, 65243, 65274, 65304, 65332, 65358, 65383, 65405, 65426, 65445, 65462, 65478, 65491, 65503, 65513, 65521, 65527, 65532, 65535, 65535

;iteratory do przechodzenia po odpowiednich sinusach w trakcie rysowania elipsy
	iter1 			dw		?
	iter2 			dw		?
	
;parametry do rysowania punktu
	point_x 		dw		?	
	point_y 		dw		?
	point_color	    db  	?
;parametry elipsy
	cur_color		db		40
	x_center		dw		160
	y_center		dw		100
	minor_ax		dw		0
	major_ax		dw		0
	
;bufor na input podany przy uruchomieniu programu i różne komunikaty
	input		    db	 	100 dup('$')
	pass_parameters db		"Program powinien byc uruchomiany z parametrami!$"
	wrong_input     db		"Blad danych wejsciowych, nalezy podac dwie liczby z przedzialu (0, 200)!$"
	new_line        db		13, 10, '$'
	
dane1 ends


code1 segment

start1:	
;inicjalizacja stosu
	mov		ax, seg stos1
	mov		ss, ax
	mov 	sp, offset ws1

;zapamietanie w es miejsca z argumentami z command line
	mov		ax, ds
	mov		es, ax
	
	mov		si, 082h
	xor		cx, cx
	mov		cl, byte ptr es:[080h]
	
;przsunięcie rejestru danych do ds
	mov		ax, seg	dane1
	mov		ds, ax
	mov		di, offset input

;sprawdzenie czy zostały podane jakieś parametry, komunikat o błędzie w przypadku gdy nie zostały podane
	cmp		cl, 0
	jnz		copy	
	mov		dx, offset pass_parameters
	call	print_text	
	mov 	ax, 4c00h
	int 	21h
	
;kopiowanie podanych parametrów do bufora input
copy:
	mov		al, byte ptr es:[si]
	mov		byte ptr ds:[di], al
	inc		si
	inc		di
	loop	copy

;parsowanie argumentów
	mov		di, offset input	
	call	skip_whitespace
	call 	parse_number
	mov		word ptr ds:[major_ax], ax
	shr		word ptr ds:[major_ax], 1
	mov		bx, di
	call	skip_whitespace
	cmp		bx, di
	jz		faulty_input
	call 	parse_number
	mov		word ptr ds:[minor_ax], ax
	shr		word ptr ds:[minor_ax], 1
	
;przesunięcie rejestru es na początek pamięci obrazu
	mov		ax, 0a000h
	mov		es, ax	
	
	
; zmiana na tryb graficzny
	mov		al, 13h
	mov		ah, 0
	int 	10h
;---------------------------------------		

begin:
	mov		al, byte ptr ds:[cur_color]
	mov		byte ptr ds:[point_color], al
	call 	draw_ellipse

;obsługa przycisków
simulation:

	xor		ax, ax
	int 	16h
	
	cmp		ah, 1
	jz		ending
	
	cmp		ah, 30
	jz		move_left

	cmp		ah, 31
	jz		move_down
	
	cmp		ah, 32
	jz		move_right
	
	cmp		ah, 17
	jz		move_up
	
	cmp		ah, 72
	jz		extend_height

	cmp		ah, 80
	jz		shrink_height
	
	cmp		ah, 77
	jz		extend_width
	
	cmp		ah, 75
	jz		shrink_width
	
	cmp		ah, 2
	jz		dec_color
	
	cmp		ah, 3
	jz		inc_color
	
	jmp		simulation


ending:
	
; zmiana z powrotem na tryb tekstowy
	mov		al, 3h
	mov		ah, 0
	int 	10h
;------------------------------------
; Zakończenie programu
	mov 	ax, 4c00h
	int 	21h


;printowanie na ekran
print_text: 
	mov		ah, 9
	int		21h	
	ret  
	
;---------------------------------------------
move_down:
	mov		ax, word ptr ds:[y_center]
	inc		ax
	add		ax, word ptr ds:[major_ax]
	cmp		ax, 200
	jge		begin
	
	inc		word ptr ds:[y_center]
	call 	draw_ellipse
	dec		word ptr ds:[y_center]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	inc		word ptr ds:[y_center]
	jmp		begin
	
	
	
move_up:
	mov		ax, word ptr ds:[y_center]
	dec		ax
	sub		ax, word ptr ds:[major_ax]
	cmp		ax, -1
	jle		begin
	
	dec		word ptr ds:[y_center]
	call 	draw_ellipse
	inc		word ptr ds:[y_center]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	dec		word ptr ds:[y_center]
	jmp		begin
	
move_left:
	mov		ax, word ptr ds:[x_center]
	dec		ax
	sub		ax, word ptr ds:[minor_ax]
	cmp		ax, -1
	jle		begin
	
	dec		word ptr ds:[x_center]
	call	draw_ellipse
	inc		word ptr ds:[x_center]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	dec		word ptr ds:[x_center]
	jmp		begin
	
move_right:
	mov		ax, word ptr ds:[x_center]
	inc		ax
	add		ax, word ptr ds:[minor_ax]
	cmp		ax, 320
	jge		begin
	
	inc		word ptr ds:[x_center]
	call	draw_ellipse
	dec		word ptr ds:[x_center]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	inc		word ptr ds:[x_center]
	jmp		begin
	
	
extend_height:
	mov		ax, word ptr ds:[y_center]
	dec		ax
	sub		ax, word ptr ds:[major_ax]
	cmp		ax, -1
	jle		begin
	mov		ax, word ptr ds:[y_center]
	inc		ax
	add		ax, word ptr ds:[major_ax]
	cmp		ax, 200
	jge		begin
	
	inc		word ptr ds:[major_ax]
	call	draw_ellipse
	dec		word ptr ds:[major_ax]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	
	inc		word ptr ds:[major_ax]
	jmp		begin
	
	
shrink_height:
	mov		ax, word ptr ds:[major_ax]
	dec		ax
	cmp		ax, 0
	jle		begin
	
	dec		word ptr ds:[major_ax]
	call	draw_ellipse
	inc		word ptr ds:[major_ax]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	
	
	dec		word ptr ds:[major_ax]
	jmp		begin
	
	
extend_width:
	mov		ax, word ptr ds:[x_center]
	dec		ax
	sub		ax, word ptr ds:[minor_ax]
	cmp		ax, -1
	jle		begin
	mov		ax, word ptr ds:[x_center]
	inc		ax
	add		ax, word ptr ds:[minor_ax]
	cmp		ax, 320
	jge		begin
	
	inc		word ptr ds:[minor_ax]
	call	draw_ellipse
	dec		word ptr ds:[minor_ax]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	
	inc		word ptr ds:[minor_ax]
	jmp		begin
	
shrink_width:
	mov		ax, word ptr ds:[minor_ax]
	dec		ax
	cmp		ax, 0
	jbe		begin
	
	dec		word ptr ds:[minor_ax]
	call	draw_ellipse
	inc		word ptr ds:[minor_ax]
	
	mov		byte ptr ds:[point_color], 0
	call 	draw_ellipse
	
	dec		word ptr ds:[minor_ax]
	jmp		begin

dec_color:
	mov		ah, byte ptr ds:[cur_color]
	dec 	ah
	cmp		ah, 16
	jbe		begin
	
	dec		byte ptr ds:[cur_color]
	jmp		begin


inc_color:
	mov		ah, byte ptr ds:[cur_color]
	dec 	ah
	cmp		ah, 102
	jae		begin
	
	inc		byte ptr ds:[cur_color]
	jmp		begin
	
	
	
;///////////////////////////////////////////////////
;Rysowanie elipsy

draw_ellipse:
	mov		cx, 300
	mov		word ptr ds:[iter1], offset angle_sin1
	mov		word ptr ds:[iter2], offset angle_sin15
	add		word ptr ds:[iter2], 38
	
	ellipse:
		push	cx

		mov		bx,	word ptr ds:[iter1]
		mov		ax,	word ptr ds:[bx]
		mov		bx,	word ptr ds:[minor_ax]
		mul		bx
		mov		word ptr ds:[point_x], dx
	
		mov		bx,	word ptr ds:[iter2]
		mov		ax,	word ptr ds:[bx]
		mov		bx,	word ptr ds:[major_ax]
		mul		bx
		mov		word ptr ds:[point_y], dx
		call	put_four_pixels
	
		add		word ptr ds:[iter1], 2
		sub		word ptr ds:[iter2], 2
		pop		cx
		loop	ellipse
	ret
	
;////////////////////////////////////////////////////
;Zapalenie 4 symetrycznych punktów
put_four_pixels:
	call	put_pixel
	neg		word ptr ds:[point_y]
	call 	put_pixel
	neg		word ptr ds:[point_x]
	call	put_pixel
	neg		word ptr ds:[point_y]
	call 	put_pixel
	ret
;------------------------------------------------
;Zapalanie punktu o współrzędnych point_x, point_y
;i przesunięciu x_offset, y_offset
put_pixel:
	mov		ax, word ptr ds:[point_y]
	add		ax, word ptr ds:[y_center]
	mov		bx, 320
	mul		bx
	;ax to teraz 320*(y + y_offset)
	mov		bx, word ptr ds:[point_x]
	add		ax, word ptr ds:[x_center]
	add		bx, ax
	mov		al, byte ptr ds:[point_color]
	mov		byte ptr es:[bx], al
	ret
	
;wyświetlenie komunikatu o błędnych danych i zakończenie programu
faulty_input:
	pop		ax
	mov		dx, offset wrong_input
	call 	print_text
	mov 	ax, 4c00h
	int 	21h
	
;parsowanie liczby podanej na wejściu
parse_number:
	dec		di
	mov		ax, 0
	parser:
		push	ax
		inc		di
		mov		ah, byte ptr ds:[di]
		
		cmp		ah, 32
		jz		finish_parsing
		cmp		ah, 9
		jz		finish_parsing
		cmp		ah, 13
		jz		finish_parsing
		cmp		ah, 48
		jb		faulty_input
		cmp		ah, 57
		ja		faulty_input
		
		pop		ax
		mov		bx, 10
		mul		bx
		xor		bx, bx
		mov		bl, byte ptr ds:[di]
		sub		bx, 48
		add		ax, bx
		
		cmp		ax, 0
		jl		faulty_input
		cmp		ax, 200
		jg		faulty_input
		jmp		parser
		
	finish_parsing:
	pop		ax
	ret
	
	
; omijanie spacji i znaków tabulacji z pętlą while
skip_whitespace:
	sub			di, 1
	petla_while:
		add		di, 1
		mov		ah, byte ptr ds:[di]
		cmp		ah, 32
		jz		petla_while
		cmp		ah, 9
		jz		petla_while
	ret
	
code1 ends


; segment stosu
stos1 segment stack
		dw	300		dup(?)
	ws1 dw 	?

stos1 ends

end start1