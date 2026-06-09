;==============================================================================
;  COMPRES  -  compressor engine (SAM Coupe)
;------------------------------------------------------------------------------
;  File: COMPRES (1834 bytes).  Load address: &A000.  STATUS: first pass, byte-exact.
;
;  LIB's compressor engine (S. Grodkowski / SAPOSOFT) - driven by "Lib v21.bas"
;  PROC compr (POKEs params at &A00D, USR &76000=&A000). See LIB.md.
;  NOT byte-identical to RUMSOFT's TURBO IMPLODER. Flow:
;    &A000 di; save SP + VMPR; JP &A023
;    &A023 ld sp,&FFFF; CALL &A550 (main); JR &A016 (exit: restore VMPR/LMPR, RET)
;  The core &A550 reads parameters from the &A00D block (start/length/...), then
;  loops: read source byte (&A02B, paged), track runs/tokens, and write a
;  bit/byte stream via the emitters &A056 / &A032 / &A06E. It is a different,
;  table-driven token scheme than the IMPLODER's shrink/implode (no CPIR window
;  search) - i.e. a distinct compression engine, not a relocated copy.
;
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC
;==============================================================================

	org	0a000h

	di			; save state, then JP &A023 (main), JR &A016 = exit
	ld (la016h+1),sp
	in a,(0fch)
	ld (0a01ah),a
	jp la023h
la00dh:
	rra
la00eh:
	rst 38h
	rra
	inc d
	rst 38h
	ccf
la013h:
	nop
	jr nz,la016h
la016h:
	ld sp,00000h
	ld a,000h
	out (0fch),a
	ld a,01fh
	out (0fah),a
	ei
	ret
la023h:
	ld sp,0ffffh
	call sub_a550h
	jr la016h
sub_a02bh:
	ld a,020h
	or b
	out (0fah),a
	ld a,(hl)
	ret
sub_a032h:
	push af
	ld a,020h
	or b
	out (0fah),a
	pop af
	ld (hl),a
	push hl
	push af
	ld hl,0a47eh
	call sub_a060h
	pop af
	pop hl
	ret
sub_a045h:
	push af
	ld a,020h
	or b
	out (0fah),a
	pop af
	ld (hl),a
	ret
	inc hl
	bit 6,h
	ret z
	res 6,h
	inc b
	ret
sub_a056h:
	dec hl
	bit 7,h
	ret z
	res 6,h
	res 7,h
	dec b
	ret
sub_a060h:
	ld a,(hl)
	inc a
	ld (hl),a
	ret nz
	inc hl
	ld a,(hl)
	inc a
	ld (hl),a
	ret nz
	inc hl
	ld a,(hl)
	inc a
	ld (hl),a
	ret
sub_a06eh:
	ld a,(hl)
	dec a
	ld (hl),a
	inc a
	ret nz
	inc hl
	ld a,(hl)
	dec a
	ld (hl),a
	inc a
	ret nz
	inc hl
	ld a,(hl)
	dec a
	ld (hl),a
	ret
la07eh:
	ei
la07fh:
	jr z,la08ch
	call 0f71ah
	call 0f45ah
	call 0f112h
	jr la08fh
la08ch:
	call 0e727h
la08fh:
	xor a
la090h:
	call 0e0a1h
	ld hl,05c3bh
	ld b,007h
la098h:
	bit 5,(hl)
	jr nz,la0b5h
	halt
	djnz la098h
	jr la090h
	ld hl,(0f8adh)
	ld bc,00380h
	add hl,bc
	ex af,af'
	ld a,(hl)
	xor 03fh
	ld (hl),a
	inc l
	ld a,(hl)
	xor 0fch
	ld (hl),a
	ex af,af'
	cpl
	ret
la0b5h:
	res 5,(hl)
	and a
	call nz,0e0a1h
	ld hl,000c8h
	ld de,00005h
	call 0016fh
	ld a,(05c08h)
	ld hl,0e08fh
	push hl
	ld (0f8c7h),sp
	ld hl,(0f8adh)
	cp 020h
	jp c,0e289h
	cp 080h
	jr c,la0f9h
	cp 0c8h
	jr nz,la0e3h
	ld a,028h
	jr la0f9h
la0e3h:
	cp 0c9h
	jr nz,la0ebh
	ld a,029h
	jr la0f9h
la0ebh:
	cp 0c5h
	jr nz,la0f3h
	ld a,025h
	jr la0f9h
