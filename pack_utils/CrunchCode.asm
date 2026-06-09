;==============================================================================
;  CrunchCode  -  foreign SAM Coupe cruncher (unknown author)
;------------------------------------------------------------------------------
;  File: CrunchCode (782 bytes).  Load address: &8000.  Byte-exact (reassembles).
;  NOT related to the RUMSOFT/SAPOSOFT tools here (0% shared code). See CrunchCode.md.
;
;  Three entry vectors at the load address:
;    &800E  crunch        - PACK   (frequency analysis -> 2-bit rank codes)
;    &8025  decrunch      - UNPACK  (the depacker)
;    &803F  decrunch_out  - unpack, then stream the result out via OTDR to
;                           port &F8 (after waiting for status &C0 on &F8)
;  Each saves SP at &800C, runs with SP=0 / IFF off, then restores LMPR & SP.
;
;  ALGORITHM = RLE pre-pass + a static frequency-rank entropy code (NOT LZ):
;    1. histogram (&81CB) counts byte frequencies into &8400 (256 x 16-bit).
;       find_escape (&81F1) picks the least-frequent byte (-> &9C40, used as a
;       marker). rle_pass (&80B0)/run_count (&80D2) RLE the data (run-length
;       thresholds 4 and &103=259).
;    2. build_ranktab (&8212) sorts the (up to 84) bytes by frequency -> a
;       rank table at &9C41 (saved with the file); inverse byte->rank at &8600.
;    3. emit_codes (&814C) writes a 2-bit-CLASS prefix code (bit_write &81BB,
;       2 bits at a time):
;          class 0 (00) + 2 index bits  -> rank 0..3     (4-bit code)
;          class 1 (01) + 4 index bits  -> rank 4..19    (6-bit code)
;          class 2 (10) + 6 index bits  -> rank 20..83   (8-bit code)
;          class 3 (11) + 8 raw bits    -> escape: literal byte not in the table
;       i.e. frequent bytes get short codes (quasi-Huffman, 3 length classes).
;    decrunch_core (&8256) is the inverse: bit_read (&82FD) pulls the 2-bit
;    class, decodes the rank/raw byte and expands the RLE.
;
;  Work areas: &8400 histogram, &8600 byte->rank, &9C40 escape byte,
;              &9C41 rank->byte table, &9C95 bitstream pointer; output from &0000.
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC ; &F8 = output device.
;==============================================================================

	org	08000h

	jp crunch		; &800E pack
	jp decrunch		; &8025 unpack (depacker)
	jp decrunch_out		; &803F unpack + stream out to port &F8
l8009h:
	ld c,000h
	nop
l800ch:
	nop
	nop
crunch:
	di
	ld (l800ch),sp
	ld sp,00000h
	in a,(0fah)
	push af
	call crunch_core
	pop af
	out (0fah),a
	ld sp,(l800ch)
	ei
	ret
decrunch:
	di
	ld (l800ch),sp
	ld sp,00000h
	in a,(0fah)
	push af
	call decrunch_core
	call sub_8073h
l8036h:
	pop af
	out (0fah),a
	ld sp,(l800ch)
	ei
	ret
decrunch_out:
	di
	ld (l800ch),sp
	ld sp,00000h
	in a,(0fah)
	push af
	call decrunch_core
	call sub_8073h
	jr c,l8036h
l8052h:
	ld a,001h
	in a,(0f8h)
	cp 0c0h
	jr nz,l8052h
	ld hl,0600fh
	ld bc,010f8h
	otdr
	in a,(0fah)
	and 01fh
	or 060h
	out (0fch),a
	pop af
	out (0fah),a
	ld sp,(l800ch)
	ei
	ret
sub_8073h:
	push af
	ld a,000h
	sbc a,000h
	ld h,a
	ld l,a
	ld (l8009h+1),hl
	pop af
	ret
crunch_core:
	in a,(0fch)
	and 01fh
	or 020h
	out (0fah),a
	ld hl,06010h
	ld (l8009h+1),hl
	call histogram
	call find_escape
	call rle_pass
	ld (l8009h+1),hl
	ld b,h
	ld c,l
	ld hl,09c41h
	ld de,00000h
	ldir
	call histogram
	call build_ranktab
	call emit_codes
	ld (l8009h+1),hl
	ret
rle_pass:
	ld iy,09c40h
	exx
	ld hl,09c41h
	exx
	ld ix,00000h
	ld de,06010h
l80c0h:
	call run_count
	push af
	call sub_80ebh
	pop af
	jr c,l80c0h
	exx
	ld bc,09c41h
	or a
	sbc hl,bc
	ret
run_count:
	ld a,(ix+000h)
	ld hl,00000h
l80d8h:
	inc hl
	dec e
	jr nz,l80e0h
	dec d
	jp m,l80e9h
l80e0h:
	inc ix
	cp (ix+000h)
	jr z,l80d8h
	scf
	ret
l80e9h:
	and a
	ret
sub_80ebh:
	cp (iy+000h)
	jr z,l812ah
l80f0h:
	or a
	ld bc,00103h
	sbc hl,bc
	jr c,l8107h
	exx
	ld c,(iy+000h)
	ld (hl),c
	inc hl
	ld (hl),a
	inc hl
	ld (hl),0ffh
	inc hl
	exx
	ret z
	jr l80f0h
l8107h:
	add hl,bc
	or a
	ld bc,00004h
	sbc hl,bc
	jr c,l811fh
	exx
	ld c,(iy+000h)
	ld (hl),c
	inc hl
	ld (hl),a
	inc hl
	exx
	ld a,l
	exx
	ld (hl),a
	inc hl
	exx
	ret
l811fh:
	add hl,bc
	ld b,l
	push bc
	exx
	pop bc
l8124h:
	ld (hl),a
	inc hl
	djnz l8124h
	exx
	ret
l812ah:
	ld a,h
	and a
	jr z,l813dh
l812eh:
	exx
	ld c,(iy+000h)
	ld (hl),c
	inc hl
	ld (hl),c
	inc hl
	ld (hl),000h
	inc hl
	exx
	dec h
	jr nz,l812eh
l813dh:
	ld a,l
	and a
	ret z
	exx
	ld c,(iy+000h)
	ld (hl),c
	inc hl
	ld (hl),c
	inc hl
	ld (hl),a
	inc hl
	exx
	ret
emit_codes:
	ld ix,00000h
	ld hl,09c95h
	ld de,00400h
	exx
	ld de,(l8009h+1)
	ld hl,08600h
	exx
l815fh:
	exx
	ld a,d
	or e
	jr z,l8182h
	dec de
	ld a,(ix+000h)
	inc ix
	ld l,a
	ld a,(hl)
	exx
	cp 0ffh
	jr nz,l8199h
	ld a,003h
	call bit_write
	ld b,004h
	ld a,(ix-001h)
l817bh:
	call bit_write
	djnz l817bh
	jr l815fh
l8182h:
	exx
	ld a,003h
	call bit_write
	ld a,(09c40h)
	ld b,008h
l818dh:
	call bit_write
	djnz l818dh
	ld de,09c40h
	or a
	sbc hl,de
	ret
l8199h:
	cp 004h
	jr c,l81b5h
	cp 014h
	jr c,l81abh
	ld b,004h
	sub 014h
	add a,a
	add a,a
	or 002h
	jr l817bh
l81abh:
	ld b,003h
	sub 004h
	add a,a
	add a,a
	or 001h
	jr l817bh
l81b5h:
	ld b,002h
	add a,a
	add a,a
	jr l817bh
bit_write:
	srl a
	rr e
	srl a
	rr e
	dec d
	ret nz
	ld (hl),e
	ld e,d
	ld d,004h
	inc hl
	ret
histogram:
	ld hl,08400h
	ld bc,001ffh
	ld de,08401h
	ld (hl),000h
	ldir
	ld de,00000h
	ld bc,(l8009h+1)
	ld hl,08400h
l81e2h:
	ld a,(de)
	ld l,a
	inc de
	inc (hl)
	jr nz,l81ebh
	inc h
	inc (hl)
	dec h
l81ebh:
	dec bc
	ld a,b
	or c
	jr nz,l81e2h
	ret
find_escape:
	ld de,0ffffh
	ld bc,08400h
l81f7h:
	ex af,af'
	ld a,(bc)
	ld l,a
	inc b
	ld a,(bc)
	ld h,a
	dec b
	ex af,af'
	or a
	sbc hl,de
	jr nc,l820bh
	ld a,(bc)
	ld e,a
	inc b
	ld a,(bc)
	ld d,a
	dec b
	ld a,c
l820bh:
	inc c
	jr nz,l81f7h
	ld (09c40h),a
	ret
build_ranktab:
	ld hl,08600h
l8215h:
	ld (hl),0ffh
	inc l
	jr nz,l8215h
	xor a
	ld ix,09c41h
l821fh:
	push af
	ld de,00000h
	ld bc,08400h
	xor a
l8227h:
	ex af,af'
	ld a,(bc)
	ld l,a
	inc b
	ld a,(bc)
	ld h,a
	dec b
	ex af,af'
	or a
	sbc hl,de
	jr c,l823bh
	ld a,(bc)
	ld e,a
	inc b
	ld a,(bc)
	ld d,a
	dec b
	ld a,c
l823bh:
	inc c
	jr nz,l8227h
	ld (ix+000h),a
	inc ix
	ld c,a
	xor a
	ld (bc),a
	inc b
	ld (bc),a
	inc b
	pop af
	ex af,af'
	ld a,d
	or e
	ret z
	ex af,af'
	ld (bc),a
	inc a
	cp 054h
	jr nz,l821fh
	ret
decrunch_core:
	ld a,(l8009h)
	and 01fh
	or 020h
	out (0fah),a
	ld hl,09c95h
	ld ix,09c41h
	ld d,(hl)
	inc hl
	ld e,(hl)
	ld b,004h
	exx
	ld de,00000h
	ld b,001h
l8271h:
	ld a,d
	cp 061h
	ccf
	ret c
	exx
	ld a,d
	call bit_read
	and 003h
	and a
	jr z,l82c6h
	dec a
	jr z,l82d4h
	dec a
	jr z,l82e7h
	ld a,d
	cp (ix+000h)
	ret z
	call bit_read
	call bit_read
	call bit_read
	call bit_read
l8297h:
	exx
	djnz l82a9h
	cp (ix-001h)
	jr z,l82a5h
	ld b,001h
	ld (de),a
	inc de
	jr l8271h
l82a5h:
	ld b,002h
	jr l8271h
l82a9h:
	djnz l82b0h
	ld c,a
	ld b,003h
	jr l8271h
l82b0h:
	ld b,a
	ld a,c
	cp (ix-001h)
	jr z,l82beh
	ld (de),a
	inc de
	ld (de),a
	inc de
	ld (de),a
	inc de
	inc b
l82beh:
	ld (de),a
	inc de
	djnz l82beh
	ld b,001h
	jr l8271h
l82c6h:
	ld a,d
	call bit_read
	and 003h
	ld (082d1h),a
	ld a,(ix+000h)
	jr l8297h
l82d4h:
	ld a,d
	call bit_read
	call bit_read
	and 00fh
	add a,004h
	ld (082e4h),a
	ld a,(ix+000h)
	jr l8297h
l82e7h:
	ld a,d
	call bit_read
	call bit_read
	call bit_read
	and 03fh
	add a,014h
	ld (082fah),a
	ld a,(ix+000h)
	jr l8297h
bit_read:
	srl e
	rr d
	srl e
	rr d
	dec b
	ret nz
	ld b,004h
	inc hl
	ld e,(hl)
	ret
	sbc hl,bc

