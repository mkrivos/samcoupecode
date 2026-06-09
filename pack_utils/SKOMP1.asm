;==============================================================================
;  SKOMP  v2.0  -  RUMSOFT screen compressor for the SAM Coupe
;------------------------------------------------------------------------------
;  File:         SKOMP1.BIN  (678 bytes)
;  Load address: &4000
;  Entry point:  &4000  ->  JP &400C
;  Signatures:   "RUMSOFT", "*** Version 2.0 ***",
;                "PREKLAD: 30.09.93  ZDRAVIM RECALL SOFT ..."
;
;  Disassembled with z80dasm 1.1.6 + manual annotation (Claude Code).
;  Original address and raw bytes are in the trailing comment of each line
;  (;address  bytes  ascii).
;
;------------------------------------------------------------------------------
;  WHAT THE PROGRAM DOES
;------------------------------------------------------------------------------
;  It is a SCREEN compressor for the SAM Coupe. When started it:
;    1. Picks the data length from system variable &5A40 (the mode):
;          0    -> &1B00 (6912 B, classic screen)
;          1    -> &3800 (14336 B)
;          >=2  -> &6000 (24576 B, full SAM mode-4 screen)
;    2. Converts the target Z80 address (&4009, default &8000) into a SAM
;       (page, offset) pair - paged memory is controlled via LMPR/HMPR/VMPR.
;    3. Pages the VIDEO page into section C (&8000..&BFFF) through HMPR (&FB),
;       so the screen contents become visible at &8000.
;    4. Calls COMPRESS (&41C5): compresses the screen from &8000 into &E000.
;    5. Builds a SELF-CONTAINED depacker from the DEPACKER template (&40FF,
;       198 B), patches it with the concrete parameters (length, target,
;       first byte, ...) and copies it to &8000.
;    6. The result = [depacker + compressed data] is prepared/saved via ROM.
;
;  Compression scheme (RLE over the "previous byte" + a control bit stream):
;    - COMPRESS reads bytes and compares each with the previous one (reg E).
;    - A control BIT STREAM is produced (1 bit per byte: "same as previous"
;      / "different"), into which run lengths are interleaved.
;    - C_FLUSH (&4240) encodes the run lengths into the output; the values
;      &00 and &FF carry a special meaning (separators / escape).
;    - The DEPACKER reads this bit stream and rebuilds the screen run by run.
;
;  NOTE: the code is heavily SELF-MODIFYING and uses both register banks
;        (exx) - one bank holds the INPUT context (reading), the other the
;        OUTPUT / bit-buffer context. z80dasm prints "self modifying code"
;        warnings while assembling - that is expected.
;
;  FILE MEMORY MAP (&4000..&42A5):
;    &4000        JP &400C                  entry jump
;    &4003..&400B header / self-modified variables (parameters)
;    &400C..&40E8 MAIN  - main driver routine
;    &40E9..&40FE text  " *** Version 2.0 *** "
;    &40FF..&41C4 DEPACKER - depacker template (runs relocated at &8000)
;       inside it: &4196..&419C "RUMSOFT", &419D..&41C4 40-byte table
;    &41C5..&427B COMPRESS + C_FLUSH - the compressor (runs only when packing)
;    &427C..&42A5 signature text "PREKLAD: 30.09.93 ..."
;
;  SAM Coupe ports:  LMPR=&FA  HMPR=&FB  VMPR=&FC
;==============================================================================


	org	04000h

; --- SAM ROM routines (ROM mapped at &0000) ---
ROM_0004:	equ 0x0004 ; ROM helper (returns a pointer in HL)
ROM_005C:	equ 0x005c ; ROM entry used after re-paging
ROM_012D:	equ 0x012d ; ROM block copy / page-aware move
ROM_015A:	equ 0x015a ; ROM helper (mode-dependent setup)
; --- source / system variables ---
SRC_55D8:	equ 0x55d8 ; source of the 40-byte table copied into the depacker
SVAR_5A40:	equ 0x5a40 ; mode selector (0/1/>=2 -> length 1B00/3800/6000)

l4000h:
	jp hdr_end		; entry: skip the header, jump to MAIN
hP_PAGE:

;------------------------------------------------------------------------------
; HEADER / self-modified parameter block (&4003..&400B)
; These bytes are written by MAIN and read back later; they are the parameters
; of the pack operation. In the raw file they hold the default values below.
;------------------------------------------------------------------------------
hdr_start:
	defb 000h		; hP_PAGE: computed SAM page of the target address
hP_OFFS:
	defb 000h		; hP_OFFS: computed offset within section C (lo)
	defb 000h		; (hi, normally &8x)
hP_LEN:
	defb 000h		; hP_LEN: data length (lo) - set from the &5A40 mode
	defb 000h		; (hi)
hP_FLAG:
	defb 000h		; hP_FLAG: flag (default 0)