la0f3h:
	cp 0c6h
	jr nz,la0fch
	ld a,026h
la0f9h:
	jp 0e6b9h
la0fch:
	cp 0fdh
	jr nz,la117h
	ld (0f8afh),a
	ex de,hl
	ld l,e
	srl l
	ld h,0f9h
	ld c,(hl)
	ld a,020h
la10ch:
	ld (hl),a
	inc l
	bit 6,l
	jp nz,0e6a6h
	ld a,c
	ld c,(hl)
	jr la10ch
la117h:
	cp 0fch
	jr nz,la12bh
	ld a,l
	cp 07eh
	ret z
	ld hl,0f8d7h
la122h:
	inc hl
	cp (hl)
	jr nc,la122h
	ld a,(hl)
la127h:
	ld (0f8adh),a
	ret
la12bh:
	cp 0fah
	jr nz,la148h
	call 0e39fh
	ld c,a
	ld hl,0f8ddh
la136h:
	ld a,(hl)
	dec hl
	cp c
	jr nc,la136h
	and a
	jr nz,la127h
	ld a,(0f893h)
	and a
	jr z,la127h
	ld a,002h
	jr la127h
la148h:
	call 0e396h
	cp 0a8h
	jr nz,la15eh
	ld a,l
	ld (0f892h),a
	call 0e2f2h
	ld a,0ffh
	ld (0f893h),a
	jp 0e336h
la15eh:
	cp 0fbh
	jr nz,la1a2h
	call 0e5bah
	call 0e3c2h
	ld d,h
	ld e,l
	ld bc,00400h
	add hl,bc
	ld c,e
	ld a,0dch
	sub d
	ld b,a
	call nz,0e819h
	ld a,(0f8aeh)
	and 07ch
	rrca
	rrca
	cpl
	add a,018h
	jr z,la19fh
	ld b,a
	call 0e77bh
	push af
	push hl
la188h:
	push bc
	call 0e798h
	pop bc
	jr c,la191h
	djnz la188h
la191h:
	call 0e571h
	pop hl
	pop af
	call 0e7cah
	ld hl,0dc00h
	call 0e6a9h
la19fh:
	jp 0e300h
la1a2h:
	cp 0c3h
	jr nz,la1cah
	call 0e2f2h
	ld hl,0f4b7h
la1ach:
	call 0e5ceh
	jp c,0eca6h
	call 0e3c2h
	ld a,0dch
	sub h
	ld b,a
	ld c,l
	ld hl,0dbffh
	ld de,0dfffh
	call nz,0e91dh
	call 0e300h
	xor a
	jp 0e127h
la1cah:
	cp 0c2h
	jr nz,la1d6h
	call 0e2f2h
	ld hl,0f4b9h
	jr la1ach
la1d6h:
	cp 0c7h
	jr nz,la1e9h
	call 0e2f2h
	ld a,(0f895h)
	ld hl,(0f896h)
	call 0e774h
la1e6h:
	jp 0e727h
la1e9h:
	cp 0c4h
	jr nz,la1f5h
	call 0e2f2h
la1f0h:
	call 0e782h
	jr la1e6h
la1f5h:
	cp 0c1h
	jr nz,la201h
	call 0e2f2h
	call 0e75dh
	jr la1e6h
la201h:
	cp 0c0h
	jr nz,la213h
	call 0e2f2h
	ld a,(0f898h)
	ld hl,(0f899h)
	call 0e774h
	jr la1f0h
la213h:
	cp 0a5h
	jr nz,la21fh
	ld a,(0f894h)
	cpl
	ld (0f894h),a
	ret
la21fh:
	cp 0a4h
	jr nz,la22ah
	call 0e2f2h
	xor a
	jp 0ef6fh
la22ah:
	cp 082h
	jr nz,la23dh
	ld de,0f4c7h
la231h:
	ld a,(de)
	push de
	call 0e6b9h
	pop de
	inc de
	ld a,(de)
	rla
	jr nc,la231h
	ret
la23dh:
	cp 094h
	ret nz
	call 0e2f2h
	ld a,(0f89bh)
	call 0ea21h
	ld hl,(0f89ch)
	call 0e7cah
	ld a,(hl)
	and a
	jr z,la275h
	set 7,(hl)
la255h:
	call 0e7a9h
	jr c,la27bh
la25ah:
	bit 7,(hl)
	jr z,la255h
	ld c,a
	ld a,(0f89bh)
	cp c
	jr nz,la26bh
	ld de,(0f89ch)
	sbc hl,de
