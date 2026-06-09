# Makefile — SAM Coupe reverse-engineering (arch-pack utilities)
#
# Reassembles an annotated source and verifies a byte-exact round-trip against
# the original binary. Uses z88dk z80asm and z80dasm. One routine at a time,
# selected by NAME (default SKOMP1):
#
#   make                         build + verify SKOMP1
#   make NAME=ARCHIV verify      build + verify ARCHIV  (needs ARCHIV.asm + ARCHIV.BIN)
#   make NAME=IMPLO1 disasm      raw reference listing for IMPLO1
#
# Targets:
#   make            build + verify (default)
#   make build      assemble $(NAME).asm -> $(NAME).bin
#   make verify     compare $(NAME).bin with the original $(NAME).BIN
#   make disasm     regenerate a RAW reference listing ($(NAME).gen.asm)
#                   (does NOT overwrite the hand-annotated $(NAME).asm)
#   make clean      remove build artifacts for $(NAME)

NAME      ?= SKOMP1
ORG       ?= 0x4000

ASM       := z80asm
ASMFLAGS  := -b
DASM      := z80dasm
GHIDRA    := /opt/ghidra/support/analyzeHeadless
GHLANG    := z80:LE:16:default

SRC       := $(NAME).asm
BIN       := $(NAME).bin
ORIG      := $(NAME).BIN
OBJ       := $(NAME).o

BLK       := $(NAME).blk
SYM       := $(NAME).z80sym
GEN       := $(NAME).gen.asm

.DEFAULT_GOAL := verify
.PHONY: all build verify disasm ghidra clean

all: verify

build: $(BIN)

$(BIN): $(SRC)
	$(ASM) $(ASMFLAGS) -o=$@ $<

verify: $(BIN)
	@cmp $(BIN) $(ORIG) \
		&& echo "OK: $(BIN) == $(ORIG) (byte-exact round-trip)" \
		|| { echo "FAIL: $(BIN) differs from $(ORIG)"; exit 1; }

# Regenerate a raw reference listing from the original binary.
disasm: $(ORIG) $(BLK) $(SYM)
	$(DASM) -a -t -l -u -g $(ORG) -b $(BLK) -S $(SYM) $(ORIG) -o $(GEN)
	@echo "wrote $(GEN)"

# Complementary: Ghidra headless decompile to pseudo-C ($(NAME).ghidra.c).
# Aid only - NOT the canonical artifact (see ghidra_decompile.java header).
ghidra: $(ORIG)
	@rm -rf /tmp/ghprj_$(NAME) && mkdir -p /tmp/ghprj_$(NAME)
	$(GHIDRA) /tmp/ghprj_$(NAME) p -import $(ORIG) -processor "$(GHLANG)" \
	  -loader BinaryLoader -loader-baseAddr $(ORG) \
	  -scriptPath $(CURDIR) -postScript ghidra_decompile.java $(CURDIR)/$(NAME).ghidra.c \
	  -deleteProject
	@echo "wrote $(NAME).ghidra.c"

clean:
	$(RM) $(BIN) $(OBJ) $(GEN)