hP_DEST:
	defb 000h		; hP_DEST: decompress target address (lo)
	defb 080h		; (hi) -> default &8000
hP_BYTE:
	defb 000h		; hP_BYTE: scratch byte (RLE marker, start of input)
hdr_end:

;==============================================================================
; MAIN  (&400C)  -  driver: set up paging, compress screen, build depacker
;==============================================================================
	di		; disable interrupts (paging is about to change)
; --- choose data length from the mode in &5A40 --------------------------------
	ld a,(SVAR_5A40)		; A = mode
	and a		; mode == 0 ?
	jr nz,l4016h
	ld hl,01b00h		; mode 0 -> HL = &1B00 (6912)
l4016h:
	cp 001h		; mode == 1 ?
	jr nz,l401dh
	ld hl,03800h		; mode 1 -> HL = &3800 (14336)
l401dh:
	cp 002h		; mode >= 2 ?
	jr c,l4024h
	ld hl,06000h		; mode>=2 -> HL = &6000 (24576)
l4024h:
	ld (hP_LEN),hl		; store chosen length
; --- convert target address (hP_DEST) into SAM (page, offset) -----------------
	ld a,(hP_FLAG)		; A = flag (high page bits seed)
	ld hl,(hP_DEST)		; HL = target address (&8000)
	ld de,l4000h		; DE = &4000 (paging base)
	and a		; clear carry
	sbc hl,de		; HL = target - &4000
	sbc a,000h		; propagate borrow into A
	rlc h
	rla
	rlc h		; > page = (target-&4000) / 16384
	rla		; | A = page number
	srl h
	srl h		; / HL = offset within a 16K page
	set 7,h		; force offset into section C (&8000..)
	ld (hP_PAGE),a		; save page
	ld (hP_OFFS),hl		; save offset
; --- page the VIDEO page into section C so the screen appears at &8000 ---------
	in a,(0fch)		; A = VMPR (current video page)
	and 01fh		; keep page bits
	out (0fbh),a		; HMPR = video page -> screen @ &8000
; --- copy a 40-byte table from &55D8 into the depacker template (&419D) --------
	ld hl,SRC_55D8		; src = &55D8
	ld de,rumsoft_end		; dst = &419D (table inside template)
	ld bc,00028h		; bytes
	ldir
; --- patch the DEPACKER template with the run-time parameters ------------------
	ld hl,(hP_OFFS)
	push hl
	ld a,(SVAR_5A40)		; mode ...
	ld (l4112h+1),a		; ... patched into depacker @ &8013
	ld hl,(hP_LEN)		; length ...
	ld (04141h),hl		; ... patched into depacker @ &8042
	pop hl
	push hl
	push hl
	pop de
	ld hl,(hP_OFFS)
	ld bc,00091h		; +&91 (offset to compressed data area)
	add hl,bc
	ld (04159h),hl		; patch depacker jp-target @ &805A
; --- compress the screen (&8000) into &E000 -----------------------------------
	call table_end		; call COMPRESS (&41C5)
; --- relocate/move the compressed result and compute its size -----------------
	exx		; back to main bank (DE = end of compressed)
	push de
	ld hl,0df39h		; move a buffer down in memory ...
	ld de,0dfffh
	ld bc,05f3ah
	lddr
	ld de,000c6h		; &C6 = size of the depacker template
	pop hl
	res 7,h		; normalise high bit of pointer
	ld (0413ah),hl		; patch end-pointer into depacker @ &803B
	add hl,de
	ld de,(hP_OFFS)
	add hl,de
	ld de,0e001h		; compressed data starts at &E001
	and a
	push ix		; IX = end of compressed output (from COMPRESS)
	ex (sp),hl
	sbc hl,de		; HL = IX - &E001 = compressed length
	ld b,h		; BC = compressed length (for LDIR)
	ld c,l
	pop hl
	ld de,(hP_OFFS)
	res 7,d
	sbc hl,de
	ex de,hl
	ld hl,0e001h		; HL = &E001 (compressed source)
	ld a,(hl)		; first compressed byte ...
	ld (0414ah),a		; ... patched into depacker @ &804B
	ldir		; copy compressed data to its final place
; --- copy the patched DEPACKER template to &8000 (it will run there) ----------
	push de
	ld hl,ver_end		; src = template @ &40FF
	ld de,08000h		; dst = &8000
	ld bc,000c6h		; 198 bytes
	ldir
	pop hl
	push hl
	xor a
	bit 6,h		; test/clear high page bits of the pointer
	res 6,h
	res 7,h
	jr z,l40cbh
	inc a		; page wrapped -> bump page count
l40cbh:
	ld (05b83h),a		; store result page (sys var &5B83)
	ld (05b84h),hl		; store result address (sys var &5B84)
