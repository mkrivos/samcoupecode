;==============================================================================
;  TURBO IMPLODER V1.0  -  RUMSOFT & SAPOSOFT '93  (file/memory packer)
;------------------------------------------------------------------------------
;  File:         IMPLO1.BIN  (2576 bytes)
;  Load address: &4000
;  Entry:        &4000 -> JP &43FB
;  Author note:  "Preklad: 18-10-93  Lipt. Mikulas"  (Marian Krivos)
;  STATUS: first pass - structure + both compression algorithms identified;
;          byte-exact (reassembles to the original). See IMPLO1.md.
;
;  WHAT IT DOES (per arch-pack_utils_info.txt):
;    Interactive packer. Prompts: Start, Length, Call, Name, Mode, Speed, Skip.
;    Produces a self-extracting ".PAK" file (default NONAME.PAK).
;
;  COMPRESSION (Mode is ASCII '1'..'3', tested bitwise):
;    Mode & 1  -> SHRINK  (shrink @ &4554)  = RLE: shrink_scan (&4665) finds
;                 runs of >=4 equal bytes and run-length-encodes them.
;    Mode & 2  -> IMPLODE (implode @ &476A) = LZ77/LZSS: implode_core (&483E)
;                 uses CPIR to find match candidates in a sliding window
;                 (max distance &0821 = 2081 B), extends to the longest match
;                 (min length 2), and emits literal / (length,distance) tokens
;                 via the bit emitter (emit @ &49EE). implode_fin (&4911) flushes.
;    Mode 3    -> both, cascaded (shrink then implode).
;    Speed (0..7) trades match-search effort for ratio.
;
;  OUTPUT (.PAK): a SAM CODE file. A header is built at &4B00 (type &13) and a
;    self-extracting depacker is relocated (to &4C00) and saved ahead of the
;    compressed data - same self-extracting approach as SKOMP1.
;
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC
;==============================================================================

	org	04000h
HMPR:	equ 0x00fb
shrink_core:	equ 0x4608

l4000h:
	jp start		; entry -> &43FB

t_preklad_start:
	defb 050h
	defb 072h
	defb 065h
	defb 06bh
	defb 06ch
	defb 061h
	defb 064h
	defb 03ah
	defb 020h
	defb 031h
	defb 038h
	defb 02dh
	defb 031h
	defb 030h
	defb 02dh
	defb 039h
	defb 033h
	defb 020h
	defb 020h
	defb 04ch
	defb 069h
	defb 070h
	defb 074h
	defb 02eh
	defb 020h
	defb 04dh
	defb 069h
	defb 06bh
	defb 075h
	defb 06ch
	defb 061h
	defb 073h
sub_4023h:
	defb 03eh
t_preklad_end:
	ld d,0d7h
	ld a,l
	rst 10h
	ld a,h
	rst 10h
	ret
sub_402bh:
	ei
l402ch:
	halt
	djnz l402ch
	ret
l4030h:
	ld d,002h
	defb 006h

t_title_start:
	defb 054h
	defb 055h
	defb 052h
	defb 042h
	defb 04fh
	defb 020h
	defb 049h
	defb 04dh
	defb 050h
	defb 04ch
	defb 04fh
	defb 044h
	defb 045h
	defb 052h
	defb 020h
	defb 020h
	defb 056h
	defb 031h
	defb 02eh
	defb 030h
t_title_end:
	ld d,004h
	inc b
	ld a,a

t_rumsoft_start:
	defb 020h
	defb 052h
	defb 055h
	defb 04dh
	defb 053h
	defb 04fh
	defb 046h
	defb 054h
	defb 020h
	defb 026h
	defb 020h
	defb 053h
	defb 041h
	defb 050h
	defb 04fh
	defb 053h
	defb 04fh
	defb 046h
	defb 054h
	defb 020h
	defb 027h
	defb 039h
	defb 033h
t_rumsoft_end:
	ld d,006h
	defb 006h

t_rights_start:
	defb 041h
	defb 04ch
	defb 04ch
	defb 020h
	defb 052h
	defb 049h
	defb 047h
	defb 048h
	defb 054h
	defb 053h
	defb 020h
	defb 052h
	defb 045h
	defb 053h
	defb 045h
	defb 052h
	defb 056h
	defb 045h
	defb 044h
