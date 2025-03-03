.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Proiectel",0
area_width EQU 1000
area_height EQU 600
area DD 0

matrice_width equ 20
matrice_height equ 15


counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include objects.inc
include stari.inc

obj_width EQU 32
obj_height EQU 20

button1_x equ 500
button1_y equ 450
button_size_x equ 32
button_size_y equ 20
button2_x equ 532
button2_y equ 450


minge_i dd 11	;randul la care se afla mingea in matricea de joc (numerotare de la 0)
minge_j dd 9	;coloana la care se afla mingea in matricea de joc (numerotare de la 0)

minge_poz_y dd 260	;minge_i * obj_height + 40, pentru ca matriceca de joc se afiseaza de la 40 (in sus)
minge_poz_x dd 328  ;minge_j * obj_width + 40, pentru ca matriceca de joc se afiseaza de la 40 (la stanga)
minge_adresa dd 0


paleta_i dd 12	;randul la care se afla paleta in matricea de joc (numerotare de la 0)
paleta_j dd 8	;coloana la care se afla paleta in matricea de joc (numerotare de la 0)

paleta_poz_y dd 280		;paleta_i * obj_height + 40, pentru ca matriceca de joc se afiseaza de la 40 (in sus)
paleta_poz_x dd 296		;paleta_j * obj_width + 40, pentru ca matriceca de joc se afiseaza de la 40 (in stanga)
paleta_adresa dd 0

diry dd 0	;0 => sus, 1 => jos
dirx dd 0	;0 => stanga, 1 => dreapta

scor dd 0
contor_win dd 0	;cate blocuri trebuie sa fie sparte pentru a castiga
ok_game_over dd 1 ;se va face 0 cand se termina jocul


.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx 	;eax = y+objH - ecx (ecx = objH -> 1) => eax = y -> y+objH - 1  => ia valori de la 0 la y-1 in matricea care tebuie
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0	;culoarea negru
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh	;culoarea alb
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


make_background proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ;citim simbolul de afisat
	
	cmp eax, 0
	jl make_empty
	cmp eax, 7
	jg make_empty
	lea esi, objects
	jmp make_block
	
make_empty:
	mov eax, 0
	lea esi, objects
	
make_block:
	mov ebx, obj_width
	mul ebx
	mov ebx, obj_height
	mul ebx
	add esi, eax
	mov ecx, obj_height

bucla_background_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, obj_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, obj_width
	
bucla_background_coloane:
	cmp byte ptr [esi], 0
	je background_pixel_alb
	cmp byte ptr [esi], 1
	je background_pixel_visiniu
	cmp byte ptr [esi], 3
	je background_pixel_galben
	mov dword ptr [edi], 0	;negru
	jmp background_pixel_next
	
background_pixel_alb:
	mov dword ptr [edi], 0FFE7E2h ;alb
	jmp background_pixel_next
background_pixel_visiniu:
	mov dword ptr [edi], 0800600h ;visiniu
	jmp background_pixel_next
background_pixel_galben:
	mov dword ptr [edi], 0fcbe03h ;galben
	jmp background_pixel_next


background_pixel_next:
	inc esi
	add edi, 4
	loop bucla_background_coloane
	pop ecx
	loop bucla_background_linii
	popa
	mov esp, ebp
	pop ebp
	ret

make_background endp
	

;un macro cu care apelez make backgorund
make_background_macro macro object, drawArea, x, y
	push y
	push x
	push drawArea
	push object
	call make_background
	add esp, 16
endm

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

matrice_de_stari proc
	push ebp
	mov ebp, esp
	pusha
	
	;de aici incep sa desenez
	lea esi, matrice
	;mov byte ptr[esi+45], 1  ;;;;asa scriu in matrice!
	mov ecx, matrice_height
	mov ebx, 40	;desenez de la pozitia 40 (las margine la stanga)
	mov edi, 40 ;desenez de la pozitia 40 (las margine in sus)

bucla_stari_linii:
	push ecx 
	mov ecx, matrice_width

bucla_stari_coloane:
	cmp byte ptr[esi], 0
	je gol
	cmp byte ptr[esi], 1
	je zid
	cmp byte ptr[esi], 3
	je brick1
	cmp byte ptr[esi], 7
	je brick2
	
	make_background_macro 0, area, ebx, edi
	jmp continue

gol:
	make_background_macro 0, area, ebx, edi
	jmp continue