la26bh:
	call 0e77bh
	jr z,la272h
	res 7,(hl)
la272h:
	call 0e774h
la275h:
	call 0ea35h
	jp 0e727h
la27bh:
	ld a,(0f895h)
	ld hl,(0f896h)
	ld b,a
	or 020h
	call 0e7c7h
	jr la25ah
	cp 00eh
	jr nz,la2a5h
	ld (0f8afh),a
	ex de,hl
	ld l,e
	srl l
	ld h,0f9h
la296h:
	inc hl
	ld a,(hl)
	bit 6,l
	dec hl
	jr nz,la2a1h
	ld (hl),a
	inc hl
	jr la296h
la2a1h:
	ld (hl),020h
	jr la303h
la2a5h:
	cp 00dh
	jr nz,la306h
	ld a,(0f893h)
	and a
	jp nz,0ebech
	ld (0f8adh),a
	call 0e2f2h
	ld a,(0f894h)
	and a
	jr z,la2c3h
	call 0e2c3h
	ret c
	jp 0e1a9h
la2c3h:
	call 0e798h
	ret c
	ld a,(0f8aeh)
	add a,004h
	cp 0e0h
	jr c,la2edh
	ld de,08000h
	ld hl,08400h
	ld bc,05c00h
	call 0e819h
	call 0e77bh
	push af
	push hl
	ld b,017h
	call 0e78dh
	pop hl
	pop af
	call 0e7cah
	ld a,0dch
la2edh:
	ld (0f8aeh),a
	jr la300h
	ld a,(0f8afh)
	and a
	ret z
	call 0e3e8h
	call 0e57fh
	jp c,0eca6h
la300h:
	call 0e571h
la303h:
	jp 0e6a6h
la306h:
	cp 00ch
	jr nz,la316h
	call 0e39fh
	dec l
	dec l
	ld a,020h
	call 0e6b9h
	jr la327h
la316h:
	cp 009h
	jr nz,la323h
	ld a,l
	cp 07eh
	ret nc
	add a,002h
	jp 0e127h
la323h:
	cp 008h
	jr nz,la32fh
la327h:
	call 0e39fh
	sub 002h
	jp 0e127h
la32fh:
	cp 007h
	jr nz,la34dh
	ld (0f8afh),a
	call 0e3c8h
	call 0e6a6h
	xor a
	call 0e127h
	ld a,(0f893h)
	and a
	ret z
	ld hl,(0f8adh)
	ld a,03eh
	jp 0e6b9h
la34dh:
	cp 006h
	jr nz,la35ah
	ld a,(05c6ah)
	xor 008h
	ld (05c6ah),a
	ret
la35ah:
	call 0e396h
	cp 00fh
	jp z,0e300h
	cp 00bh
	jr nz,la38dh
	call 0e2f2h
	call 0e7d1h
	ret c
	ld a,(0f8aeh)
	sub 004h
	cp 080h
	jr nc,la387h
	ld hl,0dbffh
	ld de,0dfffh
	ld bc,05c00h
	call 0e91dh
	call 0e771h
	ld a,080h
la387h:
	ld (0f8aeh),a
	jp 0e300h
la38dh:
	cp 00ah
	ret nz
	call 0e2f2h
	jp 0e2c3h
	ld c,a
	ld a,(0f893h)
	and a
	ld a,c
	ret z
	pop bc
	ret
	ld a,l
	cp 003h
	ret nc
	and a
	jr z,la3ach
	ld a,(0f893h)
	and a
	ld a,l
	ret z
la3ach:
	pop hl
	ret
	ld hl,08000h
	ld (0f8adh),hl
	ld de,08001h
	ld a,e
	ld (0f8f5h),a
	ld bc,05fffh
	ld (hl),l
	jp 0e81ah
	ld hl,(0f8adh)
	ld l,000h
	ret
	ld hl,0f900h
la3cbh:
	ld (hl),020h
	inc l
	bit 6,l
	jr z,la3cbh
	ret
	ld hl,0f93fh
	ld de,0f942h
la3d9h:
	ld a,(hl)
	cp 020h
	jr nz,la3e3h
	dec l
	bit 7,l
	jr z,la3d9h
la3e3h:
	inc l
	xor a
	ld (hl),a
	ld l,a
	ret
	call 0e3d3h
	call 0ea60h
	push hl
	ld b,00fh
	ld a,(hl)
	call 0ea91h
	jr nc,la416h
	inc l
	dec b