t_rights_end:
	rst 38h
l4079h:
	ld d,009h
	nop

t_prompts_start:
	defb 053h
	defb 074h
	defb 061h
	defb 072h
	defb 074h
	defb 020h
	defb 03ah
	defb 016h
	defb 00ah
	defb 000h
	defb 04ch
	defb 065h
	defb 06eh
	defb 067h
	defb 068h
	defb 074h
	defb 03ah
	defb 016h
	defb 00bh
	defb 000h
	defb 043h
	defb 061h
	defb 06ch
	defb 06ch
	defb 020h
	defb 020h
	defb 03ah
	defb 016h
	defb 00ch
	defb 000h
	defb 04eh
	defb 061h
	defb 06dh
	defb 065h
	defb 020h
	defb 020h
	defb 03ah
	defb 016h
	defb 00dh
	defb 000h
	defb 04dh
	defb 06fh
	defb 064h
	defb 065h
	defb 020h
	defb 020h
	defb 03ah
	defb 016h
	defb 00eh
	defb 000h
	defb 053h
	defb 070h
	defb 065h
	defb 065h
	defb 064h
	defb 020h
	defb 03ah
	defb 016h
	defb 00fh
	defb 000h
	defb 053h
	defb 06bh
	defb 069h
	defb 070h
	defb 020h
	defb 020h
	defb 03ah
	defb 0ffh
l40c0h:
	defb 016h
	defb 011h
	defb 003h
	defb 054h
	defb 06fh
	defb 074h
	defb 061h
	defb 06ch
	defb 020h
	defb 06ch
	defb 065h
	defb 06eh
	defb 067h
	defb 068h
	defb 074h
	defb 03ah
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 062h
	defb 079h
	defb 074h
	defb 065h
	defb 016h
	defb 013h
	defb 004h
	defb 053h
	defb 061h
	defb 076h
	defb 065h
	defb 020h
	defb 074h
	defb 068h
	defb 065h
	defb 020h
	defb 066h
	defb 069h
	defb 06ch
	defb 065h
	defb 020h
	defb 03fh
	defb 020h
	defb 028h
	defb 079h
	defb 065h
	defb 073h
	defb 029h
	defb 020h
	defb 016h
	defb 011h
	defb 010h
	defb 0ffh
l40f8h:
	defb 016h
	defb 011h
	defb 003h
	defb 020h
	defb 020h
	defb 020h
	defb 059h
	defb 06fh
	defb 075h
	defb 020h
	defb 061h
	defb 072h
	defb 065h
	defb 020h
	defb 073h
	defb 075h
	defb 072h
	defb 065h
	defb 020h
	defb 03fh
	defb 020h
	defb 028h
	defb 079h
	defb 02fh
	defb 06eh
	defb 029h
	defb 020h
	defb 020h
	defb 020h
	defb 020h
	defb 0ffh
l4117h:
	defb 020h
l4118h:
	defb 04eh
	defb 04fh
	defb 04eh
	defb 041h
	defb 04dh
	defb 045h
	defb 02eh
	defb 050h
	defb 041h
	defb 04bh
l4122h:
	defb 000h
l4123h:
	defb 016h
	defb 011h
	defb 003h
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
t_prompts_end:
	rst 38h
l4137h:
	ld a,(hl)
	cp 0ffh
	ret z
	call 00010h
	inc hl
	jr l4137h
sub_4141h:
	push ix
l4143h:
	call 00169h
	jr z,l4143h
	push af
	ld hl,00064h
	ld de,00064h
	call 0016fh
	ld b,00ah
	call sub_402bh
	pop af
	pop ix
	ret
l415bh:
	ld hl,(04188h)
sub_415eh:
	call sub_4023h
	ld b,ixh
	inc b
l4164h:
	ld a,020h
	call 00010h
	djnz l4164h
	xor a
	inc a
	ret
input_field:
	ld (04188h),hl
	ld hl,04c00h
	ld b,ixh
l4176h:
	ld (hl),020h
	inc hl
	djnz l4176h
	ld (hl),b
	xor a
	ld (0419bh),a
	ld hl,05c3bh
	res 5,(hl)