zid:
	make_background_macro 1, area, ebx, edi
	jmp continue

brick1:
	make_background_macro 3, area, ebx, edi
	jmp continue

brick2:
	make_background_macro 7, area, ebx, edi
	jmp continue
	
	
continue: 
	add ebx, 32
	inc esi
	dec ecx
	cmp ecx, 0
	jne bucla_stari_coloane
	pop ecx
	mov ebx, 40
	add edi, 20
	dec ecx
	cmp ecx, 0
	jne bucla_stari_linii
	popa
	mov esp, ebp
	pop ebp
	ret

matrice_de_stari endp

matrice_de_stari_macro macro

	call matrice_de_stari

endm


pozitie_minge macro
	;determin pozitia mingii cu formula minge_i * matrice_width + minge_j
	lea esi, matrice
	mov eax, minge_i
	mov ebx, matrice_width
	mul ebx
	add eax, minge_j
	add eax, esi
	mov minge_adresa, eax
endm

pozitie_paleta macro
	;determin pozitia paletei in mod asemanator cu pozitia minjii de mai sus
	lea esi, matrice
	mov eax, paleta_i
	mov ebx, matrice_width
	mul ebx
	add eax, paleta_j
	add eax, esi
	mov paleta_adresa, eax
endm

game_over macro
	;jocul s-a sfarsit, afisez mesaj (pierdut)
	matrice_de_stari_macro
	make_text_macro 'A', area, 110, 200
	make_text_macro 'I', area, 120, 200
	
	make_text_macro 'P', area, 140, 200
	make_text_macro 'I', area, 150, 200
	make_text_macro 'E', area, 160, 200
	make_text_macro 'R', area, 170, 200
	make_text_macro 'D', area, 180, 200
	make_text_macro 'U', area, 190, 200
	make_text_macro 'T', area, 200, 200
	;nu se mai continua jocul
	jmp final_draw
endm

game_won macro
	;jocul s-a sfarsit, afisez mesaj (castig)
	matrice_de_stari_macro
	make_text_macro 'A', area, 110, 200
	make_text_macro 'I', area, 120, 200
	
	make_text_macro 'C', area, 140, 200
	make_text_macro 'A', area, 150, 200
	make_text_macro 'S', area, 160, 200
	make_text_macro 'T', area, 170, 200
	make_text_macro 'I', area, 180, 200
	make_text_macro 'G', area, 190, 200
	make_text_macro 'A', area, 200, 200
	make_text_macro 'T', area, 210, 200
	jmp final_draw
endm

calcul_contor_win macro
	;am facut un macro care sa determine valoarea contor_win, astfel incat la fiecare modificare a matricei, valoarea sa se calculeze automat
	push ebp
	mov ebp, esp
	pusha
	
	lea esi, matrice	;parcurg elementele matricei de stari
	mov eax, matrice_width ;numarul de coloane
	mov ecx, matrice_height	;numarul de linii
	mul ecx
	mov ebx, eax
	
	mov edx, offset matrice
	mov ecx, 0
	xor eax, eax
bucla:
	mov al, [edx]
	
	;in eax pastrez elementul curent
	;procesare element
	cmp al, 3
	jne urm1
	inc contor_win
urm1:
	cmp al, 7
	jne urm2
	add contor_win, 2
urm2:
	
	;trec mai departe
	add edx, 1
	;verific daca trebuie sa ma opresc
	dec ebx
	cmp ebx, 0 
	jne bucla
	;am terminat parcurgerea matricei
	
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255 ;== backgorund
	push area
	call memset
	add esp, 12
	jmp afisare
	
evt_click:
	;mut paleta la stanga cand apas in buton 1
	mov eax, [ebp + arg2] 	;eax = x
	cmp eax, button1_x 
	jl next1
	cmp eax, button1_x + button_size_x ;daca nu e indeplinita conditia
	jg next1
	
	mov eax, [ebp + arg3] 	;eax = y
	cmp eax, button1_y
	jl next1
	cmp eax, button1_y + button_size_y
	jg next1
	
	;am dat dat click in buton1 => mut paleta la stanga
	mov eax, paleta_poz_x
	mov ebx, 40		;adaug marginea din stanga
	add ebx, obj_width	;primul element e zid, se blocheaza la element
	cmp eax, ebx	;ma asigur ca paleta nu depaseste inainte sa mut
	je next1
	
	sub paleta_j, 1		;modific coordonatele in matrice
	sub paleta_poz_x, obj_width		;modific coordonatele pe tabla
	; jmp evt_timer
	jmp afisare
	
	
