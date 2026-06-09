;==============================================================================
;  DISK ARCHIVE v2.0  -  RUMSOFT disk archiver for the SAM Coupe
;------------------------------------------------------------------------------
;  File:         ARCHIV.BIN  (5900 bytes)
;  Load address: &6D00
;  Entry:        &6D00 -> JR &6D1E  (skips a small data header)
;  Author:       Marian Krivos (RUMSOFT), 1993, L. Mikulas, Slovakia
;  Signatures:   "DISK ARCHIVE  Version 2.0  Copyright 1993 RUMSOFT",
;                "RUMSOFT ARCHIVE SYSTEM 2.0 / Marian KRIVOS ... Slovakia"
;
;  Disassembled with z80dasm 1.1.6 (byte-exact: reassembles to the original).
;  STATUS: first-pass - data blocks, strings and key routines identified;
;          deep per-routine annotation is ongoing. See ARCHIV.md.
;
;  WHAT IT DOES (per arch-pack_utils_info.txt):
;    A menu-driven disk archiver with compression. Function keys:
;      F1 SCAN     - read the disk directory
;      F2 LINK     - load selected files into memory
;      F3 COMPRESS - compress the loaded files (Mode 1/2/3, Speed 0-7, Skip)
;      F4 STORE    - save the archive
;      F5 EXIT
;      F6 ALL      - select all files
;
;  STRUCTURE:
;    &6D1E  main      - save SP, CALL init, then the main loop:
;                       draw screen -> get_command -> dispatch by bit in A.
;    Command dispatch (bit set in A returned by get_command @ &7269):
;       bit0 -> &71DA   bit1 -> &7232   bit2 -> &77C5
;       bit3 -> &7016   bit5 -> &6EA9   bit4 -> &6D7A (handled inline)
;    Text output: CALL print_inline (&734D) followed by an inline string that
;    ends in &FF; the string may embed control codes (e.g. &16 = AT row,col).
;
;  MEMORY MAP (&6D00..&840B):
;    &6D00         JR &6D1E                entry
;    &6D02..&6D0E  data header
;    &6D0F..&6D1D  set_border (OUT &FE,&27)
;    &6D1E..       MAIN + command handlers + helpers (code, with inline strings)
;    &734D/&73AB   print_inline / print_str
;    &7F77..&7FFF  credits text block
;    &8000..&840B  8x8 font (8 bytes/char from ASCII space)
;
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC  border/keyboard=&FE
;==============================================================================


	org	06d00h
HMPR:	equ 0x00fb
ROM_016F:	equ 0x016f

	jr main		; entry: skip data header -> MAIN @ &6D1E

hdr_start:
	defb 064h
l6d03h:
	defb 064h
l6d04h:
	defb 000h
l6d05h:
	defb 000h
l6d06h:
	defb 000h
l6d07h:
	defb 000h
l6d08h:
	defb 000h
l6d09h:
	defb 000h
l6d0ah:
	defb 000h
l6d0bh:
	defb 000h
l6d0ch:
	defb 000h
l6d0dh:
	defb 000h
	defb 000h
hdr_end:
set_border:
	ld de,00021h
	ld b,011h
	ld h,h
	nop
	call ROM_016F
	ld a,027h
	out (0feh),a
	ret
;==============================================================================
; MAIN (&6D1E): save SP, init, then loop { draw screen; get_command; dispatch }.
; get_command (&7269) returns a bitmask in A; bit4=F5 EXIT (-> &6D7A: reset SP,
; ROM &015A). Other bits jump to the handlers f1_scan/1/2/3/5. See ARCHIV.md.
;==============================================================================
main:
	ld (06d7eh),sp
	call init
l6d25h:
	call sub_6d88h
	call sub_7201h
	call sub_710ch
	ei
l6d2fh:
	call get_command
	bit 7,a
	jr z,l6d60h
	bit 4,a
	jr nz,l6d7ah
	ld hl,l6d5dh
	push hl
	push af
	call sub_714eh
	pop af
	bit 0,a
	jp nz,f1_scan
	bit 1,a
	jp nz,f2_link
	bit 3,a
	jp nz,f4_store
	bit 2,a
	jp nz,f3_compress
	bit 5,a
	jp nz,f6_all
	pop hl
l6d5dh:
	call sub_710ch
l6d60h:
	halt
	ld a,027h
	out (0feh),a
	ld a,(l6d04h)
	bit 4,a
	jr z,l6d75h
	call sub_714eh
	call sub_6f23h
	call sub_710ch
l6d75h:
	call sub_72e1h
	jr l6d2fh
l6d7ah:
	call sub_714eh
	ld sp,00000h
	ld a,003h
	call 0015ah
	jp 00166h
sub_6d88h:
	xor a
	call 0014eh
	ld a,002h
	call 00112h
	call print_inline

str_6d94_start:
	defb 014h
	defb 001h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 044h
	defb 049h
	defb 053h
	defb 04bh
	defb 020h
	defb 041h
	defb 052h
	defb 043h
	defb 048h
	defb 049h
	defb 056h
	defb 045h
	defb 020h
	defb 020h
	defb 056h
	defb 065h
	defb 072h
	defb 073h
	defb 069h
	defb 06fh
	defb 06eh
	defb 020h
	defb 032h
	defb 02eh
	defb 030h
	defb 020h
	defb 020h
	defb 043h
	defb 06fh
	defb 070h
	defb 079h
	defb 072h
	defb 069h
	defb 067h
	defb 068h
	defb 074h
	defb 020h
	defb 031h
	defb 039h
	defb 039h
	defb 033h
	defb 020h
	defb 052h
	defb 055h
	defb 04dh
	defb 053h
	defb 04fh
	defb 046h
	defb 054h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 014h
	defb 000h
	defb 016h
	defb 015h
	defb 005h
	defb 046h
	defb 049h
	defb 04ch
	defb 045h
	defb 053h
	defb 03ah
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 053h
	defb 045h
	defb 04ch
	defb 045h
	defb 043h
	defb 054h
	defb 045h
	defb 044h
	defb 03ah
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 046h
	defb 052h
	defb 045h
	defb 045h
	defb 03ah
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 044h
	defb 049h
	defb 053h
	defb 04bh
	defb 020h
	defb 055h
	defb 053h
	defb 045h
	defb 053h
	defb 03ah
	defb 0ffh
str_6d94_end:
	call sub_6e16h
	call sub_6e55h
	jp l7cd5h
sub_6e16h:
	ld hl,00c15h
	call sub_73a3h
	ld hl,(l6d09h)
	ld h,000h
	ld a,030h
	call sub_7727h
	ld hl,01a15h
	call sub_73a3h
	ld hl,(l6d0ah)
	ld h,000h
	ld a,030h
	call sub_7727h
	ld hl,02415h
	call sub_73a3h
	ld hl,l6d0ch
	call sub_76d7h
	call sub_76e4h
	ld hl,03715h
	call sub_73a3h
	ld hl,l6d06h
	call sub_76d7h
	jp sub_76e4h
	ret
sub_6e55h:
	xor a
	call 00112h
	call print_inline

str_6e5c_start:
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
	defb 043h
	defb 041h
	defb 04eh
	defb 020h
	defb 046h
	defb 032h
	defb 02dh
	defb 04ch
	defb 049h
	defb 04eh
	defb 04bh
	defb 020h
	defb 046h
	defb 033h
	defb 02dh
	defb 043h
	defb 04fh
	defb 04dh
	defb 050h
	defb 052h
	defb 045h
	defb 053h
	defb 053h
	defb 020h
	defb 046h
	defb 034h
	defb 02dh
	defb 053h
	defb 054h
	defb 04fh
	defb 052h
	defb 045h
	defb 020h
	defb 046h
	defb 035h
	defb 02dh
	defb 045h
	defb 058h
	defb 049h
	defb 054h
	defb 020h
	defb 046h
	defb 036h
	defb 02dh
	defb 041h
	defb 04ch
	defb 04ch
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
str_6e5c_end:
	ld a,002h
	jp 00112h
f6_all:
	ld a,(hdr_end)
	bit 5,a
	jp z,hdr_end+1
	call sub_70b6h
	ld a,(06ec7h)
	and a
	call z,sub_6eech
	jp c,l70cfh
	ld hl,0f00bh
	ld b,050h
	ld de,00019h
	ld a,000h
	cpl
	ld (06ec7h),a
l6ecch:
	ld (hl),a
	add hl,de
	djnz l6ecch
	call sub_74bbh
	call sub_7201h
	call l70cfh
	ld hl,l6d0ah
	ld a,(hl)
	and a
	ld a,(l6d09h)
	ld (hl),a
	jr z,l6ee9h
	xor a
	ld (hl),a
	call sub_71b4h
l6ee9h:
	jp sub_6e16h