la3f9h:
	ld a,(hl)
	call 0ea67h
	jr c,la413h
	cp 03ah
	jr nz,la416h
	ld a,00fh
	sub b
	jr z,la416h
	pop hl
	ld (de),a
	inc e
	ld b,000h
	ld c,a
	ldir
	inc l
	jr la417h
la413h:
	inc l
	djnz la3f9h
la416h:
	pop hl
la417h:
	call 0e4b2h
	push de
	ld b,080h
	ld de,0f775h
la420h:
	push hl
la421h:
	ld c,(hl)
	res 5,c
	ld a,(de)
	and 07fh
	cp c
	jr nz,la43eh
	ld a,(de)
	inc de
	inc l
	rla
	jr nc,la421h
	dec de
	ld a,(hl)
	call 0ea67h
	jr c,la43eh
	pop de
	pop de
la439h:
	ld a,b
	ld (de),a
	inc e
	jr la417h
la43eh:
	pop hl
	jr nc,la449h
la441h:
	ld a,(de)
	inc de
	rla
	jr nc,la441h
	inc b
	jr la420h
la449h:
	pop de
	ld a,(hl)
	and 0dfh
	cp 044h
	jr nz,la473h
	inc l
	ld a,(hl)
	and 0dfh
	ld b,095h
	cp 042h
	jr z,la46ah
	inc b
	cp 04dh
	jr z,la46ah
	inc b
	cp 053h
	jr z,la46ah
	inc b
	cp 057h
	jr nz,la472h
la46ah:
	inc l
	ld a,(hl)
	call 0ea67h
	jr nc,la439h
	dec l
la472h:
	dec l
la473h:
	ld a,(hl)
	ld (de),a
	inc l
	inc e
	cp 028h
	jr z,la417h
	cp 02ch
	jr z,la47fh
la47fh:
	nop
la480h:
	nop
la481h:
	nop
la482h:
	nop
	nop
la484h:
	nop
la485h:
	nop
	nop
la487h:
	nop
la488h:
	nop
	nop
la48ah:
	nop
la48bh:
	nop
la48ch:
	nop
sub_a48dh:
	ld hl,la07eh
	ld de,la07fh
	ld bc,003ffh
	ld (hl),000h
	ldir
	ld a,(la00dh)
	ld (la484h),a
	ld hl,(la00eh)
	ld (la485h),hl
	ld hl,(la013h)
	ld (la48ah),hl
	ld a,(0a015h)
	ld (la48ch),a
la4b2h:
	ld a,000h
	xor 001h
	ld (la4b2h+1),a
	out (0feh),a
	ld a,(la48ah)
	ld d,a
	ld a,(la48bh)
	or d
	ld d,a
	ld a,(la48ch)
	or d
	jr z,la4f2h
	ld hl,(la485h)
	ld a,(la484h)
	ld b,a
	call sub_a02bh
	call sub_a056h
	ld (la485h),hl
	ld h,000h
	ld l,a
	add hl,hl
	add hl,hl
	ld a,b
	ld (la484h),a
	ld de,la07eh
	add hl,de
	call sub_a060h
	ld hl,la48ah
	call sub_a06eh
	jr la4b2h
la4f2h:
	ld b,000h
	ld c,000h
	ex af,af'
	ld a,000h
	ex af,af'
	ld hl,0ffffh
	ld d,0ffh
	ld ix,la07eh
la503h:
	ld a,(ix+002h)
	cp d
	jr c,la51bh
	jr nz,la527h
	ld a,(ix+001h)
	cp h
	jr c,la51bh
	jr nz,la527h
	ld a,(ix+000h)
	cp l
	jr c,la51bh
	jr nz,la527h
la51bh:
	ex af,af'
	ld a,c
	ex af,af'
	ld l,(ix+000h)
	ld h,(ix+001h)
	ld d,(ix+002h)
la527h:
	ld a,000h
	xor 001h
	ld (la527h+1),a
	out (0feh),a
	inc ix
	inc ix
	inc ix
	inc ix
	inc c
	djnz la503h
	xor a
	out (0feh),a
	ex af,af'
	ret
sub_a540h:
	ld a,(la487h)
	ld b,a
	ld hl,(la488h)
sub_a547h:
	ld a,000h
	call sub_a032h
	call sub_a056h
	ret