next1:
	;mut paleta la dreapta cand apas in buton 2
	mov eax, [ebp + arg2]  ;eax = x
	cmp eax, button2_x 
	jl next2	
	cmp eax, button2_x + button_size_x ;daca nu e indeplinita conditia
	jg next2
	
	mov eax, [ebp + arg3]
	cmp eax, button2_y
	jl next2
	cmp eax, button2_y + button_size_y
	jg next2
	
	;am dat dat click in buton2 => mut paleta la dreapta
	mov ecx, paleta_poz_x
	mov eax, matrice_width
	sub eax, 4		;oastrez un loc pentru zid si alte 3 locuri pentru cele 3 "bucati" de paleta
	mov ebx, obj_width	;inmultesc cu latimea obiectelor
	mul ebx
	add eax, 40	;adaug marginea din stanga
	cmp eax, ecx	;ma asigur ca paleta nu depaseste inainte sa mut
	je next2
	
	add paleta_j, 1		;modific coordonatele in matrice
	add paleta_poz_x, obj_width		;modific coordonatele pe tabla
	; jmp evt_timer
	jmp afisare
	
next2:
	jmp afisare
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
evt_timer:
	inc counter
	
	lea esi, matrice
	
	;verific conditia de game over si stabilesc daca jocul continua
	cmp ok_game_over, 1
	je cont0
	game_over

cont0:	
	
	;verific conditia de game won si stabilesc daca jocul continua
	cmp contor_win, 0
	jne cont0_1
	game_won
	
cont0_1:
	;se deplaseaza mingea in sus?
	cmp diry, 0
	jne cont1
	
	;se loveste mingea de ceva?
	pozitie_minge
	mov eax, minge_adresa
	sub eax, matrice_width	;verific sus
	cmp byte ptr[eax], 1
	jne skip1
	mov diry, 1	;mingea trebuie sa ricoseze
	add minge_i, 1 ;modific pozitia in matrice
	add minge_poz_y, obj_height ;modific pozitia la care trebuie sa afisez pe ecran
	jmp cont1
skip1:
	cmp byte ptr[eax], 7	;bloc pe care trebuie sa il sparg de doua ori pentru a disparea
	jne skip1_0
	mov diry, 1
	add minge_i, 1
	add minge_poz_y, obj_height
	mov byte ptr[eax], 3	;pun in locul lui un bloc pe care trebuie sa il sparg o singura data
	add scor, 10 ;s-a spart un bloc, creste scorul
	sub contor_win, 1 ;sunt cu un pas mai aproape de a castiga
	jmp cont1
skip1_0:
	cmp byte ptr[eax], 3
	jne skip1_1
	mov diry, 1
	add minge_i, 1
	add minge_poz_y, obj_height
	mov byte ptr[eax], 0
	add scor, 10
	sub contor_win, 1
	jmp cont1
skip1_1:
	sub minge_i, 1
	sub minge_poz_y, obj_height
cont1:
	
	cmp diry, 1
	jne cont2
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	pozitie_minge
	mov eax, minge_adresa
	add eax, matrice_width	;verific jos doar coliziunea cu block ul (nu si marginea de jos)
	cmp byte ptr[eax], 1
	jne skip2_1
	mov diry, 0
	sub minge_i, 1
	sub minge_poz_y, obj_height
	jmp cont2_1
skip2_1:
	cmp byte ptr[eax], 7
	jne skip2_0
	mov diry, 0
	sub minge_i, 1
	sub minge_poz_y, obj_height
	mov byte ptr[eax], 3
	add scor, 10
	sub contor_win, 1
	jmp cont2_1
skip2_0:
	cmp byte ptr[eax], 3
	jne cont2_1
	mov diry, 0
	sub minge_i, 1
	sub minge_poz_y, obj_height
	mov byte ptr[eax], 0
	add scor, 10
	sub contor_win, 1
	jmp cont2_1
cont2_1:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;coliziune cu paleta => ricoseaza
	pozitie_minge
	pozitie_paleta
	mov ebx, paleta_adresa
	mov eax, minge_adresa
	add eax, matrice_width	;verific jos
	cmp eax, ebx	;mingea pica pe partea din stanga a paletei
	jne skip2_1_2
	mov diry, 0
	mov dirx, 0		;ricoseaza spre stanga, indiferent de unde vine
	sub minge_i, 1
	sub minge_poz_y, obj_height
	jmp cont2
skip2_1_2:

	add ebx, 1	;trec la urmatoarea "bucata" de paleta
	cmp eax, ebx	;mingea pica pe partea din mijloc a paletei
	jne skip2_2_1 
	mov diry, 0		;ricoseaza spre partea din care vine
	sub minge_i, 1
	sub minge_poz_y, obj_height
	jmp cont2
skip2_2_1:
	add ebx, 1	;trec la ultima "bucata" din paleta
	cmp eax, ebx	;mingea pica pe partea din dreapta a paletei
	jne skip2_2
	mov diry, 0
	mov dirx, 1		;ricoseaza spre dreapta, indiferent de unde vine
	sub minge_i, 1
	sub minge_poz_y, obj_height
	jmp cont2
skip2_2:
	add minge_i, 1
	add minge_poz_y, obj_height
	;am grija ca mingea sa nu ajunga mai jos decat paleta
	mov eax, minge_i
	mov ebx, paleta_i
	cmp eax, ebx
	jle cont2
	;sfarsit de joc
	mov ok_game_over, 0 ;semnalez ca s-a incheiat jocul
	game_over
cont2:
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	cmp dirx, 0
	jne cont3
	
	pozitie_minge
	mov eax, minge_adresa
	sub eax, 1	;verific stanga
	cmp byte ptr[eax], 1
	jne skip3
	mov dirx, 1
	add minge_j, 1
	add minge_poz_x, obj_width
	jmp cont3
skip3:
	cmp byte ptr[eax], 7
	jne skip3_0
	mov dirx, 1
	add minge_j, 1
	add minge_poz_x, obj_width
	mov byte ptr[eax], 3
	add scor, 10
	sub contor_win, 1
	jmp cont3
skip3_0:
	cmp byte ptr[eax], 3
	jne skip3_1
	mov dirx, 1
	add minge_j, 1
	add minge_poz_x, obj_width
	mov byte ptr[eax], 0
	add scor, 10
	sub contor_win, 1
	jmp cont3
skip3_1:
	sub minge_j, 1
	sub minge_poz_x, obj_width
cont3:

	cmp dirx, 1
	jne cont4
	
	pozitie_minge
	mov eax, minge_adresa
	add eax, 1	;verific dreapta
	cmp byte ptr[eax], 1
	jne skip4
	mov dirx, 0
	sub minge_j, 1
	sub minge_poz_x, obj_width
	jmp cont4
skip4:
	cmp byte ptr[eax], 7
	jne skip4_0
	mov dirx, 0
	sub minge_j, 1
	sub minge_poz_x, obj_width
	mov byte ptr[eax], 3
	add scor, 10
	sub contor_win, 1
	jmp cont4
skip4_0:
	cmp byte ptr[eax], 3
	jne skip4_1
	mov dirx, 0
	sub minge_j, 1
	sub minge_poz_x, obj_width
	mov byte ptr[eax], 0
	add scor, 10
	sub contor_win, 1
	jmp cont4
skip4_1:
	add minge_j, 1
	add minge_poz_x, obj_width
cont4:
	
	
	
	
afisare:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	
	;afisam valoarea scorului curent (sute, zeci si unitati)
	make_text_macro 'S', area, 150, 10
	make_text_macro 'C', area, 160, 10
	make_text_macro 'O', area, 170, 10
	make_text_macro 'R', area, 180, 10
	
	
	mov ebx, 10
	mov eax, scor
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 220, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 210, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 200, 10
	
	
	;afisare buton stanga
	make_background_macro 6, area, button1_x, button1_y
	;afisare buton dreapta
	make_background_macro 5, area, button2_x, button2_y
	

afisare_contur:
	matrice_de_stari_macro  

	
	make_background_macro 2, area, minge_poz_x, minge_poz_y

	;afisez o "bucata" de paleta de 3 ori, la 3 pozitii consecutive
	make_background_macro 4, area, paleta_poz_x, paleta_poz_y
	mov eax, paleta_poz_x
	add eax, obj_width
	make_background_macro 4, area, eax, paleta_poz_y
	add eax, obj_width
	make_background_macro 4, area, eax, paleta_poz_y
	
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	calcul_contor_win
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
