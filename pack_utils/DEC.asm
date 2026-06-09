;==============================================================================
;  DEC  -  standalone self-relocating depacker stub (SAM Coupe)
;------------------------------------------------------------------------------
;  File: DEC (367 bytes).  Load address: &8000.  STATUS: first pass, byte-exact.
;
;  This is LIB's runtime DECompressor (S. Grodkowski / SAPOSOFT), the inverse of
;  the COMPRES engine. "Lib v21.bas" prepends these 367 bytes to each compressed
;  file (MEM$ &77000 TO …+366) and patches &77057/&77058 (see LIB.md). It is
;  position-independent:
;    1. &8000.. relocator: uses the CALL/POP HL trick to find its own run-time
;       address, then LDIRs the decode body (file offset 0x40, 303 bytes) down
;       to &4000 and JPs into it (&4003).
;    2. The decode body runs at &4000 but reads the COMPRESED input back from the
;       original &80xx region (hence the &80xx references below) and writes the
;       restored block out, paging with HMPR/LMPR (&FB/&FA).
;  Because of this relocation the static addresses below are the LOAD-time view;
;  the body executes at &4000. Not byte-identical to any other tool here.
;
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC
;==============================================================================

	org	08000h

l8000h:
	di
l8001h:
	ld a,01fh
	out (0fah),a
	ld hl,00000h
	add hl,sp
	exx
	ld sp,0400ah
	ld a,0c9h
	ld (04000h),a
	call 04000h
l8015h:
	dec sp
	dec sp
l8017h:
	pop hl
l8018h:
	ld de,0002bh
l801bh:
	add hl,de
l801ch:
	ld de,04000h
	ld bc,0012fh
	ldir
	in a,(0fbh)
	bit 7,h
	res 7,h
	jr nz,l802eh
	ld a,0ffh
l802eh:
	bit 6,h
	res 6,h
	jr z,l8035h
	inc a
l8035h:
	ld (04000h),a
	ld (04001h),hl
	exx
	ld sp,hl
	jp 04003h
	inc bc
	nop
	nop
	di
sub_8044h:
	ld a,000h
	out (0fbh),a
	ld (04010h),sp
	jp l806eh
	ld sp,00000h
	ei
	ret
sub_8054h:
	nop
	nop
	nop
	rra
	rst 38h
	rra
	nop
	nop
	nop
	ld a,020h
	or b
	out (0fah),a
	ld a,(hl)
	push hl
	push af
	ld hl,l8018h+2
	call 0805eh
	ld a,(l8018h+2)
l806eh:
	ld h,a
	ld a,(l801bh)
	or h
	ld h,a
	ld a,(l801ch)
	or h
	jr z,l807dh
	pop af
	pop hl
	ret
l807dh:
	ld a,01fh
	out (0fah),a
	jp 0400fh
	push af
	ld a,020h
	or b
	out (0fah),a
	pop af
	ld (hl),a
	push bc
	ld bc,000f8h
	out (c),a
	pop bc
	ret
	dec hl
	bit 7,h
	ret z
	res 6,h
	res 7,h
	dec b
	ret
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
	ld hl,04000h
	add hl,sp
	ld sp,hl
	ld a,(l8000h)
	or 020h
	out (0fah),a
	ld hl,(l8001h)
	ld a,(hl)
	ld (080e9h),a
	inc hl
	ld a,(hl)
	ld e,a
	ld (l8018h+2),a
	inc hl
	ld a,(hl)
	ld d,a
	ld (l801bh),a
	inc hl
	ld a,(hl)
	ld (l801ch),a
	add a,a
	add a,a
	ld b,a
	ld a,d
	and 0c0h
	rlca
	rlca
	add a,b
	ld b,a
	ld a,(l8000h)
	add a,b
	ld (08014h),a
	ld a,d
	and 03fh
	ld d,a
	ld hl,(l8001h)
	inc hl
	inc hl
	inc hl
	inc hl
	add hl,de
	bit 6,h
	res 6,h
	ld (l8015h),hl
	jr z,l80ffh
	ld a,(08014h)
	inc a
	ld (08014h),a
l80ffh:
	ld hl,(l8018h+2)
	ld de,00003h
	add hl,de
	ld (l8018h+2),hl
	jr nc,l8112h
l810bh:
	ld a,(l801ch)
	inc a
	ld (l801ch),a
l8112h:
	ld a,(08014h)
	ld b,a
	ld hl,(l8015h)
	call l801ch+1
	call sub_8054h
	ld (l8015h),hl
	ex af,af'
	ld a,b
	ld (08014h),a
	ex af,af'
	cp 000h
	jr nz,l815eh
	call l801ch+1
	ld d,a
	call sub_8054h
	call l801ch+1
	ld (l810bh),a
	call sub_8054h
	ld (l8015h),hl
	ld a,b
	ld (08014h),a
	ld a,(l8017h)
	ld b,a
	ld hl,(l8018h)
l814ah:
	ld a,000h
	call sub_8044h
	call sub_8054h
	dec d
	jr nz,l814ah
l8155h:
	ld a,b
	ld (l8017h),a
	ld (l8018h),hl
	jr l8112h
l815eh:
	ex af,af'
	ld a,(l8017h)
	ld b,a
	ld hl,(l8018h)
	ex af,af'
	call sub_8044h
	call sub_8054h
	jr l8155h