; --- hand the finished [depacker+data] block to the ROM, restore, return ------
	ld a,(hP_PAGE)		; A = page
	ld de,(hP_OFFS)		; DE = offset
	ld c,a
	ld hl,08000h		; HL = &8000 (built block)
	in a,(0fbh)
	and 01fh
	call ROM_012D		; ROM page-aware copy/finalise
	pop bc
	pop hl
	res 7,b
	ei		; re-enable interrupts
	ret		; done

;------------------------------------------------------------------------------
; DATA: version banner text " *** Version 2.0 *** "  (&40E9..&40FE)
;------------------------------------------------------------------------------
ver_start:
	defm " ***  Version 2.0 *** "
ver_end:
;==============================================================================
; DEPACKER template  (&40FF..&41C4, 198 bytes)
;------------------------------------------------------------------------------
; This is the run-time unpacker. MAIN copies it to &8000 (so it RUNS at &8000)
; after patching five immediates inside it:
;   &8013 = mode      &803B = end pointer   &8042 = length
;   &804B = first byte &805A = jp-target
; Addresses below are the TEMPLATE addresses (&40FF-based); add (&8000-&40FF)
; to get the run-time address. It rebuilds the screen from the compressed
; stream and re-pages the video page so the picture reappears, then RETs.
;==============================================================================
DEPACKER:
	call ROM_0004		; get a pointer in HL
	bit 7,h		; target in a high page ?
	jr z,l4112h
	bit 6,h
	jr z,l4112h
	in a,(0fbh)		; adjust HMPR (move target page up)
	inc a
	res 6,h
	jp ROM_005C		; continue in ROM with fixed paging
l4112h:
	ld a,000h		; A = mode (PATCHED by MAIN @ &8013)
	call ROM_015A		; ROM: mode-dependent screen setup
	di
	call ROM_0004
	ld de,0003eh
	add hl,de
	push hl
	ld de,00037h
	add hl,de
	pop de
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	ex de,hl
	ld de,0000dh
	add hl,de
	ld de,SRC_55D8
	ld bc,00028h
	ldir
	ld de,00000h
	ld bc,01111h
	add hl,bc
	push hl
	sbc hl,bc
	ld bc,06000h
	exx		; -> alt bank = INPUT (compressed) context
	ld bc,00080h		; C = &80 = initial bit mask (top bit)
	pop hl
	push hl
	ld (hl),000h
	pop ix		; IX = compressed-stream pointer
	exx		; -> back to main bank = OUTPUT context
; --- page the screen page into section A (&0000-&3FFF) via LMPR ----------------
	in a,(0fch)		; A = VMPR
	and 01fh
	or 020h
	out (0fah),a		; LMPR = video page (screen now writable)
; --- main decompression loop --------------------------------------------------
l4156h:
	ldi		; emit one byte, dec output counter BC
	jp po,00059h		; BC==0 ? -> finished (PATCHED target @ &805A)
	exx		; switch to INPUT context
	rlc c		; rotate control bit out of the mask
	jr c,l4168h		; carry -> a control/run code follows
l4160h:
	ld a,c		; test next control bit
	and (hl)
	exx		; back to OUTPUT context
	jr nz,l4156h		; bit set -> copy literal byte (loop)
	dec hl		; bit clear -> repeat previous byte
	jr l4156h
l4168h:
; --- handle a run / control code from the stream ------------------------------
	bit 0,b		; B selects literal-run vs repeat-run
	jr nz,l4185h
	ld a,(ix+000h)		; read next literal byte
	ld (hl),a
	inc ix
	cp 0ffh		; &FF = escape/marker
	jr z,l4179h
	and a		; &00 = special, else plain literal
	jr nz,l4160h
l4179h:
	ld e,(ix+000h)		; read run length
	dec e
	inc ix
	jr z,l4160h
	ld b,001h		; switch to repeat-run mode
	jr l4160h
l4185h:
	ld a,(ix-002h)		; repeat the previous literal
	ld (hl),a
	dec e		; decrement remaining run length
	jr nz,l4160h
	ld b,000h		; run done -> back to literal mode
	jr l4160h
; --- finished: restore LMPR and return ----------------------------------------
	ei
	ld a,01fh
	out (0fah),a		; LMPR = &1F (default ROM0/RAM paging)
	ret

;------------------------------------------------------------------------------
; DATA: "RUMSOFT" tag (&4196..&419C) - part of the relocated &8000 block
;------------------------------------------------------------------------------
rumsoft_start:
	defm "RUMSOFT"
rumsoft_end:

;------------------------------------------------------------------------------
; DATA: 40-byte table (&419D..&41C4). Filled at run time by MAIN from &55D8
; (LDIR at &404D) before the template is copied to &8000; the DEPACKER copies
; it back to &55D8 (LDIR at &412E) to restore that system area.
;------------------------------------------------------------------------------
table_start:
	defs 40, 000h		; runtime table, copied from &55D8 then restored
table_end:
;==============================================================================
; COMPRESS  (&41C5)  -  compress the screen at &8000 into the buffer at &E000
;------------------------------------------------------------------------------
; Build-time only (not part of the saved file's runtime). Reads BC=hP_LEN bytes
; from &8000, writes the literal bytes to &8000+ (in place, alt bank) and the
; control/run information to IX=&E000+ via C_FLUSH. Uses both register banks:
;   alt bank (after exx) = INPUT scan: HL'=input ptr, BC'=remaining count,
;                          E'=previous byte
;   main bank            = OUTPUT: DE=literal out ptr, C=bit mask, IX=control out
;==============================================================================
COMPRESS:
	ld bc,00080h		; C = &80 = first control-bit mask
	ld hl,hP_BYTE		; (overwritten below) input base
	ld de,08000h		; DE = &8000 literal output
	ld ix,0e000h		; IX = &E000 control output
	push de
	xor a
	ex af,af'		; A' = 0 (run counter)
	exx		; -> INPUT bank
	pop hl		; HL' = &8000 (input = screen)
	ld bc,(hP_LEN)		; BC' = byte count to compress
	ld a,(hl)
	cpl		; E' = ~first byte (force "different")
	ld e,a
l41deh:
	ld a,b		; BC' == 0 ? (all input consumed)
	or c
	jr z,l4201h		; -> finalise
	dec bc
	ld a,(hl)		; A = next input byte
	inc hl
	cp e		; same as previous ?
	ld e,a		; remember as previous
	jr z,l41fch		; equal -> emit a "repeat" 0-bit
	exx		; -> OUTPUT bank (byte differs)
	ld b,c
	ld (de),a		; store literal byte
	inc de
l41edh:
	xor a		; set the current control bit ...
	or b
	or (hl)
	ld (hl),a		; ... into the bit buffer
	rlc c		; advance bit mask
	jr nc,l41f8h		; byte of bits full ?
	call C_FLUSH		; -> flush run / start new bit byte
l41f8h:
	exx		; -> INPUT bank
	jp l41deh		; next input byte
l41fch:
	exx		; equal-byte path: OUTPUT bank
	ld b,000h		; control bit = 0 (repeat previous)
	jr l41edh
; --- finalise: write the trailing run / end markers into the control stream ---
l4201h:
	ld a,(hP_BYTE)
	cp (ix-001h)		; compare with last control byte written
	jr nz,l421fh
	ex af,af'
	cp 0ffh
	jr z,l4215h
	inc a
	ld (ix+000h),a
	inc ix
	ret
l4215h:
	ld (ix+000h),a
	ld a,(ix-001h)
	inc ix
	jr l4234h
l421fh:
	ex af,af'
	and a
	jr z,l4228h
	ld (ix+000h),a
	inc ix
l4228h:
	ex af,af'
	ld (ix+000h),a
	inc ix
	and a
	jr z,l4234h
	cp 0ffh
	ret nz
l4234h:
	ld (ix+000h),a
	inc ix
	ld (ix+000h),001h
	inc ix
	ret
;==============================================================================
; C_FLUSH  (&4240)  -  emit the accumulated run length into the control stream
;------------------------------------------------------------------------------
; Called from COMPRESS each time a control byte fills up. Encodes the current
; run counter (kept in A') into IX. &00 and &FF are reserved values and get
; special escape handling so they can never be confused with a run length.
;==============================================================================
C_FLUSH:
	cp 0ffh		; last byte == &FF ? (reserved)
	jr z,l425ch
	and a		; last byte == &00 ? (reserved)
	jr z,l425ch
C_FLUSH2:
	ex af,af'		; A = run counter
	and a
	jr z,l4251h
	ld (ix+000h),a
	xor a
	inc ix
l4251h:
	ex af,af'
	ld (ix+000h),a
	ex af,af'
	inc ix
l4258h:
	ex af,af'
	ld (hl),000h
	ret
l425ch:
	ex af,af'
	and a
	jr z,l4271h
	ex af,af'
	cp (ix-001h)
	jr z,l4269h
	call C_FLUSH2
l4269h:
	ex af,af'
	inc a
	cp 0ffh
	jr z,l4274h
	jr l4258h
l4271h:
	inc a
	jr l4251h
l4274h:
	ld (ix+000h),a
	inc ix
	xor a
	jr l4258h

;------------------------------------------------------------------------------
; DATA: author signature (&427C..&42A5)
;       "PREKLAD: 30.09.93  ZDRAVIM RECALL SOFT ..."
;       (PREKLAD = "translation/port"; greetings to RECALL SOFT)
;------------------------------------------------------------------------------
sig_start:
	defm "PREKLAD: 30.09.93  ZDRAVIM RECALL SOFT ..."
sig_end:

