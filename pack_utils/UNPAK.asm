;==============================================================================
;  UNPACK ARCHIVE 2.0  -  RUMSOFT archive extractor for the SAM Coupe
;------------------------------------------------------------------------------
;  File:         "UNPAK .BIN"  (2154 bytes; note the space in the file name)
;  Load address: &4100
;  Entry:        &4100 -> JP &414D   (a 2nd vector JP &484E follows)
;  Author:       Marian Krivos (RUMSOFT), 1993
;  STATUS: first pass - identification, UI and text identified; byte-exact
;          (reassembles to the original). See UNPAK.md.
;
;  ROLE: the inverse of ARCHIV.BIN - reads an archive produced by DISK ARCHIVE,
;  lets you pick files and writes them back out (decompressing shrink/implode,
;  i.e. the inverse of TURBO IMPLODER - see IMPLO1.md).
;
;  Menu (per arch-pack_utils_info.txt):
;    F1 SAVE  - save selected files from the archive
;    F2 EXIT
;    F3 ALL   - select all      F4 NONE - unselect all
;    F5 INVERSE - invert selection
;
;  Text is printed inline: CALL print_inline (&45A4) + string + &FF
;  (control codes such as &16 row col may be embedded), as in ARCHIV.
;
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC
;==============================================================================

	org	04100h
print_inline:	equ 0x45a4

	jp hdr_end		; entry -> &414D
	jp l484eh		; secondary vector

hdr_start:
	defb 064h
	defb 064h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
hdr_end:
main:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
l418ah:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
l41abh:
	nop
	nop
	nop
	nop
	nop
sub_41b0h:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
sub_41f5h:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
sub_4215h:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld (l41abh),sp
	call sub_4433h
	call sub_4268h
	call sub_41b0h
	call sub_4466h
	call 043c3h
	ei
l4261h:
	call sub_44c0h
	bit 7,a
	jr z,l428dh
sub_4268h:
	bit 1,a
	jr nz,l42a7h
	ld hl,l418ah
	push hl
	push af
	call 04405h
	pop af
	bit 0,a
	jp nz,l469ah
	bit 4,a
	jp nz,l42cah
	bit 3,a
	jp nz,l42c1h
	bit 2,a
	jp nz,l42b6h
	pop hl
	call 043c3h
l428dh:
	halt
	ld a,027h
	out (0feh),a
	ld a,(04008h)
	bit 4,a
	jr z,l42a2h
	call 04405h
	call sub_42f5h
	call 043c3h
l42a2h:
	call 04538h
	jr l4261h
l42a7h:
	call 04405h
	ld sp,00000h
	jp 00166h
	xor a
	call 0014eh
	ld a,002h
l42b6h:
	call 00112h
	call print_inline

str_42bc_start:
	defb 016h
	defb 000h
	defb 017h
	defb 055h
	defb 04eh
l42c1h:
	defb 050h
	defb 041h
	defb 043h
	defb 04bh
	defb 020h
	defb 041h
	defb 052h
	defb 043h
	defb 048h
l42cah:
	defb 049h
	defb 056h
	defb 045h
	defb 020h
	defb 032h
	defb 02eh
	defb 030h
	defb 016h
	defb 015h
	defb 015h
	defb 046h
	defb 049h
	defb 04ch
	defb 045h
	defb 053h
	defb 020h
	defb 03ah
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 053h
	defb 045h
	defb 04ch
l42e3h:
	defb 045h
	defb 043h
	defb 054h
	defb 045h
	defb 044h
	defb 020h
	defb 03ah
	defb 020h
	defb 0ffh
str_42bc_end:
	call sub_41f5h
	call sub_4215h
	jp 0467bh
sub_42f5h:
	ld hl,01d15h
	call 045aah
	ld hl,(0400ah)
	ld h,000h
	ld a,030h
	call sub_4651h
	ld hl,02b15h
	call 045aah
	ld hl,(0400bh)
	ld h,000h
	ld a,030h
	jp sub_4651h
	xor a
	call 00112h
	call print_inline

str_431c_start:
	defb 016h
	defb 001h
	defb 000h
	defb 014h
	defb 001h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 046h
	defb 031h
	defb 02dh
	defb 053h
	defb 041h
	defb 056h
	defb 045h
	defb 020h
	defb 020h
	defb 020h
	defb 046h
	defb 032h
	defb 02dh
	defb 045h
	defb 058h
	defb 049h
	defb 054h
	defb 020h
	defb 020h
	defb 020h
	defb 046h
	defb 033h
	defb 02dh
	defb 041h
	defb 04ch
	defb 04ch
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 046h
	defb 034h
	defb 02dh
sub_4348h:
	defb 04eh
	defb 04fh
	defb 04eh
	defb 045h
	defb 020h
	defb 020h
	defb 020h
	defb 046h
	defb 035h
	defb 02dh
	defb 049h
	defb 04eh
	defb 056h
	defb 045h
sub_4356h:
	defb 052h
l4357h:
	defb 053h
	defb 045h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 014h
	defb 000h
	defb 0ffh
str_431c_end:
	ld a,002h
	jp 00112h
	xor a
	ld (0400ah),a
	inc a
	ld hl,08000h
	ld ix,0400dh
sub_4374h:
	ld iy,0400ah
l4378h:
	out (0fbh),a
	ld a,(hl)
	cp 0ffh
	ret z
	in a,(0fbh)
	ld (ix+000h),a
	ld (ix+001h),l
	ld (ix+002h),h
	ld (ix+003h),000h
l438dh:
	inc ix
	inc ix
	inc ix
	inc ix
	ld de,00022h
	add hl,de
	ld c,(hl)
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	push de
	ld de,0000ch
	add hl,de
	pop de
	res 7,d
	add hl,de
	bit 6,h
	res 6,h
	jr z,l43aeh
	scf
l43aeh:
	adc a,c
	and 01fh
	inc (iy+000h)
	jr l4378h
	ld a,(0400ah)
	ld (0400bh),a
	ld hl,0ff3eh
	jr l43d8h
	xor a
	ld (0400bh),a
	ld hl,0003eh
	jr l43d8h
	ld a,(0400bh)
	ld b,a
	ld a,(0400ah)
	sub b
	ld (0400bh),a
	ld hl,0ffeeh
l43d8h:
	ld a,(0400ah)
	ld b,a
	ld (l42e3h),hl
	ld hl,04010h
l43e2h:
	ld a,(hl)
	ld a,0ffh
	ld (hl),a
	inc hl
	inc hl
	inc hl
	inc hl
	djnz l43e2h
	call 045bch
	call sub_41f5h
	jp sub_4466h
	ld hl,(04006h)
	ld de,00034h
	ld h,000h
	call 043aah
	push hl
	ld a,(04007h)
	sub 018h
	sra a
	sra a
	sra a
	and 01fh
	ld d,000h
	ld e,a
	pop hl
	ld h,000h
	ld c,e
	ld b,l
	ld (l4357h),bc
	push hl
	ld hl,00005h
	call 04397h
	pop de
	add hl,de
	ld a,(0400ah)
	dec a
	cp l
	ret c
	ld a,l
	ld (0400ch),a
	call sub_4497h
	ld a,(ix+003h)
sub_4433h:
	cp 001h
	adc a,000h
	ld hl,0400bh
	add a,(hl)
	ld (hl),a
	call sub_4348h
	call sub_4356h
	call sub_41f5h
	jp 045bch
	ld a,(0400ch)
	call sub_4497h
	ld a,(ix+003h)
	cpl
	ld (ix+003h),a
	ret
	ld hl,00000h
	ld a,003h
	add a,l
	push af
	ld l,h
	ld h,000h
	ld de,0000dh
	call 04397h
sub_4466h:
	ld h,l
	pop af
	ld l,a
	call 045aah
	ld a,(0400ch)
	ld b,a
	call sub_45deh
	ret
	push af
	push bc
	ld a,(05cb4h)
	dec a
	ld b,a
	in a,(0fbh)
	and 01fh
	cp b
	jr z,l448ah
	in a,(0fbh)
	ld (l438dh+1),a
	ld a,b
	out (0fbh),a
l448ah:
	pop bc
	pop af
	ret
	ld a,000h
	out (0fbh),a
	ret
	ld a,020h
	jp l4598h
sub_4497h:
	push bc
	ld b,010h
	ld a,h
	ld c,l
	ld hl,00000h
l449fh:
	add hl,hl
	rl c
	rla
	jr nc,l44a6h
	add hl,de
l44a6h:
	djnz l449fh
	pop bc
	ret
	ld b,010h
	ld a,h
	ld c,l
	ld hl,00000h
l44b1h:
	sla c
	set 0,c
	rla
	adc hl,hl
	sbc hl,de
	jr nc,l44beh
	add hl,de
	dec c
l44beh:
	djnz l44b1h
sub_44c0h:
	ld h,a
	ld l,c
	ret
	call sub_4374h
	push ix
	push iy
	ld ix,05490h
	ld iy,05000h
	exx
sub_44d3h:
	ld hl,05510h
	exx
	ld hl,(04006h)
	scf
	rr h
	rr l
	ld de,00078h
	ld b,010h
l44e4h:
	push bc
	ld b,008h
l44e7h:
	ld a,(hl)
	ld (iy+000h),a
	and (ix+000h)
	exx
	or (hl)
	inc hl
	exx
	ld (hl),a
	inc hl
	inc ix
sub_44f6h:
	inc iy
	djnz l44e7h
	add hl,de
	pop bc
	djnz l44e4h
	pop iy
	pop ix
	jp l438dh
	call sub_4374h
	ld hl,05000h
	ld de,(04006h)
	scf
	rr d
	rr e
	ld b,010h
l4516h:
	push bc
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ld bc,00078h
	ex de,hl
	add hl,bc
	ex de,hl
	pop bc
	djnz l4516h
	jp l438dh
	di
	ld a,002h
	ld (05a35h),a
	call 00112h
	ld hl,00808h
	ld (05a36h),hl
	ld hl,000ffh
	ld (05a48h),hl
	ld (05a30h),hl
	ld a,027h
	out (0feh),a
	ld hl,01615h
	ld (05a3eh),hl
	ld a,017h
	ld (05a3bh),a
	ld l,04ch
sub_455ch:
	ld h,043h
	ld (05a01h),hl
	xor a
	ld (0400bh),a
	ret
	ld a,(0400ah)
	and a
	ret z
sub_456bh:
	ld c,a
	ld hl,00003h
	call 045aah
	ld b,000h
l4574h:
	call sub_45deh
	ret z
	call sub_45deh
	ret z
	call sub_45deh
	ret z
	call sub_45deh
	ret z
	call sub_45deh
	ld a,008h
sub_4589h:
	call l4598h
	call l4598h
	ld a,00dh
	call l4598h
	ret z
	jr l4574h
	ld l,a
l4598h:
	ld h,000h
	add hl,hl
	add hl,hl
	ld de,0400dh
	add hl,de
	push hl
	pop ix
	ld a,(ix+000h)
	ld l,(ix+001h)
	ld h,(ix+002h)
	out (0fbh),a
	push hl
	ld de,04b00h
sub_45b2h:
	ld bc,00030h
	ldir
	ld a,001h
	out (0fbh),a
	ld hl,04b00h
	pop de
	ret
	call sub_44d3h
	ret nz
	call l4516h
	ld (04008h),a
	and a
	ret nz
	call sub_44f6h
	ld (04008h),a
	ret
	ld bc,0fef9h
	in e,(c)
	ld b,0fdh
	in d,(c)
	ld a,e
	rra
sub_45deh:
	rra
	rra
	rra
	rra
	xor 007h
	and 007h
	ld e,a
	ld a,d
	rra
	rra
	xor 038h
	and 038h
	or e
	ld (04009h),a
	ret z
	or 080h
	ret
	ld a,0ffh
	in a,(0feh)
	and 01eh
	ld bc,0bffeh
	in b,(c)
	ld c,a
	ld a,001h
	and b
	or c
	and 007h
	bit 3,c
	jr z,l460eh
	set 4,a
l460eh:
	bit 4,c
	jr z,l4614h
	set 3,a
l4614h:
	jr l461bh
	ld bc,0effeh
	in a,(c)
l461bh:
	xor 01fh
	ld e,a
	rra
	rra
	rra
	and 003h
	bit 0,e
	jr z,l4629h
	or 010h
l4629h:
	bit 1,e
	jr z,l462fh
	or 008h
l462fh:
	bit 2,e
	jr z,l4635h
	or 004h
l4635h:
	and 01fh
	ret
	ld a,(04008h)
	and 00fh
	ret z
	call 04405h
	ld a,(04008h)
	ld e,a
	rr e
	call c,0457ah
	rr e
	call c,sub_4589h
	rr e
sub_4651h:
	call c,sub_455ch
sub_4654h:
	rr e
	call c,sub_456bh
	jp 043c3h
	ld a,(04007h)
	inc a
	inc a
	cp 0b1h
	jr c,l4667h
	dec a
	dec a
l4667h:
	ld (04007h),a
	ret
	ld a,(04007h)
	dec a
	dec a
	cp 016h
	jr nz,l4676h
	inc a
	inc a
l4676h:
	ld (04007h),a
	ret
	ld a,(04006h)
	inc a
	inc a
	cp 0f1h
	jr c,l4685h
	dec a
	dec a
l4685h:
	ld (04006h),a
	ret
	ld a,(04006h)
	dec a
	dec a
	cp 0feh
	jr nz,l4694h
	inc a
	inc a
l4694h:
	ld (04006h),a
	ret
	push af
	push bc
l469ah:
	push de
	push hl
	call 00010h
	pop hl
	pop de
	pop bc
	pop af
	ret
	ex (sp),hl
	call sub_45b2h
	ex (sp),hl
	ret
	ld a,016h
	rst 10h
	ld a,l
	rst 10h
	ld a,h
	rst 10h
	ret
l46b2h:
	ld a,(hl)
	cp 0ffh
	ret z
	call l4598h
	inc hl
	jr l46b2h
	ld e,080h
	ld a,027h
	di
l46c1h:
	ld b,e
	out (0feh),a
l46c4h:
	djnz l46c4h
	xor 018h
	dec c
	jr nz,l46c1h
	srl e
	jr nc,l46c1h
	ei
	ret
	ld b,00ah
l46d3h:
	ld a,(hl)
	call l4598h
	inc hl
	djnz l46d3h
	ret
	push bc
	jr l46e3h
	ld a,b
	push bc
	call sub_4497h
l46e3h:
	ld a,(ix+003h)
	ld (l461bh),a
	push hl
	ld a,(hl)
	and 01fh
	inc hl
	cp 010h
	ld b,042h
	jr z,l4714h
	cp 011h
	ld b,04eh
	jr z,l4714h
	ld b,024h
	cp 012h
	jr z,l4714h
	ld b,043h
	cp 013h
	jr z,l4714h
	ld b,053h
	cp 014h
	jr z,l4714h
	ld b,044h
	cp 015h
	jr z,l4714h
	ld b,03fh
l4714h:
	push bc
	ld a,014h
	call l4598h
	ld a,000h
	and 001h
	call l4598h
	call 045d1h
	ld a,014h
	call l4598h
	xor a
	call l4598h
	ld a,02eh
	call l4598h
	pop af
	call l4598h
	ld a,009h
	call l4598h
	pop hl
	pop bc
	inc b
	dec c
	ret
l4740h:
	ld de,0000ah
	call sub_4654h
	ld a,l
	add a,030h
	call l4598h
	call 04392h
	pop hl
	ret
	push hl
	jr l4740h
	ld bc,00000h
	push af
	ld a,b
	ld b,000h
	and a
l475ch:
	sbc hl,de
	sbc a,c
	jr c,l4764h
	inc b
	jr l475ch
l4764h:
	add hl,de
	adc a,c
	ld c,a
	ld a,b
	ld b,c
	and a
	jr nz,l4772h
sub_476ch:
	pop de
	add a,d
	ret z
	jp l4598h
l4772h:
	add a,030h
	call l4598h
	pop de
	ld a,030h
	ret
	ld de,00068h
	ld hl,0fffch
	ld b,097h
	ld c,004h
l4785h:
	push de
	push bc
	add hl,de
	push hl
	call 00139h
	pop hl
	push hl
	ld b,018h
	call 0013fh
	pop hl
	pop bc
	pop de
	dec c
	jr nz,l4785h
	ret
	ld de,l47a8h
	ld a,(0400bh)
	and a
	ret z
	ld bc,0003eh
l47a5h:
	call 00013h
l47a8h:
	ld hl,000c8h
	ld de,0012ch
	call 0016fh
	call 00166h
	ld hl,05c3bh
l47b7h:
	bit 5,(hl)
	jr z,l47b7h
	rst 8
	and h
	ld bc,(04009h)
	ld iy,0400dh
l47c5h:
	push iy
	push bc
	ld a,(iy+000h)
	ld l,(iy+001h)
	ld h,(iy+002h)
	out (0fbh),a
	ld a,(iy+003h)
	cp 0ffh
	jr nz,l47e8h
	ld a,(iy+000h)
	ld de,04b00h
	ld bc,00030h
	ldir
	call 046fbh
l47e8h:
	pop bc
	pop iy
	inc iy
	inc iy
	inc iy
	inc iy
	djnz l47c5h
	call sub_41b0h
	jp sub_4466h
	bit 6,h
	res 6,h
	in a,(0fbh)
	jr z,l4806h
	inc a
	out (0fbh),a
l4806h:
	ld de,(04b1fh)
	ld (l47a5h),de
	ld de,(04b20h)
	ld (l47a5h+1),de
	ld (04b1fh),a
	ld (04b20h),hl
	ld ix,04b00h
	rst 8
	add a,h
	ld a,(04b00h)
	and 01fh
	cp 013h
	ret nz
	jr l4838h
	xor a
	ld bc,00a00h
l4830h:
	ld a,(de)
	xor (hl)
	inc hl
	inc de
	ret nz
	djnz l4830h
	ret
l4838h:
	ld de,00001h
	ld b,028h
l483dh:
	push de
	push bc
	call 04791h
	jr c,l486ah
	ld hl,04f01h
	ld de,04b01h
	push de
	call 0472ch
l484eh:
	pop de
	jr z,l4875h
	ld hl,05001h
	call 0472ch
	jr z,l4875h
	and a
	pop bc
	pop de
	ret c
	call sub_476ch
	djnz l483dh
	ld a,0f7h
	in a,(0f9h)
	and 020h
	jr nz,$-3
l486ah:
	rst 8
	add hl,de
	inc e
	ld a,e
	cp 00bh
	ret nz
	ld e,001h
	inc d
	ret
l4875h:
	pop bc
	inc hl
	inc hl
	ld b,(hl)
	inc hl
	ld c,(hl)
	ld bc,000deh
	add hl,bc
	ld a,(l47a5h)
	ld de,(l47a5h+1)
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	pop de
	call 0479bh
	and a
	ret
	ld a,(05a07h)
	ld hl,04f00h
	di
	rst 8
	and b
	ret
	ld a,(05a07h)
	ld hl,04f00h
	di
	rst 8
	sub l
	ret
	nop
	nop
	nop
	ld d,012h
	djnz l48cch
	jr nz,l48ceh
	jr nz,l48d0h
	jr nz,l4902h
	ld (hl),l
	ld (hl),h
	jr nz,l48fah
	ld b,l
	ld d,e
	ld d,h
	ld c,c
	ld c,(hl)
	ld b,c
	ld d,h
	ld c,c
	ld c,a
	ld c,(hl)
	jr nz,l4926h
	ld l,c
	ld (hl),e
	ld l,e
	ld d,014h
	defb 010h

credits_start:
	defb 020h
	defb 020h
	defb 02ah
	defb 020h
l48cch:
	defb 02ah
	defb 020h
l48ceh:
	defb 02ah
	defb 020h
l48d0h:
	defb 020h
	defb 020h
	defb 050h
	defb 072h
	defb 065h
	defb 073h
	defb 073h
	defb 020h
	defb 061h
	defb 020h
	defb 06bh
	defb 065h
	defb 079h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 02ah
	defb 020h
	defb 02ah
	defb 020h
	defb 02ah
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 052h
	defb 055h
	defb 04dh
	defb 053h
	defb 04fh
	defb 046h
	defb 054h
	defb 020h
	defb 041h
	defb 052h
	defb 043h
	defb 048h
	defb 049h
	defb 056h
	defb 045h
l48fah:
	defb 020h
	defb 053h
	defb 059h
	defb 053h
	defb 054h
	defb 045h
	defb 04dh
	defb 020h
l4902h:
	defb 032h
	defb 02eh
	defb 030h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 04dh
	defb 061h
	defb 072h
	defb 069h
	defb 061h
	defb 06eh
	defb 020h
	defb 04bh
	defb 052h
	defb 049h
	defb 056h
	defb 04fh
	defb 053h
	defb 020h
	defb 020h
	defb 020h
	defb 02dh
	defb 020h
	defb 020h
	defb 04eh
	defb 061h
	defb 062h
	defb 072h
	defb 065h
	defb 07ah
	defb 069h
	defb 065h
l4926h:
	defb 020h
	defb 065h
	defb 02fh
	defb 032h
	defb 020h
	defb 020h
	defb 02dh
	defb 020h
	defb 020h
	defb 030h
	defb 033h
	defb 031h
	defb 020h
	defb 030h
	defb 031h
	defb 020h
	defb 04ch
	defb 02eh
	defb 020h
	defb 04dh
	defb 069h
	defb 06bh
	defb 075h
	defb 06ch
	defb 061h
	defb 073h
	defb 020h
	defb 020h
	defb 020h
	defb 02dh
	defb 020h
	defb 020h
	defb 053h
	defb 06ch
	defb 06fh
	defb 076h
	defb 061h
	defb 06bh
	defb 069h
	defb 061h
credits_end:
	exx
	push bc
	push de
	push hl
	push ix
	push iy
	di
	call 07e2bh
	call 07f00h
	call sub_4268h
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	exx
	ei
	ret