sub_6eech:
	ld a,(l6d09h)
	cp 001h
	ret c
	call sub_71b4h
	xor a
	ld (l6d0ah),a
	ld a,(l6d06h)
	ld c,a
	ld hl,(l6d0dh)
	ld a,(l6d0ch)
	ld de,(l6d07h)
	res 7,d
	res 7,h
	cp c
	ret c
	jr nz,l6f13h
	sbc hl,de
	add hl,de
	ret c
l6f13h:
	sbc hl,de
	sbc a,c
	call sub_6ff3h
	and a
l6f1ah:
	ld a,(hdr_end)
	or 020h
	ld (hdr_end),a
	ret
sub_6f23h:
	ld a,(hdr_end)
	bit 5,a
	jp z,hdr_end+1
	ld hl,(hdr_start)
	ld de,00034h
	ld h,000h
	call sub_70f3h
	push hl
	ld a,(l6d03h)
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
	ld (sub_6fc0h+1),bc
	push hl
	ld hl,00005h
	call sub_70e0h
	pop de
	add hl,de
	ld a,(l6d09h)
	dec a
	cp l
	ret c
	ld a,l
	ld (l6d0bh),a
	call sub_7244h
	ld a,(0480bh)
	and a
	ld ix,04813h
	jr z,l6f77h
	call sub_6fdeh
	ld a,0ffh
	jr l6f7dh
l6f77h:
	call sub_6ffeh
	ld a,001h
	ret c
l6f7dh:
	ld hl,l6d0ah
	add a,(hl)
	ld (hl),a
	call sub_6f91h
	call sub_6fc0h
	call sub_6e16h
	call sub_74bbh
	jp l6f1ah
sub_6f91h:
	ld a,(l6d0bh)
	call sub_7244h
	ld hl,0000bh
	add hl,de
	call sub_70b6h
	ld a,(hl)
	cpl
	ld (hl),a
	call l70cfh
	ret
sub_6fa5h:
	add a,c
	add hl,de
	bit 6,h
	res 6,h
	jr z,l6faeh
	inc a
l6faeh:
	ret
sub_6fafh:
	sub c
	ret c
	sbc hl,de
	bit 7,h
	set 7,h
	res 6,h
	ret nz
	and a
	scf
	ret z
	ccf
	dec a
	ret
sub_6fc0h:
	ld hl,00000h
	ld a,003h
	add a,l
	push af
	ld l,h
	ld h,000h
	ld de,0000dh
	call sub_70e0h
	ld h,l
	pop af
	ld l,a
	call sub_73a3h
	ld a,(l6d0bh)
	ld b,a
	call sub_767ah
	ret
sub_6fdeh:
	ld a,(ix+000h)
	and 01fh
	ld c,a
	ld e,(ix+001h)
	ld d,(ix+002h)
	ld a,(l6d0ch)
	ld hl,(l6d0dh)
	call sub_6fa5h
sub_6ff3h:
	set 7,h
	res 6,h
	ld (l6d0ch),a
	ld (l6d0dh),hl
	ret
sub_6ffeh:
	ld a,(ix+000h)
	and 01fh
	ld c,a
	ld e,(ix+001h)
	ld d,(ix+002h)
	ld a,(l6d0ch)
	ld hl,(l6d0dh)
	call sub_6fafh
	ret c
	jr sub_6ff3h
f4_store:
	ld a,(hdr_end)
	bit 1,a
	jp z,hdr_end+1
	call print_inline

str_7021_start:
	defb 016h
	defb 014h
	defb 014h
	defb 045h
	defb 06eh
	defb 074h
	defb 065h
	defb 072h
	defb 020h
	defb 066h
	defb 069h
	defb 06ch
	defb 065h
	defb 020h
	defb 06eh
	defb 061h
	defb 06dh
	defb 065h
	defb 03ah
	defb 0ffh
str_7021_end:
	ld hl,02514h
	call sub_73ddh
	jp z,l7c16h
	call l7c16h
	ld hl,04f00h
	push hl
	ld bc,0000ah
	ld de,l705bh
	ldir
	ld hl,01802h
	call sub_73a3h
	pop hl
	call sub_766dh
	call sub_7065h
	ret
l705bh:
	jr nz,$+34
	jr nz,l707fh
	jr nz,l7081h
	jr nz,$+34
	jr nz,l7085h
sub_7065h:
	call sub_7599h
	ld hl,l705bh
	ld de,04b01h
	ld bc,0000ah
	ldir
	ld ix,04b00h
	ld (ix+000h),013h
	ld hl,0bd00h
	xor a
l707fh:
	out (0fbh),a
l7081h:
	ld (ix+01fh),a
	inc a
l7085h:
	ld (ix+025h),a
	ld (04b20h),hl
	ld (04b26h),hl
	ld de,00300h
	ld hl,(l7f4ah)
	ld a,(l7f49h)
	inc hl
	dec a
	add hl,de
	bit 6,h
	jr z,l70a1h
	res 6,h
	inc a
l70a1h:
	ld (04b22h),a
	ld (04b23h),hl
	ld c,a
	ex de,hl
	res 7,d
	call sub_76e4h
	rst 8
	add a,h
	call sub_6d88h
	jp sub_7201h
sub_70b6h:
	push af
	push bc
	ld a,(05cb4h)
	dec a
	ld b,a
	in a,(0fbh)
	and 01fh
	cp b
	jr z,l70cch
	in a,(0fbh)
	ld (l70cfh+1),a
	ld a,b
	out (0fbh),a
l70cch:
	pop bc
	pop af
	ret
l70cfh:
	ld a,000h
	out (0fbh),a
	ret
sub_70d4h:
	ld a,0f7h
	in a,(0f9h)
	and 020h
	ret
sub_70dbh:
	ld a,020h
	jp l7341h
sub_70e0h:
	push bc
	ld b,010h
	ld a,h
	ld c,l
	ld hl,00000h
l70e8h:
	add hl,hl
	rl c
	rla
	jr nc,l70efh
	add hl,de
l70efh:
	djnz l70e8h
	pop bc
	ret
sub_70f3h:
	ld b,010h
	ld a,h
	ld c,l
	ld hl,00000h
l70fah:
	sla c
	set 0,c
	rla
	adc hl,hl
	sbc hl,de
	jr nc,l7107h
	add hl,de
	dec c
l7107h:
	djnz l70fah
	ld h,a
	ld l,c
	ret
sub_710ch:
	call sub_70b6h
	push ix
	push iy
	ld ix,05490h
	ld iy,05000h
	exx
	ld hl,05510h
	exx
	ld hl,(hdr_start)
	scf
	rr h
	rr l
	ld de,00078h
	ld b,010h
l712dh:
	push bc
	ld b,008h
l7130h:
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
	inc iy
	djnz l7130h
	add hl,de
	pop bc
	djnz l712dh
	pop iy
	pop ix
	jp l70cfh
sub_714eh:
	call sub_70b6h
	ld hl,05000h
	ld de,(hdr_start)
	scf
	rr d
	rr e
	ld b,010h
l715fh:
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
	djnz l715fh
	jp l70cfh
init:
	di
	ld a,002h
	call 0015ah
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
	ld a,(05cb4h)
	dec a
	or 0c0h
	out (0fch),a
	ld (05a78h),a
l71b3h:
	nop
sub_71b4h:
	ld a,(05cb4h)
	sub 003h
	ld hl,credits_end
	ld (l6d0ch),a
	ld (l6d0dh),hl
l71c2h:
	ld a,0c9h
	ld (l71c2h),a
	ld (l71b3h),a
	ld a,001h
	out (0fbh),a
	ld hl,credits_end
	ld de,05190h
	ld bc,00400h
	ldir
	ret
f1_scan:
	call sub_752eh
	ld a,0a7h
	out (0feh),a
	ld a,(05cb4h)
	dec a
	out (0fbh),a
	call sub_75abh
	xor a
	ld (l6d0ah),a
	call sub_71b4h
	call sub_6d88h
	call sub_7201h
	ld a,027h
	out (0feh),a
	ld a,039h
	ld (hdr_end),a
	ret
sub_7201h:
	ld a,(l6d09h)
	and a
	ret z
	ld c,a
	ld hl,00003h
	call sub_73a3h
	ld b,000h
l720fh:
	call sub_767ah
	ret z
	call sub_767ah
	ret z
	call sub_767ah
	ret z
	call sub_767ah
	ret z
	call sub_767ah
	ld a,008h
	call l7341h
	call l7341h
	ld a,00dh
	call l7341h
	ret z
	jr l720fh
f2_link:
	ld a,(l6d0ah)
	and a
	jp z,hdr_end+1
	ld a,(hdr_end)
	bit 3,a
	jp z,hdr_end+1
	jp l7b9eh
sub_7244h:
	ld l,a
	ld h,000h
	ld de,00019h
	call sub_70e0h
	ld de,0f000h
	add hl,de
	push hl
	ld de,04800h
	ld bc,00019h
	ld a,(05cb4h)
	dec a
	out (0fbh),a
	ldir
	ld a,001h
	out (0fbh),a
	ld hl,04800h
	pop de
	ret
get_command:
	call scan_keys
	ret nz
	call sub_72bfh
	ld (l6d04h),a
	and a
	ret nz
	call sub_729fh
	ld (l6d04h),a
	ret
;==============================================================================
; scan_keys (&727C): read the F-key row and build the command bitmask in A.
; Two keyboard half-rows are read on data port &F9 with the row selected by the
; high address byte (B = &FE then &FD). Three keys are taken from each row and
; packed into A as bits 0..5 (F1..F6); bit7 is set if any of them is down.
;   bit0=F1 SCAN  bit1=F2 LINK  bit2=F3 COMPRESS
;   bit3=F4 STORE bit4=F5 EXIT  bit5=F6 ALL
;==============================================================================
scan_keys:
	ld bc,0fef9h		; B=&FE selects first key row, C=&F9 data port
	in e,(c)		; E = row &FE
	ld b,0fdh		; B=&FD selects second key row
	in d,(c)		; D = row &FD
	ld a,e			; extract 3 keys from row &FE -> bits 0..2
	rra
	rra
	rra
	rra
	rra			; E.b5..b7 -> b0..b2
	xor 007h		; keys active-low -> invert
	and 007h
	ld e,a
	ld a,d			; extract 3 keys from row &FD -> bits 3..5
	rra
	rra			; D.b5..b7 -> b3..b5
	xor 038h
	and 038h
	or e			; A = 6-bit command mask (F1..F6)
	ld (l6d05h),a		; remember last key mask
	ret z			; no key -> return Z, A=0
	or 080h			; key down -> set bit7 "pressed" flag
	ret
sub_729fh:
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
	jr z,l72b7h
	set 4,a
l72b7h:
	bit 4,c
	jr z,l72bdh
	set 3,a
l72bdh:
	jr l72c4h
sub_72bfh:
	ld bc,0effeh
	in a,(c)
l72c4h:
	xor 01fh
	ld e,a
	rra
	rra
	rra
	and 003h
	bit 0,e
	jr z,l72d2h
	or 010h
l72d2h:
	bit 1,e
	jr z,l72d8h
	or 008h
l72d8h:
	bit 2,e
	jr z,l72deh
	or 004h
l72deh:
	and 01fh
	ret
sub_72e1h:
	ld a,(l6d04h)
	and 00fh
	ret z
	call sub_714eh
	ld a,(l6d04h)
	ld e,a
	rr e
	call c,sub_7323h
	rr e
	call c,sub_7332h
	rr e
	call c,sub_7305h
	rr e
	call c,sub_7314h
	jp sub_710ch
sub_7305h:
	ld a,(l6d03h)
	inc a
	inc a
	cp 0b1h
	jr c,l7310h
	dec a
	dec a
l7310h:
	ld (l6d03h),a
	ret
sub_7314h:
	ld a,(l6d03h)
	dec a
	dec a
	cp 016h
	jr nz,l731fh
	inc a
	inc a
l731fh:
	ld (l6d03h),a
	ret
sub_7323h:
	ld a,(hdr_start)
	inc a
	inc a
	cp 0f1h
	jr c,l732eh
	dec a
	dec a
l732eh:
	ld (hdr_start),a
	ret
sub_7332h:
	ld a,(hdr_start)
	dec a
	dec a
	cp 0feh
	jr nz,l733dh
	inc a
	inc a
l733dh:
	ld (hdr_start),a
	ret
l7341h:
	push af
	push bc
	push de
	push hl
	call 00010h
	pop hl
	pop de
	pop bc
	pop af
	ret
print_inline:
	ex (sp),hl
	call print_str
	ex (sp),hl
	ret
l7353h:
	push af
	call hdr_end+1
	call l7c16h
	ld sp,(06d7eh)
	ld hl,l6d25h
	push hl
	ld hl,l73cdh
	push hl
	ld hl,01614h
	call sub_73a3h
	pop af
	cp 057h
	jr nz,l7380h
	call print_inline

str_7374_start:
	defb 043h
	defb 068h
	defb 065h
	defb 063h
	defb 06bh
	defb 020h
	defb 064h
	defb 069h
	defb 073h
	defb 06bh
	defb 0ffh
str_7374_end:
	ret
l7380h:
	and a
	jr nz,l7392h
	call print_inline

str_7386_start:
	defb 050h
	defb 061h
	defb 063h
	defb 06bh
	defb 020h
	defb 065h
	defb 072h
	defb 072h
	defb 06fh
	defb 072h
	defb 0ffh
str_7386_end:
	ret
l7392h:
	call print_inline

str_7395_start:
	defb 044h
	defb 069h
	defb 073h
	defb 06bh
	defb 020h
	defb 065h
	defb 072h
	defb 072h
	defb 06fh
	defb 072h
	defb 020h
	defb 021h
	defb 0ffh
str_7395_end:
	ret
sub_73a3h:
	ld a,016h
	rst 10h
	ld a,l
	rst 10h
	ld a,h
	rst 10h
	ret
print_str:
	ld a,(hl)
	cp 0ffh
	ret z
	call l7341h
	inc hl
	jr print_str
sub_73b5h:
	call 00166h
l73b8h:
	bit 5,(hl)
	jr z,l73b8h
	ld a,(05c08h)
	push af
	call sub_74bbh
	pop af
	ret
sub_73c5h:
	ld hl,05c6ah
	ld a,008h
	xor (hl)
	ld (hl),a
	ret
l73cdh:
	push bc
	push de
	push hl
	ei
	call sub_73b5h
	cp 006h
	call z,sub_73c5h
	pop hl
	pop de
	pop bc
	ret
sub_73ddh:
	ld (073f9h),hl
	ld hl,04f00h
	ld ix,00a00h
	ld b,ixh
	ld de,l705bh
l73ech:
	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	djnz l73ech
	ld (hl),b
	call 00166h
l73f6h:
	ld b,ixh
	ld hl,00000h
	ld a,016h
	rst 10h
	ld a,l
	rst 10h
	ld a,h
	rst 10h
	ld hl,04f00h
	ld c,000h
l7407h:
	ld a,l
	cp c
	ld a,07ch
	call z,l7341h
	ld a,(hl)
	call l7341h
	inc hl
	djnz l7407h
	ld a,l
	cp c
	ld a,03ch
	call z,l7341h
	call l73cdh
	cp 007h
	jp z,l747fh
	cp 00dh
	jp z,l747fh
	ld hl,l73f6h
	push hl
	ld hl,07406h
	cp 008h
	jr z,l7458h
	cp 009h
	jr z,l745dh
	cp 00ch
	jr z,l746ah
	cp 00eh
	jr z,l7463h
	cp 020h
	ret c
	cp 080h
	ret nc
	ex af,af'
	ld a,(hl)
	cp ixh
	ret nc
	inc (hl)
	ld l,(hl)
	dec l
	ld h,04fh
l7450h:
	ld a,(hl)
	or a
	ret z
	ex af,af'
	ld (hl),a
	inc hl
	jr l7450h
l7458h:
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ret
l745dh:
	ld a,(hl)
	cp ixh
	ret nc
	inc (hl)
	ret
l7463h:
	ld a,(hl)
	cp ixh
	ret z
	inc a
	jr l746eh
l746ah:
	ld a,(hl)
	or a
	ret z
	dec (hl)
l746eh:
	ld l,a
	ld h,04fh
	ld e,l
	ld d,h
	dec e
l7474h:
	ld a,(hl)
	ldi
	or a
	jr nz,l7474h
	ex de,hl
	dec hl
	ld (hl),020h
	ret
l747fh:
	push af
	ld hl,(073f9h)
	ld a,016h
	rst 10h
	ld a,l
	rst 10h
	ld a,h
	rst 10h
	ld b,ixh
	inc b
l748dh:
	ld a,020h
	call l7341h
	djnz l748dh
	pop af
	cp 007h
	ret
sub_7498h:
	di
	ld hl,credits_end
	ld bc,05200h
	ld de,l8001h
	ld (hl),l
	ldir
	ld hl,credits_end
	ld de,00001h
l74abh:
	ld a,(05a07h)
	call sub_7547h
	ret c
	call sub_7df2h
	ld a,004h
	cp d
	ret z
	jr l74abh
sub_74bbh:
	ld e,080h
	ld a,027h
	di
l74c0h:
	ld b,e
	out (0feh),a
l74c3h:
	djnz l74c3h
	xor 018h
	dec c
	jr nz,l74c0h
	srl e
	jr nc,l74c0h
	ei
	ret
sub_74d0h:
	cp 002h
	ld b,0e0h
	jr nz,l74d8h
	ld b,0f0h
