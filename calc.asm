
;PROGRAM 1
; definiowanie potrzebnych stringów i zmiennych w których będą przechowywane wczytane wartości i działanie
dane1 segment
	new_line 	     db  13, 10, '$'
	welcome_text     db  "Wprowadz slowny opis dzialania: $"
	wrong_input      db  "Blad danych wejsciowych!$"
	result  	     db  "Wynikiem jest: $"
	other_minus 	 db  "minus $"	
	
	input 		     db  128, ?, 130 dup('$')
	
	zero		     db  "zero$$$$$$$$$$$"
	jeden		     db  "jeden$$$$$$$$$$"
	dwa 		     db  "dwa$$$$$$$$$$$$"
	trzy 		     db  "trzy$$$$$$$$$$$"
	cztery 		     db  "cztery$$$$$$$$$"
	piec 		     db  "piec$$$$$$$$$$$"
	szesc 		     db  "szesc$$$$$$$$$$"
	siedem 		     db  "siedem$$$$$$$$$"
	osiem 		     db  "osiem$$$$$$$$$$"
	dziewiec 	     db  "dziewiec$$$$$$$"
	dziesiec 	     db  "dziesiec$$$$$$$"
	jedenascie 	     db  "jedenascie$$$$$"
	dwanascie	     db  "dwanascie$$$$$$"
	trzynascie	     db  "trzynascie$$$$$"
	czternascie	     db  "czternascie$$$$"
	pietnascie	     db  "pietnascie$$$$$"
	szesnascie	     db  "szesnascie$$$$$"
	siedemnascie     db  "siedemnascie$$$"
	osiemnascie	     db  "osiemnascie$$$$"
	dziewietnascie	 db  "dziewietnascie$"
	
	osiemdziesiat    db  "osiemdziesiat $$"
	siedemdziesiat	 db  "siedemdziesiat $"
	szescdziesiat	 db  "szescdziesiat $$"
	piecdziesiat	 db  "piecdziesiat $$$"
	czterdziesci     db  "czterdziesci $$$"
	trzydziesci	     db  "trzydziesci $$$$"
	dwadziescia	     db  "dwadziescia $$$$"
	
	
	cur_word	 	 dw  ?
	begin_pointer	 dw  ?
	
	plus		     db	 "plus$$"
	razy		     db	 "razy$$"
	minus		     db	 "minus$"
	
	liczba1 	     dw  -1 ; początkowo zmienne są inicjalizowane na -1, jeśli po wywołaniu algorytmu do parsowania inputu
	dzialanie	     dw  -1 ; dalej któraś będzie miała wartość -1 to znaczy, że wejściowe dane były błędne
	liczba2 	     dw  -1
	wynik		     dw  -1
	
	
dane1 ends


code1 segment

start1:	; inicjalizacja stosu
	mov		ax, seg stos1
	mov		ss, ax
	mov 	sp, offset ws1
	
	; wypisanie poczatkowego tekstu
	mov		dx, offset welcome_text
	call 	print_text
	
	
	; wczytanie inputu
	mov		ax, seg dane1
	mov		ds, ax
	mov		dx, offset input
	mov		ah, 0ah
	int 	21h

	; wypisanie nowej linii
	mov		dx, offset new_line
	call 	print_text
	
	; pierwsze dwa bajty należy pominąć
	mov		di, offset input + 2
	
	
	; pominięcie początkowych spacji ( jęśli występują)
	call 	skip_whitespace
	
	; di wskazuje teraz na właściwy początek inputu
	; zapisuje tą wąrtość w word ptr ds:[begin_pointer]
	; gdyż będę porywnywał input z każdą możliwą liczbą
	; więc za każdym razem trzeba będzie trzeba wracać na to samo miejsce
	; di będzie służył do iteracji po inpucie
	; do iteracji po drugim stringu posłuży rejestr si
	mov		word ptr ds:[begin_pointer], di
	
	; ponadto na stosie klade offset miejsca do którego będę chciał wrócić po sparsowaniu pierwszego stringa
	; jest tak dlatego, że z użyciem ret będę wracał wtedy gdy nie uda się niczego dopasować
	; i ten sam podprogram jest wykorzystywany jeszcze dwa razy, i wtedy muszę wrócić do innego miejsca
	mov 	ax, offset comeback
	push	ax
	
	; Na stosie ląduje także offset zmiennej do której zapiszę pierwszą liczbę
	mov		ax, offset liczba1
	push 	ax
	call 	parse_number
comeback:
	mov		ax, word ptr ds:[liczba1]
	; jęsli liczba1 to dalej -1 to znaczy, że nie udało się sparsować
	cmp		ax, -1
	jz		faulty_input
	
	
	mov		word ptr ds:[begin_pointer], di
	call 	skip_whitespace
	cmp		word ptr ds:[begin_pointer], di ; sprawdzanie czy między liczba a znakiem znajduje si
	jz		faulty_input
	
	
	; ten sam schemat tylko zamiast parse_number jest parse_symbol
	mov		word ptr ds:[begin_pointer], di
	mov 	ax, offset comeback2
	push	ax
	mov		ax, offset dzialanie
	push 	ax
	call 	parse_symbol
comeback2:
	mov		ax, word ptr ds:[dzialanie]
	cmp		ax, -1
	jz		faulty_input
	
	
	mov		word ptr ds:[begin_pointer], di
	call 	skip_whitespace
	cmp		word ptr ds:[begin_pointer], di
	jz		faulty_input
	
	; i znowu to samo
	mov		word ptr ds:[begin_pointer], di
	mov 	ax, offset comeback3
	push	ax
	mov		ax, offset liczba2
	push 	ax
	call 	parse_number
	
comeback3:
	mov		ax, word ptr ds:[liczba2]
	cmp		ax, -1
	jz		faulty_input
	
	
	call 	skip_whitespace
	mov 	ah, byte ptr ds:[di]
	cmp		ah, 13
	jnz		faulty_input
	
	
	; zapisane miejsca do którego należy skoczyć po obliczeniu wartości wyniku
	mov		ax, offset print_result
	push 	ax
	
		
	; obliczenie wartości wyniku w zależności od wybranego działania
	mov		ax, word ptr ds:[dzialanie]
	
	cmp 	ax, 3
	jz 		add_nums
	
	cmp 	ax, 2
	jz 		multiply_nums
	
	cmp 	ax, 1
	jz 		subtract_nums
	
	
print_result:
	
	mov  	dx, offset result
	call 	print_text
	
	mov		ax, word ptr ds:[wynik]
	cmp		ax, 0
	jge 	dont_print_minus
	; jeśli liczba jest ujemna to wypisuje na ekran minus(spacja) i mnożę wynik przez -1
	mov  	dx, offset other_minus
	call 	print_text
	mov		ax, word ptr ds:[wynik]
	mov		bx, -1
	mul		bx
	mov		word ptr ds:[wynik], ax
	
dont_print_minus: ; ostateczne printowanie
	
	mov		cx, 20
	mov		ax, 0
	mov 	word ptr ds:[cur_word], offset zero
	; po kolei sprawdzam czy wynik jest równy któreś z dziewietnastu liczb
	loop_cases:
		mov		dx, word ptr ds:[cur_word]
		cmp		ax, word ptr ds:[wynik]
		jz		ending
		add		ax, 1
		add		word ptr ds:[cur_word], 15
		loop	loop_cases
		
	mov		cx, 7
	mov		word ptr ds:[cur_word], offset osiemdziesiat
	
	
	; przypadek liczb większych lub równych dwadzieścia
	loop_other_cases:
		mov		bx, cx
		add		bx, 1
		mov		ax, 10
		mul		bx
		mov		dx, word ptr ds:[cur_word]
		cmp		word ptr ds:[wynik], ax
		jae		print_rest
		add		word ptr ds:[cur_word], 16
		loop	loop_other_cases
	
	
print_rest: ; cyfra jedności liczb większych niż dwadzieścia
	sub		word ptr ds:[wynik], ax
	call 	print_text
	
	mov		cx, 9
	mov		ax, 1
	mov 	word ptr ds:[cur_word], offset jeden
	
	loop_rest:
		mov		dx, word ptr ds:[cur_word]
		cmp		ax, word ptr ds:[wynik]
		jz		ending
		add 	ax, 1
		add		word ptr ds:[cur_word], 15
		loop 	loop_rest
	
	mov 	ax, 4c00h
	int 	21h

faulty_input:
	pop 	ax ; jeśli znajdę się w tym miejscu to na stosie dalej jest offset comeback i któraś ze zmiennych
	pop		ax
	mov		dx, offset wrong_input
	call 	print_text
	mov 	ax, 4c00h
	int 	21h
	

ending:
	call 	print_text
	mov 	ax, 4c00h
	int 	21h
	

print_text: 
	mov		ax, seg dane1
	mov 	ds, ax
	mov		ah, 9
	int		21h	
	ret     

add_nums:
	mov 	ax, word ptr ds:[liczba1]
	add		ax, word ptr ds:[liczba2]
	mov		word ptr ds:[wynik], ax
	ret
	

multiply_nums:
	mov		ax, word ptr ds:[liczba1]
	mov		bx, word ptr ds:[liczba2]
	mul		bx
	mov		word ptr ds:[wynik], ax
	ret
	
subtract_nums:
	mov		ax, word ptr ds:[liczba1]
	sub		ax, word ptr ds:[liczba2]
	mov		word ptr ds:[wynik], ax
	ret

; parsowanie liczb, na stosie kładę jaką liczbę teraz sprawdzam, 
;bo być może właśnie tą liczbę trzeba będzie zapisać do któreś ze zmiennych
parse_number:
	mov		cx, 10
	mov		word ptr ds:[cur_word], offset zero
	
	loop_numbers:
		mov		dx, word ptr ds:[cur_word]
		mov		ax, 10
		sub		ax, cx  
		push	ax
		mov 	si, word ptr ds:[cur_word]
		mov 	di, word ptr ds:[begin_pointer]
		call 	compare
		pop		ax
		add		word ptr ds:[cur_word], 15
		loop	loop_numbers
	
	ret
	
; schemat ten sam co w parse_number tylko inna ilość patternów i długość patternu
parse_symbol:
	mov		cx, 3
	mov		word ptr ds:[cur_word], offset plus
	
	loop_symbols:
		mov		dx, word ptr ds:[cur_word]
		mov		ax, cx
		push	ax
		mov 	si, word ptr ds:[cur_word]
		mov 	di, word ptr ds:[begin_pointer]
		call 	compare
		pop		ax
		add		word ptr ds:[cur_word], 6
		loop	loop_symbols
	
	ret
	

; jeśli znajdę	się w tym miejscu to na stosie jest pięc liczb które trzeba zdjąć
; są to liczba którą trzeba zapisać do zmiennej, a także offset tej zmiennej
; ponadto wcześniej został wywołany podprogram parse_(number, symbol), a także
; compare z których zrobiłem skok do tej procedury, więc nie zostało wywołane ret
; ret w tym przypadku powróci do miejsca comeback
save_number:
	pop 	ax
	pop		ax
	pop 	bx
	pop 	bx
	mov		word ptr ds:[bx], ax
	ret
	
	
; porównywanie znaków 
; prosta pętla, cx został ustawiony na długość patternu do którego przyrównuje input( a dokładnie jakiś podciąg inputu)
compare:
	compare_loop:
		mov 	al, byte ptr ds:[si]
		cmp		al, '$'
		jz		equal
		cmp 	al, byte ptr ds:[di]
		jnz     not_equal
		add	 	si, 1
		add		di, 1
		jmp   	compare_loop
	
	equal:
	jmp save_number
	not_equal:
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