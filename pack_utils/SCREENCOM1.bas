; SCREENCOM1 - SAM BASIC loader, detokenised to ASCII (sambas2txt.py).
; One-way listing (binary number forms dropped); not byte-reversible.
;
10 LET b= DPEEK &4009+ PEEK (&4008)*65536
20 INPUT #2; AT 6,4;"File name:";a$: IF a$="" THEN CLS: DIR 1: PAUSE: RUN
30 PRINT AT 7,7;"( ";b;" )"
40 INPUT #2; AT 8,4;"From address: ";b$: IF b$="" THEN LET a=b
50 IF b$<>"" THEN LET a= VAL b$
60 LOAD a$ SCREEN$
70 LET e=a: POKE &4008, INT ( e/65536): DPOKE &4009,(e MOD 65536)
80 LET c= USR 16384,d=b,b=E+c
90 POKE &4008, INT ( b/65536): DPOKE &4009,(b MOD 65536)
100 PALETTE: CLS
110 PRINT ''"Final lenght: ";c
120 PRINT ''"Next free address: ";b
130 PRINT ''"Save ? (no)": GET x$: IF x$="y" OR x$="Y" THEN INPUT #2;''"File name: ";m$: SAVE m$ CODE e,c,e
140 GO TO 160
150 LOAD "sKomp1.bin" CODE 16384: RUN