l74d8h:
	ld a,d
	and 080h
	jr z,l74dfh
	ld a,004h
l74dfh:
	or b
	push af
	ld (l7510h+1),a
	ld (l7520h+1),a
	inc a
	ld (07517h),a
	inc a
	ld (07506h),a
	ld a,d
	and 07fh
	ld d,a
	pop af
	ret
sub_74f5h:
	ld a,e
	and a
	jr z,l7528h
	cp 00bh
	jr nc,l7528h
	ld a,d
	and 07fh
	cp 050h
	jr nc,l7528h
	ld a,e
	out (0e2h),a
l7507h:
	call sub_70d4h
	jr nz,l7510h
	pop af
	jp l7595h
l7510h:
	in a,(0e0h)
	bit 0,a
	jr nz,l7507h
	in a,(0e1h)
	cp d
	ret z
	ld a,07bh
	jr nc,l7520h
	ld a,05bh
l7520h:
	out (0e0h),a
	ld b,014h
l7524h:
	djnz l7524h
	jr l7507h
l7528h:
	pop af
	ld a,051h
	jp l7595h+2
sub_752eh:
	ld hl,l7539h
	ld (05bc0h),hl
	ld a,(05a07h)
	rst 8
	and h
l7539h:
	call sub_7cceh
	and a
	push af
	ld a,027h
	out (0feh),a
	pop af
	jp nz,l7353h
	ret
sub_7547h:
	call sub_74d0h
	ld (07561h),a
	ld (l756dh+1),a
	ld (0758fh),a
	add a,003h
	ld (07567h),a
	xor a
	ex af,af'
l755ah:
	call sub_74f5h
	di
	ld a,080h
	out (0e0h),a
	ld b,014h
l7564h:
	djnz l7564h
	ld bc,000f3h
	jr l756dh
l756bh:
	ini
l756dh:
	in a,(0e0h)
	bit 1,a
	jr nz,l756bh
	bit 0,a
	jr nz,l756dh
	and 01bh
	ret z
	ex af,af'
	inc a
	push af
	ex af,af'
	pop af
	push af
	and 002h
	call nz,sub_758ch
	pop af
	cp 001h
	jr nc,l7595h
	jr l755ah
sub_758ch:
	ld a,009h
	out (0e0h),a
	ld b,014h
l7592h:
	djnz l7592h
	ret
l7595h:
	jp l7353h
	ret
sub_7599h:
	ld hl,04b00h
	ld b,01ah
l759eh:
	ld (hl),020h
	inc hl
	djnz l759eh
	ld b,00eh
l75a5h:
	ld (hl),0ffh
	inc hl
	djnz l75a5h
	ret
sub_75abh:
	ld ix,0f000h
	xor a
	ld h,a
	ld l,a
	ld (l6d06h),hl
	ld (l6d08h),a
	ld (l6d09h),a
	ld (06ec7h),a
	ld hl,0f000h
	ld bc,007ffh
	ld de,0f001h
	ld (hl),l
	ldir
	call sub_7498h
	ld hl,l8001h
	ld a,(hl)
	dec hl
	and a
	jr z,l75feh
l75d5h:
	call sub_7600h
	jr nc,l75deh
	jr z,l75feh
	jr l75e6h
l75deh:
	call sub_7608h
	ld de,00019h
	add ix,de
l75e6h:
	inc h
	call sub_7600h
	jr nc,l75f0h
	jr z,l75feh
	jr l75f8h
l75f0h:
	call sub_7608h
	ld de,00019h
	add ix,de
l75f8h:
	inc h
	ld a,h
	cp 0d0h
	jr c,l75d5h
l75feh:
	ei
	ret
sub_7600h:
	ld a,(hl)
	and a
	ret nz
	inc hl
	or (hl)
	dec hl
	scf
	ret
sub_7608h:
	push hl
	ld a,(hl)
	and 01fh
	ld (ix+000h),a
	inc hl
	push ix
	pop de
	inc de
	ld bc,0000eh
	ldir
	ld (ix+00bh),000h
	ld de,000ddh
	add hl,de
	ex de,hl
	push ix
	pop hl
	ld bc,00010h
	add hl,bc
	ex de,hl
	ld bc,00009h
	push hl
	ldir
	pop hl
	ld a,(ix+000h)
	and a
	jr z,l7667h
	inc hl
	inc hl
	inc hl
	ld iy,l6d06h
	ld a,(hl)
	inc hl
	add a,(iy+000h)
	ld (iy+000h),a
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld a,(iy+000h)
	ld d,(iy+002h)
	ld e,(iy+001h)
	res 7,d
	add hl,de
	ld de,00030h
	add hl,de
	bit 6,h
	res 6,h
	jr z,l7661h
	inc a
l7661h:
	ld (l6d07h),hl
	ld (l6d06h),a
l7667h:
	ld hl,l6d09h
	inc (hl)
	pop hl
	ret
sub_766dh:
	ld b,00ah
l766fh:
	ld a,(hl)
	call l7341h
	inc hl
	djnz l766fh
	ret
sub_7677h:
	push bc
	jr l767fh
sub_767ah:
	ld a,b
	push bc
	call sub_7244h
l767fh:
	push hl
	ld a,(hl)
	and 01fh
	inc hl
	cp 010h
	ld b,042h
	jr z,l76aah
	cp 011h
	ld b,04eh
	jr z,l76aah
	ld b,024h
	cp 012h
	jr z,l76aah
	ld b,043h
	cp 013h
	jr z,l76aah
	ld b,053h
	cp 014h
	jr z,l76aah
	ld b,044h
	cp 015h
	jr z,l76aah
	ld b,03fh
l76aah:
	push bc
	ld a,014h
	call l7341h
	ld a,(0480bh)
	and 001h
	call l7341h
	call sub_766dh
	ld a,014h
	call l7341h
	xor a
	call l7341h
	ld a,02eh
	call l7341h
	pop af
	call l7341h
	ld a,009h
	call l7341h
	pop hl
	pop bc
	inc b
	dec c
	ret
sub_76d7h:
	ld a,(hl)
	and 03fh
	ld c,a
	inc hl
	ld e,(hl)
	inc hl
	ld a,(hl)
	and 07fh
	ld d,a
	inc hl
	ret
sub_76e4h:
	push hl
	ex de,hl
	xor a
	ld de,00000h
	rr c
	rr d
	rr c
	rr d
	ld a,d
	add a,h
	ld h,a
	ld a,c
	adc a,e
	ld b,a
	ld de,086a0h
	ld a,020h
	ld c,001h
	call sub_772dh
	ld c,000h
	ld de,02710h
	call sub_772dh
	ld de,003e8h
	call sub_772ah
	ld de,00064h
	call sub_772ah
l7716h:
	ld de,0000ah
	call sub_772ah
	ld a,l
	add a,030h
	call l7341h
	call sub_70dbh
	pop hl
	ret
sub_7727h:
	push hl
	jr l7716h
sub_772ah:
	ld bc,00000h
sub_772dh:
	push af
	ld a,b
	ld b,000h
	and a
l7732h:
	sbc hl,de
	sbc a,c
	jr c,l773ah
	inc b
	jr l7732h
l773ah:
	add hl,de
	adc a,c
	ld c,a
	ld a,b
	ld b,c
	and a
	jr nz,l7748h
	pop de
	add a,d
	ret z
	jp l7341h
l7748h:
	add a,030h
	call l7341h
	pop de
	ld a,030h
	ret
sub_7751h:
	ld a,001h
	ld hl,credits_end
	out (0fbh),a
	ld ix,l7f4ch
	ld (ix+000h),l
	ld (ix+001h),l
	ld a,(l7f49h)
	ld de,(l7f4ah)
	inc de
	and 01fh
	ld c,a
l776dh:
	ld a,(hl)
	add a,(ix+000h)
	ld (ix+000h),a
	jr nc,l7779h
	inc (ix+001h)
l7779h:
	inc hl
	bit 6,h
	res 6,h
	in a,(0fbh)
	jr z,l7785h
	inc a
	out (0fbh),a
l7785h:
	and 01fh
	cp c
	jr nz,l776dh
	sbc hl,de
	add hl,de
	jr nz,l776dh
	ld hl,(l7f4ch)
	ld a,l
	cpl
	ld l,a
	ld a,h
	cpl
	ld h,a
	inc hl
	ld (l7f4ch),hl
	ret
sub_779dh:
	ld hl,sub_7e2bh+1
	ld a,(07e30h)
	or (hl)
	jp nz,l77adh
	ld a,(hdr_end)
	bit 2,a
	ret nz
l77adh:
	pop hl
	jp hdr_end+1
sub_77b1h:
	ld hl,03814h
	call sub_73a3h
	ld a,(l7f49h)
	dec a
	ld c,a
	ld hl,(l7f4ah)
	res 7,h
	ex de,hl
	jp sub_76e4h