sub_a550h:
	ld a,001h
	out (0feh),a
	call sub_a48dh
	ld (sub_a547h+1),a
	ld (0a5ach),a
	ld hl,la00dh
	ld de,la484h
	xor a
	ld (0a47eh),a
	ld (la47fh),a
	ld (la480h),a
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ld a,(la484h)
	ld b,a
	ld hl,(la485h)
	call sub_a02bh
	call sub_a056h
	ld (la630h+1),a
	ld a,001h
	ld (0a635h),a
	ld a,b
	ld (la484h),a
	ld (la485h),hl
	ld hl,la48ah
	call sub_a06eh
la5a1h:
	ld a,(la484h)
	ld b,a
	ld hl,(la485h)
	call sub_a02bh
	cp 000h
	jp nz,la630h
	call sub_a056h
	ld a,b
	ld (la484h),a
	ld (la485h),hl
	ld a,(la487h)
	ld b,a
	ld hl,(la488h)
	ld a,(0a635h)
	cp 001h
	jr nz,la5dah
la5c8h:
	ld a,(la630h+1)
	call sub_a032h
	call sub_a056h
	ld a,b
	ld (la487h),a
	ld (la488h),hl
	jr la5e8h
la5dah:
	call sub_a540h
	ld a,(0a635h)
	call sub_a032h
	call sub_a056h
	jr la5c8h
la5e8h:
	call sub_a540h
	ld a,001h
	call sub_a032h
	call sub_a056h
	call sub_a547h
	ld a,b
	ld (la487h),a
	ld (la488h),hl
	ld hl,la48ah
	call sub_a06eh
	xor a
	ld (0a635h),a
	ld a,(la484h)
	ld b,a
	ld hl,(la485h)
	call sub_a02bh
	ld (la630h+1),a
la614h:
	ld a,000h
	xor 002h
	ld (la614h+1),a
	out (0feh),a
	ld a,(la48ah)
	ld b,a
	ld a,(la48bh)
	or b
	ld b,a
	ld a,(la48ch)
	or b
	jp nz,la5a1h
	jp la6cdh
la630h:
	cp 000h
	jr nz,la66ah
	ld a,000h
	inc a
	ld (0a635h),a
	jr nz,la658h
	exx
	call sub_a540h
	xor a
	call sub_a032h
	call sub_a056h
	ld a,(la630h+1)
	call sub_a032h
	call sub_a056h
	ld a,b
	ld (la487h),a
	ld (la488h),hl
	exx
la658h:
	call sub_a056h
	ld a,b
	ld (la484h),a
	ld (la485h),hl
	ld hl,la48ah
	call sub_a06eh
	jr la614h
la66ah:
	push af
	ld a,(0a635h)
	or a
	jr z,la693h
	cp 003h
	jr nc,la6b6h
	ld a,(0a635h)
	ld d,a
	ld a,(la487h)
	ld b,a
	ld hl,(la488h)
	ld a,(la630h+1)
la683h:
	call sub_a032h
	call sub_a056h
	dec d
	jr nz,la683h
la68ch:
	ld a,b
	ld (la487h),a
	ld (la488h),hl
la693h:
	ld a,001h
	ld (0a635h),a
	pop af
	ld (la630h+1),a
	ld a,(la484h)
	ld b,a
	ld hl,(la485h)
	call sub_a056h
	ld a,b
	ld (la484h),a
	ld (la485h),hl
	ld hl,la48ah
	call sub_a06eh
	jp la614h
la6b6h:
	call sub_a540h
	ld a,(0a635h)
	call sub_a032h
	call sub_a056h
	ld a,(la630h+1)
	call sub_a032h
	call sub_a056h
	jr la68ch
la6cdh:
	ld a,(0a635h)
	cp 001h
	jr z,la6ebh
	call sub_a540h
	ld a,(0a635h)
	call sub_a032h
	call sub_a056h
	ld a,(la630h+1)
	call sub_a032h
	call sub_a056h
	jr la6fbh
la6ebh:
	ld a,(la487h)
	ld b,a
	ld hl,(la488h)
	ld a,(la630h+1)
	call sub_a032h
	call sub_a056h
la6fbh:
	ld a,(la480h)
	call sub_a045h
	call sub_a056h
	ld a,(la47fh)
	call sub_a045h
	call sub_a056h
	ld a,(0a47eh)
	call sub_a045h
	call sub_a056h
	ld a,(0a5ach)
	call sub_a045h
	ld a,b
	ld (la481h),a
	ld (la482h),hl
	ld bc,0a47eh
	xor a
	out (0feh),a
	ret