l4185h:
	ld b,ixh
	ld hl,00000h
	ld a,016h
	call 00010h
	ld a,l
	call 00010h
	ld a,h
	call 00010h
	ld hl,04c00h
	ld c,000h
l419ch:
	ld a,l
	cp c
	ld a,07ch
	call z,00010h
	ld a,(hl)
	call 00010h
	inc hl
	djnz l419ch
	ld a,l
	cp c
	ld a,03ch
	call z,00010h
	call sub_4141h
	cp 007h
	ret z
	cp 00dh
	jp z,l415bh
	ld hl,l4185h
	push hl
	ld hl,0419bh
	cp 008h
	jr z,l41ebh
	cp 009h
	jr z,l41f0h
	cp 00ch
	jr z,l41fdh
	cp 00eh
	jr z,l41f6h
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
	ld h,04ch
l41e3h:
	ld a,(hl)
	or a
	ret z
	ex af,af'
	ld (hl),a
	inc hl
	jr l41e3h
l41ebh:
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ret
l41f0h:
	ld a,(hl)
	cp ixh
	ret nc
	inc (hl)
	ret
l41f6h:
	ld a,(hl)
	cp ixh
	ret z
	inc a
	jr l4201h
l41fdh:
	ld a,(hl)
	or a
	ret z
	dec (hl)
l4201h:
	ld l,a
	ld h,04ch
	ld e,l
	ld d,h
	dec e
l4207h:
	ld a,(hl)
	ldi
	or a
	jr nz,l4207h
	ex de,hl
	dec hl
	ld (hl),020h
	ret
parse_num:
	ld de,04c00h
	call sub_4230h
	call sub_4237h
	ex af,af'
	and a
	rl h
	rla
	rl h
	rla
	and a
	rrc h
	and a
	rrc h
	ld e,a
	or h
	or l
	ld a,e
	set 7,h
	ret
sub_4230h:
	ld a,(de)
	cp 020h
	ret nz
	inc de
	jr sub_4230h
sub_4237h:
	ld a,(de)
	inc de
	ld hl,00000h
	ex af,af'
	xor a
	ex af,af'
	ld b,010h
	cp 023h
	jr z,l424ch
	cp 026h
	jr z,l424ch
	ld b,00ah
	dec de
l424ch:
	ld a,(de)
	sub 030h
	cp 00ah
	jr c,l4255h
	sub 007h
l4255h:
	cp 010h
	jr c,l425bh
	sub 020h
l425bh:
	cp 010h
	ret nc
	inc de
	push de
	ex de,hl
	ld hl,00000h
	push bc
	ex af,af'
l4266h:
	add hl,de
	adc a,000h
	djnz l4266h
	ex af,af'
	ld d,b
	pop bc
	ld e,a
	ex af,af'
	add hl,de
	adc a,000h
	ex af,af'
	pop de
	jr l424ch
sub_4277h:
	cp 004h
	jr c,l427dh
	dec a
	ret
l427dh:
	push bc
	ld c,002h
	cp c
	jr z,l428ch
	jr nc,l428ah
	res 7,h
	and a
	jr z,l428ch
l428ah:
	set 6,h
l428ch:
	ld a,c
	dec a
	pop bc
	ret
sub_4290h:
	ld hl,04b00h
	ld (hl),013h
	inc hl
	ld b,01ah
l4298h:
	ld (hl),020h
	inc hl
	djnz l4298h
	ld b,00eh
l429fh:
	ld (hl),0ffh
	inc hl
	djnz l429fh
	ret
sub_42a5h:
	ld ix,00700h
	ld hl,0080bh
	call input_field
	jp z,l452dh
	call parse_num
	jr nz,l42c3h
	ld a,001h
	ld hl,00004h
	ld (04b25h),a
	ld (04b26h),hl
	ret
l42c3h:
	push af
	push hl
	call sub_4277h
	ld (04b25h),a
	ld (04b26h),hl
	pop hl
	ex de,hl
	ld hl,0080bh
	call sub_4023h
	pop af
	ex de,hl
	call page_fix
	ret
sub_42dch:
	ld hl,0080bh
	call sub_4023h
	ld hl,04b25h
	call addr_to_page
	jp page_fix
sub_42ebh:
	ld hl,0080eh
	call sub_4023h
	call sub_4141h
	cp 030h
	jr c,l42fch
	cp 038h
	jr c,l42feh
l42fch:
	ld a,030h
l42feh:
	push af
	sub 037h
	neg
	inc a
	ld (04874h),a
	ld (l4879h+2),a
	pop af
	rst 10h
	ret
sub_430dh:
	ld hl,0080fh
	call sub_4023h
	call sub_4141h
	cp 030h
	jr c,l431eh
	cp 03ah
	jr c,l4320h
l431eh:
	ld a,030h
l4320h:
	sub 030h
	ld h,a
	ld l,000h
	add hl,hl
	add hl,hl
	ld (sub_4330h+1),hl
	add a,030h
	rst 10h
	ret
sub_432eh:
	ld iyh,e
sub_4330h:
	ld de,00000h
	res 7,b
	set 7,h
	add hl,de
	bit 6,h
	res 6,h
	jr z,l433fh
	inc a
l433fh:
	push bc
	ex (sp),hl
	and a
	sbc hl,de
	res 7,h
	res 6,h
	jr nc,l434ch
	dec iyh
l434ch:
	ex (sp),hl
	pop bc
	cp 0ffh
	jp z,l4603h
	inc iyh
	jp z,l4603h
	dec iyh
	ret
sub_435bh:
	call sub_4141h
	cp 007h
	jp z,l452dh
	cp 0c1h
	ret nz
	ld hl,l4123h
	call l4137h
	ld hl,01311h
	ld ix,00a00h
	call input_field
	ld hl,04c00h
	ld de,04b01h
	ld bc,0000ah
	ldir
	ld ix,04b00h
	rst 8
	add a,c
	ld hl,04b50h
	ld de,04b00h
	ld bc,00050h
	ldir
	ld a,(04b1fh)
	and 01fh
	out (0fbh),a
	ld hl,(04b20h)
	ld a,(04b22h)
	ld de,(04b23h)
	res 7,d
	ld c,a
	rst 8
	add a,d
	ld hl,04b00h
	ld de,l4117h
	ld bc,0000bh
	ldir
	ld hl,00809h
	call sub_4023h
	ld hl,04b1fh
	call addr_to_page
	inc a
	call page_fix
	ld hl,0080ah
	call sub_4023h
	ld hl,04b22h
	call addr_to_page
	call page_fix
	ld a,(04b25h)
	cp 0ffh
	jr nz,l43deh
	call sub_42a5h
	jr l43f0h
l43deh:
	call sub_42dch
	ld a,(04b25h)
	ld hl,(04b26h)
	call sub_4277h
	ld (04b25h),a
	ld (04b26h),hl
l43f0h:
	ld hl,01311h
	ld ixh,014h
	call sub_415eh
	xor a
	ret
start:
	ld (l452dh+1),sp
l43ffh:
	call sub_4535h
	ld hl,l4030h
	call l4137h
	ld hl,l4079h
	call l4137h
	call sub_4290h
	call sub_435bh
	jp z,l4476h
	ld hl,00809h
	ld ix,00700h
	call input_field
	jp z,l452dh
	call parse_num
	jr nz,l442eh
	ld a,002h
	ld hl,08000h
l442eh:
	dec a
	ld (04b1fh),a
	ld (04b20h),hl
	ld hl,00809h
	call sub_4023h
	ld hl,04b1fh
	call addr_to_page
	inc a
	call page_fix
	ld ix,00700h
	ld hl,0080ah
	call input_field
	jp z,l452dh
	call parse_num
	jr nz,l445ch
	ld hl,00000h
	ld a,002h
l445ch:
	set 7,h
	ld (04b22h),a
	ld (04b23h),hl
	ld hl,0080ah
	call sub_4023h
	ld hl,04b22h
	call addr_to_page
	call page_fix
	call sub_42a5h
l4476h:
	ld ix,00a00h
	ld hl,0080ch
	call input_field
	cp 007h
	jp z,l452dh
	ld a,(04c00h)
	cp 020h
	jr z,l4497h
	ld de,l4118h
	ld hl,04c00h
	ld bc,0000ah
	ldir
l4497h:
	ld hl,0080ch
	call sub_4023h
	ld hl,l4118h
	ld b,00ah
l44a2h:
	ld a,(hl)
	rst 10h
	inc hl
	djnz l44a2h
	ld hl,0080dh
	call sub_4023h
	call sub_4141h
	cp 030h
	jr c,l44b8h
	cp 034h
	jr c,l44bah
l44b8h:
	ld a,033h
l44bah:
	ld (l4122h),a
	rst 10h
	call sub_42ebh
	call sub_430dh
	ld hl,l40f8h
	call l4137h
	call sub_4141h
	res 5,a
	cp 04eh
	jp z,l43ffh
	ld a,(l4122h)
	bit 0,a
	call nz,shrink
	ld hl,0080ah
	call sub_4023h
	ld hl,04b22h
	call addr_to_page
	call page_fix
	ld a,(l4122h)
	bit 1,a
	call nz,implode
	xor a
	out (0feh),a
	ld hl,l40c0h
	call l4137h
	ld hl,04b22h
	call addr_to_page
	call page_fix
	ld hl,l4118h
	ld de,04b01h
	ld bc,0000ah
	ldir
	ld ix,04b00h
	ld (ix+000h),013h
	inc (ix+025h)
	push ix
	call sub_42dch
	call sub_4141h
	pop ix
	res 5,a
	cp 04eh
	jr z,l452dh
	rst 8
	add a,h
l452dh:
	ld sp,00000h
	ei
	call 00166h
	ret
sub_4535h:
	xor a
	call 0014eh
	ld a,002h
	call 00112h
	ret
sub_453fh:
	push bc
	push de
	ld (04b25h),a
	ld (04b26h),hl
	ex de,hl
	ld hl,l4691h
	ld bc,00071h
	ldir
	ex de,hl
	pop de
	pop bc
	ret
shrink:
	di
	ld a,(04b25h)
	ld (046fbh),a
	ld hl,(04b26h)
	ld (046fdh),hl
	in a,(0fbh)
	push af
	call shrink_core
	exx
	in a,(0fbh)
	ld (046a2h),a
	ld a,b
	ld (046ach),hl
	out (c),b
	ld (046a4h),de
	ld (046aah),a
	call sub_453fh
	ld a,(04b1fh)
	ld c,a
	ld a,b
	sub c
	ld de,(04b20h)
	res 7,h
	res 7,d
	res 6,h
	res 6,d
	and a
	sbc hl,de
	sbc a,000h
	set 7,h
	res 6,h
	ld (04b22h),a
	ld (04b23h),hl
	pop af
	out (0fbh),a
	ret
sub_45a2h:
	dec bc
	bit 7,b
	jr z,l45b0h
	xor a
	or iyh
	ret z
	dec iyh
	ld bc,03fffh
l45b0h:
	inc e
	ld a,(hl)
	inc hl
	bit 6,h
	jr z,l45c0h
	push af
	in a,(0fbh)
	inc a
	out (0fbh),a
	res 6,h
	pop af
l45c0h:
	cp (hl)
	scf
	ret
l45c3h:
	inc e
	ld a,(hl)
sub_45c5h:
	dec e
	bit 7,e
	call nz,sub_45cch
	ld a,e
sub_45cch:
	ld (045d6h),a
	in a,(0fbh)
	push af
	ld (045e9h),a
	ld a,000h
	call sub_45deh
	pop af
	out (0fbh),a
	ret
sub_45deh:
	push hl
	exx
	pop de
	out (c),b
	ld (hl),a
	and 010h
	out (0feh),a
	ld a,000h
	cp b
	jr nz,l45f3h
	and a
	sbc hl,de
	add hl,de
	jr nc,l4603h
l45f3h:
	inc hl
	bit 6,h
	exx
	ret z
	exx
	inc b
	res 6,h
	exx
	ret
sub_45feh:
	ld a,(hl)
	inc hl
	cp (hl)
	dec hl
	ret
l4603h:
	xor a
	out (0feh),a
	rst 8
	ld bc,01f3ah
	ld c,e
	ld hl,(04b20h)
	ld iy,(04b21h)
	ld bc,(04b23h)
	call sub_4330h
	out (0fbh),a
	call shrink_scan
	jp nc,l4603h
	in a,(0fbh)
	push af
	push hl
	exx
	pop hl
	pop bc
	ld c,0fbh
	exx
l462bh:
	ld e,080h
l462dh:
	call sub_45a2h
	jp nc,l45c3h
	jr nz,l463eh
	bit 7,e
	jr nz,l462dh
	call sub_45c5h
	jr l462bh
l463eh:
	call sub_45c5h
	call sub_45feh
	jr z,l462bh
l4646h:
	ld e,000h
l4648h:
	ld a,(hl)
	call sub_45cch
	call sub_45a2h
	jp nc,l45c3h
	call sub_45feh
	jr nz,l465ch
	call sub_45c5h
	jr l462bh
l465ch:
	bit 7,e
	jr z,l4648h
	call sub_45c5h
	jr l4646h
;==============================================================================
; shrink_scan (&4665) - SHRINK (RLE) run detector.
; Walks the source (HL) while BC:IYH bytes remain, looking for a run of FOUR
; equal bytes in a row. Returns CF=1 with HL at the run start when one is found,
; or returns (CF=0 / Z) when the input is exhausted. Crosses 16K pages by
; bumping HMPR (&FB). The caller emits a run token for the match and literals
; otherwise - classic run-length encoding.
;==============================================================================
shrink_scan:
	ld a,(hl)		; A = byte
	inc hl
	cp (hl)			; equal to next ?
	jr nz,l4674h
	inc hl
	cp (hl)			; ...and the 3rd ?
	jr nz,l4673h
	inc hl
	cp (hl)			; ...and the 4th ? -> run of >=4 found
	jr z,l468ch
	dec hl
l4673h:
	dec hl
l4674h:
	dec bc			; advance / count down remaining length
	ld a,b
	or c
	jr nz,l467fh
	or iyh			; BC==0: also out of high-count ?
	ret z			; yes -> done (CF=0)
	ld hl,03fffh
l467fh:
	bit 6,h			; crossed into next 16K page ?
	jr z,shrink_scan
	res 6,h
	in a,(0fbh)		; advance HMPR to the next page
	inc a
	out (0fbh),a
	jr shrink_scan
l468ch:
	dec hl			; back up to the first byte of the run
	dec hl
	dec hl
	scf			; CF=1 = run found
	ret
l4691h:
	ld de,04c00h
	di
	ld bc,00071h
	call 00004h
	ldir
	jp 04c05h
	ld bc,HMPR
	ld hl,00000h
	inc hl
	exx
	ld bc,HMPR
	ld hl,00000h
l46aeh:
	out (c),b
	dec hl
	bit 7,h
	jr nz,l46bch
	set 7,h
	res 6,h
	dec b
	out (c),b
l46bch:
	ld a,(hl)
	rlca
	ld a,(hl)
	res 7,a
	inc a
l46c2h:
	dec hl
	bit 7,h
	jr nz,l46ceh
	set 7,h
	res 6,h
	dec b
	out (c),b
l46ceh:
	ex af,af'
	ld a,(hl)
	exx
	out (c),b
	dec hl
	bit 7,h
	jr nz,l46dfh
	set 7,h
	res 6,h
	dec b
	out (c),b
l46dfh:
	ld (hl),a
	ex af,af'
	exx
	out (c),b
	dec a
	jr z,l46ebh
	jr c,l46ceh
	jr l46c2h
l46ebh:
	push bc
	push hl
	exx
	pop de
	pop af
	cp b
	jr nz,l46f6h
	sbc hl,de
	add hl,de
l46f6h:
	exx
	jr nz,l46aeh
	ei
	ld a,001h
	ld hl,00004h
	jp 0005ch
addr_to_page:
	ld a,(hl)
	and 01fh
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl
	ret
page_fix:
	push hl
	ld c,a
	res 7,h
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
	ld a,030h
	ld c,001h
	call sub_4751h
	ld c,000h
	ld de,02710h
	call sub_4751h
	ld de,003e8h
	call sub_474eh
	ld de,00064h
	call sub_474eh
	ld de,0000ah
	call sub_474eh
	ld a,l
	add a,030h
	call 00010h
	pop hl
	ret
sub_474eh:
	ld bc,00000h
sub_4751h:
	push af
	ld a,b
	ld b,000h
	and a
l4756h:
	sbc hl,de
	sbc a,c
	jr c,l475eh
	inc b
	jr l4756h
l475eh:
	add hl,de
	adc a,c
	ld c,a
	ld a,b
	ld b,c
	add a,030h
	call 00010h
	pop af
	ret
implode:
	ld hl,(04b26h)
	ld a,(04b25h)
	ld (049c9h),a
	ld (049cbh),hl
	ld hl,(04b20h)
	ld bc,(04b23h)
	in a,(0fbh)
	push af
	ld a,(04b22h)
	ld e,a
	ld a,(04b1fh)
	di
	ld (04b1fh),a
	ld (04b20h),hl
	call sub_432eh
	ld e,iyh
	push af
	out (0fbh),a
	ld a,e
	push hl
	push bc
	push de
	call sub_47b1h
	pop de
	pop bc
	pop hl
	pop af
	out (0fbh),a
	call implode_core
	call implode_fin
	xor a
	out (0feh),a
	pop af
	out (0fbh),a
	ei
	ret
sub_47b1h:
	res 7,b
	call sub_47c1h
	ex af,af'
	ld (048dbh),a
	ld (048e5h),a
	ld (04997h),a
	ret
sub_47c1h:
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
l47d4h:
	in a,(0fbh)
	bit 6,h
	set 7,h
	res 6,h
	jr z,l47e1h
	inc a
	out (0fbh),a
l47e1h:
	out (0feh),a
	ld a,b
	or c
	jr nz,l47ech
	inc e
	dec e
	jr z,l480bh
	dec e
l47ech:
	dec bc
	ld a,(hl)
	inc hl
	ld ix,04f00h
	push hl
	ld l,a
	and 003h
	out (0feh),a
	ld h,000h
	add hl,hl
	ex de,hl
	add ix,de
	ex de,hl
	pop hl
	inc (ix+000h)
	jr nz,l47d4h
	inc (ix+001h)
	jr l47d4h
l480bh:
	ld a,001h
	ex af,af'
	ld ix,04f02h
	ld de,0ffffh
l4815h:
	ld c,(ix+000h)
	inc ix
	ld b,(ix+000h)
	inc ix
	ld a,b
	or c
	ret z
	ex af,af'
	inc a
	jr z,l483ah
	ex af,af'
	ld a,e
	cp c
	jr c,l4815h
	ld a,d
	cp b
	jr c,l4815h
	push bc
	pop de
	ex af,af'
	dec a
	ld (l483ah+1),a
	inc a
	ex af,af'
	jr l4815h
l483ah:
	ld a,001h
	ex af,af'
	ret
;==============================================================================
; implode_core (&483E) - IMPLODE (LZ77/LZSS) main loop.
; For each position it searches the already-seen window for the longest match:
;   - CPIR scans for a byte equal to the current one (candidate match start),
;   - the inner loop (l48a0h) extends the match comparing (DE) vs (HL),
;   - IXH keeps the best length so far (min useful length 2),
;   - BC limits the search distance to &0821 (2081 bytes) = the window size.
; A literal byte or a (length,distance) match token is then written through the
; bit emitter (emit @ &49EE). implode_fin (&4911) flushes the last bits.
; HMPR (&FB) is bumped to walk across 16K pages. Heavily register-juggled and
; self-modifying - Ghidra's Z80 decompiler mangles this; read it here.
;==============================================================================
implode_core:
	call emit_init
l4841h:
	ld a,(de)
	call emit
	inc de
	ex af,af'
	bit 6,d
	jr z,l4852h
	res 6,d
	in a,(0fbh)
	inc a
	out (0fbh),a
l4852h:
	dec bc
	ld a,b
	or c
	jr nz,l4861h
	or iyh
	jp z,l4904h
	ld bc,l4000h
	jr l4869h
l4861h:
	bit 7,b
	jr z,l486bh
	res 7,b
	res 6,b
l4869h:
	dec iyh
l486bh:
	push hl
	push bc
	ld a,iyh
	and a
	jr nz,l4879h
	ld hl,00821h
	sbc hl,bc
	jr nc,l487ch
l4879h:
	ld bc,00821h
l487ch:
	ld h,d
	ld l,e
	ld ixh,002h
l4881h:
	ex af,af'
	cpir
	ex af,af'
	scf
	push hl
	sbc hl,de
	bit 3,h
	ex (sp),hl
	exx
	pop bc
	exx
	jr nz,l48bbh
	push bc
	push de
	push hl
	ld a,b
	and a
	ld a,021h
	jr nz,l489dh
	cp c
	jr nc,l489eh
l489dh:
	ld c,a
l489eh:
	ld b,c
	inc b
l48a0h:
	dec b
	jr z,l48a9h
	ld a,(de)
	cp (hl)
	inc de
	inc hl
	jr z,l48a0h
l48a9h:
	ld a,c
	sub b
	cp ixh
	jr c,l48b5h
	ld ixh,a
	exx
	ld d,b
	ld e,c
	exx
l48b5h:
	cp c
	pop hl
	pop de
	pop bc
	jr nz,l4881h
l48bbh:
	pop bc
	pop hl
	ld a,ixh
	sub 002h
	jr z,l48e3h
	exx
	add a,a
	add a,a
	add a,a
	or d
	ex af,af'
	ld a,e
	exx
l48cbh:
	dec bc
	inc de
	dec ixh
	jr nz,l48cbh
	call emit
	inc hl
	ex af,af'
l48d6h:
	call emit
	inc hl
	ld a,003h
	call emit
	inc hl
	jp l4841h
l48e3h:
	ex af,af'
	sub 003h
	inc hl
	jp nz,l4841h
	inc hl
	call emit_flush
	dec hl
	dec hl
	jr c,l48d6h
	ld (04b00h),hl
	ld (04b02h),de
	in a,(0fbh)
	ld iyh,a
	ld (04b04h),iy
	jp l4603h
l4904h:
	ld a,iyl
	inc hl
	ld (04b25h),a
	ld (04b26h),hl
	ld (04968h),a
	ret
implode_fin:
	push hl
	ex de,hl
	ld (04965h),hl
	ld hl,(04b20h)
	ld (04962h),de
	in a,(0fbh)
	ld (0496eh),a
	ld a,(04b1fh)
	ld c,a
	ld a,iyl
	ex de,hl
	res 7,h
	res 7,d
	and a
	sbc hl,de
	sbc a,c
	res 7,h
	res 6,h
	ld bc,0007eh
	add hl,bc
	bit 6,h
	jr z,l493eh
	inc a
l493eh:
	ld (04b22h),a
	ld (04b23h),hl
	pop de
	ld a,iyl
	out (0fbh),a
	ld hl,l4952h
	ld bc,0007eh
	ldir
	ret
l4952h:
	call 00004h
	ld bc,0007eh
	ld de,04c00h
	ldir
	or a
	jp 04c0ch
	ld hl,00000h
	ld de,00000h
	ld a,000h
	out (0fbh),a
	exx
	ld bc,HMPR
	exx
l4970h:
	ld a,0a0h
	cp h
	jr c,l497ch
	set 6,h
	in a,(0fbh)
	dec a
	out (0fbh),a
l497ch:
	dec hl
	ld a,(hl)
	ex af,af'
	ld a,0a0h
	cp d
	jr c,l4989h
	exx
	dec b
	exx
	set 6,d
l4989h:
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
	jr nz,l4970h
	dec hl
	or (hl)
	jr z,l49bch
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
l49bch:
	sbc hl,de
	add hl,de
	jr c,l4970h
	exx
	ld a,e
	cp b
	exx
	jr nz,l4970h
	ei
	ld a,001h
	ld hl,00004h
	jp 0005ch
	nop
emit_flush:
	ld (l49e0h+1),a
	in a,(0fbh)
	cp iyl
	ccf
	ret nc
	jr nz,l49e0h
	ccf
	sbc hl,de
	add hl,de
l49e0h:
	ld a,000h
	ret
emit_init:
	ld iyh,e
	ld iyl,a
	out (0fbh),a
	ld d,h
	ld e,l
	res 7,b
	ret
emit:
	push af
	in a,(0fbh)
	ld (04a0bh),a
	ld a,iyl
	bit 6,h
	res 6,h
	jr z,l49fdh
	inc a
l49fdh:
	out (0fbh),a
	ld iyl,a
	pop af
	push af
	ld (hl),a
	and 010h
	or 080h
	out (0feh),a
	ld a,000h
	out (0fbh),a
	pop af
	ret