f3_compress:
	call sub_779dh
	call sub_74bbh
	call l7c16h
	call sub_7936h
	call sub_77b1h
	ld a,(l7f49h)
	ld hl,(l7f4ah)
	inc hl
	dec a
	res 7,h
	ld (l784ah),a
	ld (l784bh),hl
	ld a,003h
	bit 0,a
	jr z,l77fbh
	call sub_7825h
	inc a
	ld (sub_7e2bh+1),a
	inc hl
	ld (l7f49h),a
	ld (l7f4ah),hl
	call sub_77b1h
l77fbh:
	ld a,(077e5h)
	bit 1,a
	call nz,sub_79cch
	call sub_77b1h
l7806h:
	call l7c16h
	call sub_74bbh
	ld de,l7c45h
	ld bc,0001bh
	call 00013h
	call l73cdh
	res 5,a
	cp 059h
	jp nz,l7c16h
	call l7c16h
	jp f4_store
sub_7825h:
	di
	ld (078b2h),sp
	call sub_78b7h
	exx
	in a,(0fbh)
	ld (l7ea2h+2),a
	ld a,b
	ld (07eaeh),hl
	ld (07ea6h),de
	ld (07each),a
	in a,(0fbh)
	ld a,b
	dec a
	ld e,a
	ld a,001h
	out (0fbh),a
	ld a,e
	ei
l7849h:
	ret
l784ah:
	ld (bc),a
l784bh:
	nop
	nop
sub_784dh:
	dec bc
	bit 7,b
	jr z,l785bh
	xor a
	or iyh
	ret z
	dec iyh
	ld bc,03fffh
l785bh:
	inc e
	ld a,(hl)
	inc hl
	bit 6,h
	jr z,l786bh
	push af
	in a,(0fbh)
	inc a
	out (0fbh),a
	res 6,h
	pop af
l786bh:
	cp (hl)
	scf
	ret
l786eh:
	inc e
	ld a,(hl)
sub_7870h:
	dec e
	bit 7,e
	call nz,sub_7877h
	ld a,e
sub_7877h:
	ld (07881h),a
	in a,(0fbh)
	push af
	ld (07896h),a
	ld a,000h
	call sub_7889h
	pop af
	out (0fbh),a
	ret
sub_7889h:
	push hl
	exx
	pop de
	out (c),b
	ld (hl),a
	and 011h
	or 006h
	out (0feh),a
	ld a,000h
	cp b
	jr nz,l78a0h
	and a
	sbc hl,de
	add hl,de
	jr nc,l78b0h
l78a0h:
	inc hl
	bit 6,h
	exx
	ret z
	exx
	inc b
	res 6,h
	exx
	ret
sub_78abh:
	ld a,(hl)
	inc hl
	cp (hl)
	dec hl
	ret
l78b0h:
	xor a
	ld sp,00000h
	jp l7353h
sub_78b7h:
	ld a,001h
	ld hl,credits_end
	ld iy,(l7849h)
	ld bc,(l784bh)
	out (0fbh),a
	call sub_7910h
	jp nc,l78b0h
	in a,(0fbh)
	push af
	push hl
	exx
	pop hl
	pop bc
	ld c,0fbh
	exx
l78d6h:
	ld e,080h
l78d8h:
	call sub_784dh
	jp nc,l786eh
	jr nz,l78e9h
	bit 7,e
	jr nz,l78d8h
	call sub_7870h
	jr l78d6h
l78e9h:
	call sub_7870h
	call sub_78abh
	jr z,l78d6h
l78f1h:
	ld e,000h
l78f3h:
	ld a,(hl)
	call sub_7877h
	call sub_784dh
	jp nc,l786eh
	call sub_78abh
	jr nz,l7907h
	call sub_7870h
	jr l78d6h
l7907h:
	bit 7,e
	jr z,l78f3h
	call sub_7870h
	jr l78f1h
sub_7910h:
	ld a,(hl)
	inc hl
	cp (hl)
	jr nz,l791ah
	inc hl
	cp (hl)
	jr z,l7932h
	dec hl
l791ah:
	dec bc
	ld a,b
	or c
	jr nz,l7925h
	or iyh
	ret z
	ld hl,03fffh
l7925h:
	bit 6,h
	jr z,sub_7910h
	res 6,h
	in a,(0fbh)
	inc a
	out (0fbh),a
	jr sub_7910h
l7932h:
	dec hl
	dec hl
	scf
	ret
sub_7936h:
	call print_inline

str_7939_start:
	defb 016h
	defb 014h
	defb 016h
	defb 04dh
	defb 06fh
	defb 064h
	defb 065h
	defb 020h
	defb 03ah
	defb 020h
	defb 0ffh
str_7939_end:
	call l73cdh
	cp 030h
	jr c,l794fh
	cp 034h
	jr c,l7951h
l794fh:
	ld a,033h
l7951h:
	ld (077e5h),a
	rst 10h
	call print_inline

str_7958_start:
	defb 020h
	defb 020h
	defb 020h
	defb 053h
	defb 070h
	defb 065h
	defb 065h
	defb 064h
	defb 020h
	defb 03ah
	defb 020h
	defb 0ffh
str_7958_end:
	call l73cdh
	cp 030h
	jr c,l796fh
	cp 038h
	jr c,l7971h
l796fh:
	ld a,030h
l7971h:
	push af
	sub 037h
	neg
	inc a
	ld (07ac5h),a
	ld (l7acah+2),a
	pop af
	rst 10h
	call print_inline

str_7982_start:
	defb 020h
	defb 020h
	defb 020h
	defb 053h
	defb 06bh
	defb 069h
	defb 070h
	defb 020h
	defb 03ah
	defb 020h
	defb 0ffh
str_7982_end:
	call l73cdh
	cp 030h
	jr c,l7998h
	cp 03ah
	jr c,l799ah
l7998h:
	ld a,030h
l799ah:
	sub 030h
	ld h,a
	ld l,000h
	add hl,hl
	add hl,hl
	ld (079abh),hl
	add a,030h
	rst 10h
	ret
sub_79a8h:
	ld iyh,e
	ld de,00000h
	res 7,b
	add hl,de
	push bc
	ex (sp),hl
	and a
	sbc hl,de
	res 7,h
	res 6,h
	jr nc,l79bdh
	dec iyh
l79bdh:
	ex (sp),hl
	pop bc
	cp 0ffh
	jp z,l78b0h
	inc iyh
	jp z,l78b0h
	dec iyh
	ret
sub_79cch:
	ld hl,credits_end
	ld bc,(l7f4ah)
	inc bc
	in a,(0fbh)
	push af
	ld a,(l7f49h)
	dec a
	ld e,a
	ld a,001h
	ld (07e30h),a
	di
	call sub_79a8h
	ld e,iyh
	push af
	out (0fbh),a
	ld a,e
	push hl
	push bc
	push de
	call sub_7a02h
	pop de
	pop bc
	pop hl
	pop af
	out (0fbh),a
	call sub_7a8fh
	xor a
	out (0feh),a
	pop af
	out (0fbh),a
	ei
	ret
sub_7a02h:
	res 7,b
	call sub_7a12h
	ex af,af'
	ld (07b2dh),a
	ld (07b37h),a
	ld (07e71h),a
	ret
sub_7a12h:
	push bc
	push de
	push hl
	ld hl,04f00h
	ld de,04f01h
	ld bc,001ffh
	ld (hl),000h
	ldir
	pop hl
	pop de
	pop bc
l7a25h:
	in a,(0fbh)
	bit 6,h
	set 7,h
	res 6,h
	jr z,l7a32h
	inc a
	out (0fbh),a
l7a32h:
	out (0feh),a
	ld a,b
	or c
	jr nz,l7a3dh
	inc e
	dec e
	jr z,l7a5ch
	dec e
l7a3dh:
	dec bc
	ld a,(hl)
	inc hl
	ld ix,04f00h
	push hl
	ld l,a
	and 027h
	out (0feh),a
	ld h,000h
	add hl,hl
	ex de,hl
	add ix,de
	ex de,hl
	pop hl
	inc (ix+000h)
	jr nz,l7a25h
	inc (ix+001h)
	jr l7a25h
l7a5ch:
	ld a,001h
	ex af,af'
	ld ix,04f02h
	ld de,0ffffh
l7a66h:
	ld c,(ix+000h)
	inc ix
	ld b,(ix+000h)
	inc ix
	ld a,b
	or c
	ret z
	ex af,af'
	inc a
	jr z,l7a8bh
	ex af,af'
	ld a,e
	cp c
	jr c,l7a66h
	ld a,d
	cp b
	jr c,l7a66h
	push bc
	pop de
	ex af,af'
	dec a
	ld (l7a8bh+1),a
	inc a
	ex af,af'
	jr l7a66h
l7a8bh:
	ld a,001h
	ex af,af'
	ret
sub_7a8fh:
	call sub_7b73h
l7a92h:
	ld a,(de)
	call sub_7b7eh
	inc de
	ex af,af'
	bit 6,d
	jr z,l7aa3h
	res 6,d
	in a,(0fbh)
	inc a
	out (0fbh),a
l7aa3h:
	dec bc
	ld a,b
	or c
	jr nz,l7ab2h
	or iyh
	jp z,l7b47h
	ld bc,04000h
	jr l7abah
l7ab2h:
	bit 7,b
	jr z,l7abch
	res 7,b
	res 6,b
l7abah:
	dec iyh
l7abch:
	push hl
	push bc
	ld a,iyh
	and a
	jr nz,l7acah
	ld hl,00821h
	sbc hl,bc
	jr nc,l7acdh
l7acah:
	ld bc,00821h
l7acdh:
	ld h,d
	ld l,e
	ld ixh,002h
l7ad2h:
	ex af,af'
	call 00095h
	ex af,af'
	scf
	push hl
	sbc hl,de
	bit 3,h
	ex (sp),hl
	exx
	pop bc
	exx
	jr nz,l7b0dh
	push bc
	push de
	push hl
	ld a,b
	and a
	ld a,021h
	jr nz,l7aefh
	cp c
	jr nc,l7af0h
l7aefh:
	ld c,a
l7af0h:
	ld b,c
	inc b
l7af2h:
	dec b
	jr z,l7afbh
	ld a,(de)
	cp (hl)
	inc de
	inc hl
	jr z,l7af2h
l7afbh:
	ld a,c
	sub b
	cp ixh
	jr c,l7b07h
	ld ixh,a
	exx
	ld d,b
	ld e,c
	exx
l7b07h:
	cp c
	pop hl
	pop de
	pop bc
	jr nz,l7ad2h
l7b0dh:
	pop bc
	pop hl
	ld a,ixh
	sub 002h
	jr z,l7b35h
	exx
	add a,a
	add a,a
	add a,a
	or d
	ex af,af'
	ld a,e
	exx
l7b1dh:
	dec bc
	inc de
	dec ixh
	jr nz,l7b1dh
	call sub_7b7eh
	inc hl
	ex af,af'
l7b28h:
	call sub_7b7eh
	inc hl
	ld a,003h
	call sub_7b7eh
	inc hl
	jp l7a92h
l7b35h:
	ex af,af'
	sub 003h
	inc hl
	jp nz,l7a92h
	inc hl
	call sub_7b61h
	dec hl
	dec hl
	jr c,l7b28h
	jp l78b0h
l7b47h:
	ld a,iyl
	inc hl
	ld (l7f49h),a
	ld (l7f4ah),hl
	ld (07e42h),a
	ex de,hl
	ld (07e3fh),hl
	ld (sub_7e3bh+1),de
	in a,(0fbh)
	ld (07e48h),a
	ret
sub_7b61h:
	ld (l7b70h+1),a
	in a,(0fbh)
	cp iyl
	ccf
	ret nc
	jr nz,l7b70h
	ccf
	sbc hl,de
	add hl,de
l7b70h:
	ld a,000h
	ret
sub_7b73h:
	ld iyh,e
	ld iyl,a
	out (0fbh),a
	ld d,h
	ld e,l
	res 7,b
	ret
sub_7b7eh:
	push af
	in a,(0fbh)
	ld (07b99h),a
	ld a,iyl
	bit 6,h
	res 6,h
	jr z,l7b8dh
	inc a
l7b8dh:
	out (0fbh),a
	ld iyl,a
	pop af
	push af
	ld (hl),a
	and 037h
	out (0feh),a
	ld a,000h
	out (0fbh),a
	pop af
	ret
l7b9eh:
	call sub_74bbh
	xor a
	ld (sub_7e2bh+1),a
	ld (07e30h),a
	inc a
	ld hl,credits_end
	ld (l7f49h),a
	ld (l7f4ah),hl
	ld b,000h
l7bb4h:
	push bc
	ld a,b
	call sub_7244h
	ld a,(0480bh)
	and a
	jr z,l7bdch
	call sub_7c60h
	ld de,(l7f4ah)
	ld a,(l7f49h)
	out (0fbh),a
	ld hl,04b50h
	ld bc,00030h
	ldir
	ld (l7f4ah),de
	call sub_7c8ch
	ld (hl),0ffh
l7bdch:
	pop bc
	ld a,027h
	out (0feh),a
	inc b
	ld a,(l6d09h)
	cp b
	jr nz,l7bb4h
	ld a,(l7f49h)
	ld hl,(l7f4ah)
	ld (07f0ch),a
	dec a
	ld (07f0eh),hl
	call l7c16h
	call sub_7751h
	ld a,03fh
	ld (hdr_end),a
	ld de,l7c24h
	ld bc,00021h
	call 00013h
	call l73cdh
	res 5,a
	cp 059h
	jp nz,l7806h
	jp f3_compress
l7c16h:
	ld hl,01414h
	call sub_73a3h
	ld b,023h
l7c1eh:
	ld a,020h
	rst 10h
	djnz l7c1eh
	ret
l7c24h:
	ld d,014h
	ld d,044h
	ld c,a
	jr nz,l7c84h
	ld c,a
	ld d,l
	jr nz,$+89
	ld b,c
	ld c,(hl)
	ld d,h
	jr nz,$+69
	ld c,a
	ld c,l
	ld d,b
	ld d,d
	ld b,l
	ld d,e
	ld d,e
	jr nz,$+48
	ld l,02eh
	jr nz,$+42
	ld e,c
	cpl
	ld c,(hl)
	add hl,hl
l7c45h:
	ld d,014h
	ld d,053h
	ld b,c
	ld d,(hl)
	ld b,l
	jr nz,l7ca2h
	ld c,b
	ld c,c
	ld d,e
	jr nz,$+72
	ld c,c
	ld c,h
	ld b,l
	jr nz,$+48
	ld l,02eh
	jr nz,l7c84h
	ld e,c
	cpl
	ld c,(hl)
	add hl,hl
sub_7c60h:
	di
	call sub_7599h
	ld de,04b00h
	ld hl,04800h
	ld bc,0000bh
	ldir
	ld hl,01614h
	call sub_73a3h
	ld hl,04800h
	call sub_7677h
	ld ix,04b00h
	ld hl,l7c84h
	rst 8
	add a,c
l7c84h:
	and a
	call sub_7cceh
	jp nz,l7353h
	ret
sub_7c8ch:
	ld a,(l7f49h)
	out (0fbh),a
	ld ix,04b00h
	ld a,(ix+072h)
	ld e,(ix+073h)
	ld d,(ix+074h)
	res 7,d
	and 01fh
l7ca2h:
	ld c,a
	push bc
	push de
	in a,(0fbh)
	ld hl,(l7f4ah)
	bit 6,h
	res 6,h
	jr z,l7cb3h
	inc a
	out (0fbh),a
l7cb3h:
	push hl
	push af
	di
	rst 8
	add a,d
	pop af
	pop hl
	pop de
	pop bc
	add hl,de
	bit 6,h
	res 6,h
	jr z,l7cc4h
	inc a
l7cc4h:
	add a,c
	ld (l7f49h),a
	ld (l7f4ah),hl
	out (0fbh),a
	ret
sub_7cceh:
	ld hl,00000h
	ld (05bc0h),hl
	ret
l7cd5h:
	ld de,00068h
	ld hl,0fffch
	ld b,097h
	ld c,004h
l7cdfh:
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
	jr nz,l7cdfh
	ret
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
	call sub_7e2bh
	call sub_7f00h
	ld de,l7f5ah
	ld bc,0003bh
	call 00013h
	ld hl,000c8h
	ld de,0012ch
	call ROM_016F
	call 00166h
	ld hl,05c3bh
l7d44h:
	bit 5,(hl)
	jr z,l7d44h
	call 00151h
	rst 8
	and h
	ld hl,credits_end
	ld a,001h
	out (0fbh),a
	ld c,a
l7d55h:
	ld a,(hl)
	cp 0ffh
	ld a,c
	ret z
	push af
	ld de,04b00h
	ld bc,00030h
	ldir
	push hl
	call sub_7d81h
	ld de,(04b23h)
	ld a,(04b22h)
	ld c,a
	pop hl
	pop af
	res 7,d
	add hl,de
	bit 6,h
	res 6,h
	jr z,l7d7bh
	scf
l7d7bh:
	adc a,c
	out (0fbh),a
	ld c,a
	jr l7d55h
sub_7d81h:
	bit 6,h
	res 6,h
	in a,(0fbh)
	jr z,l7d8ch
	inc a
	out (0fbh),a
l7d8ch:
	ld de,(04b1fh)
	ld (l7f49h),de
	ld de,(04b20h)
	ld (l7f4ah),de
	ld (04b1fh),a
	ld (04b20h),hl
	ld ix,04b00h
	rst 8
	add a,h
	ld a,(04b00h)
	and 01fh
	cp 013h
	ret nz
	jr l7dbeh
sub_7db2h:
	xor a
	ld bc,00a00h
l7db6h:
	ld a,(de)
	xor (hl)
	inc hl
	inc de
	ret nz
	djnz l7db6h
	ret
l7dbeh:
	ld de,00001h
	ld b,028h
l7dc3h:
	push de
	push bc
	call sub_7e17h
	jr c,l7df0h
	ld hl,04f01h
	ld de,04b01h
	push de
	call sub_7db2h
	pop de
	jr z,l7dfbh
	ld hl,05001h
	call sub_7db2h
	jr z,l7dfbh
	and a
	pop bc
	pop de
	ret c
	call sub_7df2h
	djnz l7dc3h
	ld a,0f7h
	in a,(0f9h)
	and 020h
	jr nz,$-3
l7df0h:
	rst 8
	add hl,de
sub_7df2h:
	inc e
	ld a,e
	cp 00bh
	ret nz
	ld e,001h
	inc d
	ret
l7dfbh:
	pop bc
	inc hl
	inc hl
	ld b,(hl)
	inc hl
	ld c,(hl)
	ld bc,000deh
	add hl,bc
	ld a,(l7f49h)
	ld de,(l7f4ah)
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	pop de
	call sub_7e21h
	and a
	ret
sub_7e17h:
	ld a,(05a07h)
	ld hl,04f00h
	di
	rst 8
	and b
	ret
sub_7e21h:
	ld a,(05a07h)
	ld hl,04f00h
	di
	rst 8
	sub l
	ret
sub_7e2bh:
	ld a,000h
	and a
	push af
	ld a,000h
	and a
	call nz,sub_7e3bh
	pop af
	ei
	jp nz,l7ea2h
	ret
sub_7e3bh:
	ld hl,00000h
	ld de,00000h
	ld a,000h
	out (0fbh),a
	exx
	ld bc,HMPR
	exx
l7e4ah:
	ld a,0a0h
	cp h
	jr c,l7e56h
	set 6,h
	in a,(0fbh)
	dec a
	out (0fbh),a
l7e56h:
	dec hl
	ld a,(hl)
	ex af,af'
	ld a,0a0h
	cp d
	jr c,l7e63h
	exx
	dec b
	exx
	set 6,d
l7e63h:
	exx
	in e,(c)
	out (c),b
	exx
	ex af,af'
	dec de
	ld (de),a
	exx
	out (c),e
	exx
	sub 003h
	jr nz,l7e4ah
	dec hl
	or (hl)
	jr z,l7e96h
	dec hl
	push hl
	ld l,(hl)
	ld c,a
	and 007h
	ld h,a
	inc hl
	add hl,de
	xor c
	rrca
	rrca
	rrca
	add a,003h
	ld c,a
	exx
	in e,(c)
	out (c),b
	exx
	lddr
	exx
	out (c),e
	exx
	inc de
	pop hl
l7e96h:
	sbc hl,de
	add hl,de
	jr c,l7e4ah
	exx
	ld a,e
	cp b
	exx
	jr nz,l7e4ah
	ret
l7ea2h:
	ld bc,HMPR
	ld hl,00000h
	inc hl
	exx
	ld bc,HMPR
	ld hl,00000h
	di
l7eb1h:
	out (c),b
	dec hl
	bit 7,h
	jr nz,l7ebfh
	set 7,h
	res 6,h
	dec b
	out (c),b
l7ebfh:
	ld a,(hl)
	rlca
	ld a,(hl)
	res 7,a
	inc a
l7ec5h:
	dec hl
	bit 7,h
	jr nz,l7ed1h
	set 7,h
	res 6,h
	dec b
	out (c),b
l7ed1h:
	ex af,af'
	ld a,(hl)
	exx
	out (c),b
	dec hl
	out (0feh),a
	bit 7,h
	jr nz,l7ee4h
	set 7,h
	res 6,h
	dec b
	out (c),b
l7ee4h:
	ld (hl),a
	ex af,af'
	exx
	out (c),b
	dec a
	jr z,l7ef0h
	jr c,l7ed1h
	jr l7ec5h
l7ef0h:
	push bc
	push hl
	exx
	pop de
	pop af
	cp b
	jr nz,l7efch
	sbc hl,de
	add hl,de
	ret c
l7efch:
	exx
	jr nz,l7eb1h
	ret
sub_7f00h:
	ld a,001h
	ld hl,credits_end
	out (0fbh),a
	ld ix,l7f4ch
	ld a,000h
	ld de,00000h
	and 01fh
	inc de
	ld c,a
l7f14h:
	ld a,(hl)
	add a,(ix+000h)
	ld (ix+000h),a
	jr nc,l7f20h
	inc (ix+001h)
l7f20h:
	inc hl
	bit 6,h
	res 6,h
	in a,(0fbh)
	jr z,l7f2ch
	inc a
	out (0fbh),a
l7f2ch:
	and 01fh
	cp c
	jr nz,l7f14h
	and a
	sbc hl,de
	add hl,de
	jr nz,l7f14h
	ld hl,(l7f4ch)
	ld a,h
	or l
	ret z
	ld de,l7f4eh
	ld bc,0000ch
	call 00013h
	nop
	di
	halt
l7f49h:
	nop
l7f4ah:
	nop
	nop
l7f4ch:
	nop
	nop
l7f4eh:
	ld b,d
	ld b,c
	ld b,h
	jr nz,l7f96h
	ld c,b
	ld b,l
	ld b,e
	ld c,e
	ld d,e
	ld d,l
	ld c,l
l7f5ah:
	dec c
	jr nz,l7f7dh
	jr nz,l7f7fh
	jr nz,l7f81h
	ld d,b
	ld (hl),l
	ld (hl),h
	jr nz,l7faah
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
	jr nz,l7fd6h
	ld l,c
	ld (hl),e
	ld l,e
	dec c
	dec c
credits:

credits_start:
	defb 020h
	defb 020h
	defb 02ah
	defb 020h
	defb 02ah
	defb 020h
l7f7dh:
	defb 02ah
	defb 020h
l7f7fh:
	defb 020h
	defb 020h
l7f81h:
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
l7f96h:
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
	defb 020h
l7faah:
	defb 053h
	defb 059h
	defb 053h
	defb 054h
	defb 045h
	defb 04dh
	defb 020h
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
	defb 020h
l7fd6h:
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
	defb 081h
	defb 000h
	defb 085h
credits_end:
font:

font_start:
	defb 000h
l8001h:
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 000h
	defb 018h
	defb 000h
	defb 000h
	defb 024h
	defb 024h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 024h
	defb 07eh
	defb 024h
	defb 024h
	defb 07eh
	defb 024h
	defb 000h
	defb 000h
	defb 008h
	defb 03eh
	defb 038h
	defb 03eh
	defb 00eh
	defb 03eh
	defb 008h
	defb 000h
	defb 066h
	defb 06ch
	defb 018h
	defb 030h
	defb 066h
	defb 046h
	defb 000h
	defb 000h
	defb 018h
	defb 034h
	defb 018h
	defb 03ch
	defb 066h
	defb 03fh
	defb 000h
	defb 000h
	defb 008h
	defb 010h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 00ch
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 00ch
	defb 000h
	defb 000h
	defb 030h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 030h
	defb 000h
	defb 000h
	defb 000h
	defb 014h
	defb 008h
	defb 03eh
	defb 008h
	defb 014h
	defb 000h
	defb 000h
	defb 000h
	defb 008h
	defb 008h
	defb 03eh
	defb 008h
	defb 008h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 008h
	defb 008h
	defb 010h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 03eh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 018h
	defb 018h
	defb 000h
	defb 000h
	defb 000h
	defb 006h
	defb 00ch
	defb 018h
	defb 030h
	defb 060h
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 06eh
	defb 076h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 018h
	defb 038h
	defb 018h
	defb 018h
	defb 018h
	defb 03ch
	defb 000h
	defb 000h
	defb 03ch
	defb 046h
	defb 006h
	defb 03ch
	defb 060h
	defb 07eh
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 00ch
	defb 006h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 00ch
	defb 01ch
	defb 03ch
	defb 06ch
	defb 07eh
	defb 00ch
	defb 000h
	defb 000h
	defb 07eh
	defb 060h
	defb 07ch
	defb 006h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 03ch
	defb 060h
	defb 07ch
	defb 066h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 07eh
	defb 006h
	defb 00ch
	defb 018h
	defb 030h
	defb 030h
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 03ch
	defb 066h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 066h
	defb 03eh
	defb 006h
	defb 03ch
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 010h
	defb 000h
	defb 000h
	defb 010h
	defb 000h
	defb 000h
	defb 000h
	defb 010h
	defb 000h
	defb 000h
	defb 010h
	defb 010h
	defb 020h
	defb 000h
	defb 000h
	defb 00ch
	defb 018h
	defb 030h
	defb 018h
	defb 00ch
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 03eh
	defb 000h
	defb 03eh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 030h
	defb 018h
	defb 00ch
	defb 018h
	defb 030h
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 00ch
	defb 018h
	defb 000h
	defb 018h
	defb 000h
	defb 000h
	defb 03ch
	defb 04ah
	defb 056h
	defb 05eh
	defb 040h
	defb 03ch
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 066h
	defb 07eh
	defb 066h
	defb 066h
	defb 000h
	defb 000h
	defb 07ch
	defb 066h
	defb 07ch
	defb 066h
	defb 066h
	defb 07ch
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 060h
	defb 060h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 078h
	defb 06ch
	defb 066h
	defb 066h
	defb 06ch
	defb 078h
	defb 000h
	defb 000h
	defb 07eh
	defb 060h
	defb 07ch
	defb 060h
	defb 060h
	defb 07eh
	defb 000h
	defb 000h
	defb 07eh
	defb 060h
	defb 07ch
	defb 060h
	defb 060h
	defb 060h
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 060h
	defb 06eh
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 066h
	defb 066h
	defb 07eh
	defb 066h
	defb 066h
	defb 066h
	defb 000h
	defb 000h
	defb 03ch
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 03ch
	defb 000h
	defb 000h
	defb 006h
	defb 006h
	defb 006h
	defb 066h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 06ch
	defb 078h
	defb 070h
	defb 078h
	defb 06ch
	defb 066h
	defb 000h
	defb 000h
	defb 060h
	defb 060h
	defb 060h
	defb 060h
	defb 060h
	defb 07eh
	defb 000h
	defb 000h
	defb 042h
	defb 066h
	defb 07eh
	defb 066h
	defb 066h
	defb 066h
	defb 000h
	defb 000h
	defb 066h
	defb 066h
	defb 076h
	defb 06eh
	defb 066h
	defb 066h
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 066h
	defb 066h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 07ch
	defb 066h
	defb 066h
	defb 07ch
	defb 060h
	defb 060h
	defb 000h
	defb 000h
	defb 03ch
	defb 066h
	defb 066h
	defb 076h
	defb 06eh
	defb 03ch
	defb 000h
	defb 000h
	defb 07ch
	defb 066h
	defb 066h
	defb 07ch
	defb 06ch
	defb 066h
	defb 000h
	defb 000h
	defb 03ch
	defb 060h
	defb 03ch
	defb 006h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 07eh
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 000h
	defb 000h
	defb 066h
	defb 066h
	defb 066h
	defb 066h
	defb 066h
	defb 03ch
	defb 000h
	defb 000h
	defb 066h
	defb 066h
	defb 066h
	defb 066h
	defb 03ch
	defb 018h
	defb 000h
	defb 000h
	defb 066h
	defb 066h
	defb 066h
	defb 066h
	defb 07eh
	defb 024h
	defb 000h
	defb 000h
	defb 066h
	defb 03ch
	defb 018h
	defb 018h
	defb 03ch
	defb 066h
	defb 000h
	defb 000h
	defb 066h
	defb 03ch
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 000h
	defb 000h
	defb 07eh
	defb 006h
	defb 00ch
	defb 018h
	defb 030h
	defb 07eh
	defb 000h
	defb 000h
	defb 01eh
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 01eh
	defb 000h
	defb 000h
	defb 000h
	defb 060h
	defb 030h
	defb 018h
	defb 00ch
	defb 006h
	defb 000h
	defb 000h
	defb 078h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 078h
	defb 000h
	defb 000h
	defb 018h
	defb 03ch
	defb 05ah
	defb 018h
	defb 018h
	defb 018h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 000h
	defb 01ch
	defb 036h
	defb 078h
	defb 030h
	defb 030h
	defb 07eh
	defb 000h
	defb 000h
	defb 000h
	defb 038h
	defb 00ch
	defb 03ch
	defb 06ch
	defb 03ch
	defb 000h
	defb 000h
	defb 030h
	defb 030h
	defb 03ch
	defb 036h
	defb 036h
	defb 03ch
	defb 000h
	defb 000h
	defb 000h
	defb 01ch
	defb 030h
	defb 030h
	defb 030h
	defb 01ch
	defb 000h
	defb 000h
	defb 00ch
	defb 00ch
	defb 03ch
	defb 06ch
	defb 06ch
	defb 03ch
	defb 000h
	defb 000h
	defb 000h
	defb 038h
	defb 06ch
	defb 078h
	defb 060h
	defb 03ch
	defb 000h
	defb 000h
	defb 00ch
	defb 018h
	defb 01ch
	defb 018h
	defb 018h
	defb 018h
	defb 000h
	defb 000h
	defb 000h
	defb 03ch
	defb 06ch
	defb 06ch
	defb 03ch
	defb 00ch
	defb 038h
	defb 000h
	defb 060h
	defb 060h
	defb 078h
	defb 06ch
	defb 06ch
	defb 06ch
	defb 000h
	defb 000h
	defb 018h
	defb 000h
	defb 038h
	defb 018h
	defb 018h
	defb 03ch
	defb 000h
	defb 000h
	defb 00ch
	defb 000h
	defb 00ch
	defb 00ch
	defb 00ch
	defb 06ch
	defb 038h
	defb 000h
	defb 030h
	defb 03ch
	defb 038h
	defb 038h
	defb 03ch
	defb 036h
	defb 000h
	defb 000h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 00ch
	defb 000h
	defb 000h
	defb 000h
	defb 076h
	defb 06ah
	defb 06ah
	defb 06ah
	defb 06ah
	defb 000h
	defb 000h
	defb 000h
	defb 078h
	defb 06ch
	defb 06ch
	defb 06ch
	defb 06ch
	defb 000h
	defb 000h
	defb 000h
	defb 038h
	defb 06ch
	defb 06ch
	defb 06ch
	defb 038h
	defb 000h
	defb 000h
	defb 000h
	defb 078h
	defb 06ch
	defb 06ch
	defb 078h
	defb 060h
	defb 060h
	defb 000h
	defb 000h
	defb 03ch
	defb 06ch
	defb 06ch
	defb 03ch
	defb 00ch
	defb 00eh
	defb 000h
	defb 000h
	defb 01ch
	defb 030h
	defb 030h
	defb 030h
	defb 030h
	defb 000h
	defb 000h
	defb 000h
	defb 038h
	defb 060h
	defb 038h
	defb 00ch
	defb 078h
	defb 000h
	defb 000h
	defb 018h
	defb 03ch
	defb 018h
	defb 018h
	defb 018h
	defb 00ch
	defb 000h
	defb 000h
	defb 000h
	defb 06ch
	defb 06ch
	defb 06ch
	defb 06ch
	defb 038h
	defb 000h
	defb 000h
	defb 000h
	defb 06ch
	defb 06ch
	defb 038h
	defb 038h
	defb 010h
	defb 000h
	defb 000h
	defb 000h
	defb 062h
	defb 06ah
	defb 06ah
	defb 07eh
	defb 03eh
	defb 000h
	defb 000h
	defb 000h
	defb 06ch
	defb 038h
	defb 010h
	defb 038h
	defb 06ch
	defb 000h
	defb 000h
	defb 000h
	defb 06ch
	defb 06ch
	defb 06ch
	defb 03ch
	defb 00ch
	defb 038h
	defb 000h
	defb 000h
	defb 07ch
	defb 00ch
	defb 018h
	defb 030h
	defb 07ch
	defb 000h
	defb 000h
	defb 01eh
	defb 018h
	defb 078h
	defb 018h
	defb 018h
	defb 01eh
	defb 000h
	defb 000h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 018h
	defb 000h
	defb 000h
	defb 078h
	defb 018h
	defb 01ch
	defb 018h
	defb 018h
	defb 078h
	defb 000h
	defb 000h
	defb 014h
	defb 028h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 03ch
	defb 042h
	defb 099h
	defb 0a1h
	defb 0a1h
	defb 099h
	defb 042h
	defb 03ch
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 00fh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 00fh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 00fh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0f0h
	defb 000h
	defb 00fh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 00fh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 00fh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 0f0h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 00fh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 000h
	defb 0f0h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 000h
	defb 00fh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 000h
	defb 000h
	defb 0f0h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 000h
	defb 000h
	defb 00fh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 000h
	defb 00fh
	defb 0ffh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 0ffh
	defb 00fh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0ffh
	defb 00fh
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 00fh
	defb 0f0h
	defb 0f0h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0f0h
	defb 0f0h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 000h
	defb 0ffh
	defb 0f0h
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
	defb 0b0h
	defb 048h
	defb 048h
	defb 030h
	defb 040h
	defb 070h
	defb 088h
font_end:

