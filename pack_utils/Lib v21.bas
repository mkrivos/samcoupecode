; Lib v21 - SAM BASIC 'Library' by S. Grodkowski, 1993.
; Detokenised to ASCII (sambas2txt.py). One-way listing, not byte-reversible.
; Embedded {NN} = SAM print control codes (e.g. {14}{01}=INVERSE on,
;   {11}n=PAPER n, {10}n=INK n). Compression engines loaded at line 10000:
;   COMPRES (USR &76000) compresses, DEC decompresses (CALL).
;
1 REM {7F}1993 S.Grodkowski: {14}{01}Library - Files{14}{00}{06}{06}
5 SCREEN 1: DISPLAY 1: MODE 3: CSIZE 8,8: CLS #: GO SUB 30000
10 PRINT TAB 21; PAPER 1;"Library - Maker"
20 LET start=32768,ram=3,dane=61006,dlug=0,krok=48,lib=0,ilosc=0,o=1,max=80
25 WINDOW 0,63,1,21: CLS 1: PRINT AT 2,24; PAPER 2;"Main Menu"
30 PRINT AT 4,15;"{14}{01}a{14}{00} - Add a File to Library"; AT 6,15;"{14}{01}r{14}{00} - Remake a Library-File"; AT 8,15;"{14}{01}c{14}{00} - List of Files in Library"; AT 10,15;"{14}{01}l{14}{00} - Load a Library-File"; AT 12,15;"{14}{01}s{14}{00} - Save a Library-File"; AT 14,15;"{14}{01}d{14}{00} - Dir 1"; AT 16,15;"{14}{01}e{14}{00} - Erase a File from Library"; AT 18,15;"{14}{01}1{14}{00} - Extract one File"; AT 20,15;"{14}{01}q{14}{00} - Quit of Program"
35 PRINT #0; AT 1,19; PAPER 1; PEN 2;"{7F}1993 S. Grodkowski"
40 GET a$: IF a$="q" OR a$="Q" THEN STOP
45 IF a$="a" OR a$="A" THEN makelib: GO TO 25
48 IF a$="1" THEN one_file: GO TO 25
50 IF (a$="r" OR a$="R") AND lib THEN remakelib: GO TO 25
55 IF (a$="c" OR a$="C") AND lib THEN filelist: GO TO 25
60 IF a$="l" OR a$="L" THEN fileload: GO TO 25
65 IF (a$="s" OR a$="S") AND lib THEN filesave: GO TO 25
67 IF a$="d" OR a$="D" THEN DIR 1: PAUSE: GO TO 25
69 IF a$="e" OR a$="E" THEN fileerase: GO TO 25
70 ZAP: GO TO 40
100 {14}{01} DEF PROC makelib:{14}{00} LET lib=1
102 CLS 1: PRINT TAB 17; PAPER 2;" Add a File to Library ": WINDOW 0,63,2,21
105 DIR 1
110 ON ERROR GO TO 105
115 INPUT "File as Number ( {14}{01}RETURN{14}{00} - Dir {14}{01}c{14}{00} - List Library {14}{01}q{14}{00} - Main Menu ) ";a$
116 IF a$(1)="@" THEN DIR =a$(2 TO ): GO TO 105
117 IF a$="q" OR a$="Q" THEN ON ERROR STOP: GO TO 199
118 IF a$="c" OR a$="C" THEN filelist: WINDOW 0,63,1,21: GO TO 102
120 LET a= VAL a$: ON ERROR STOP
130 oblicz: READ AT 1,tr,sec,45000: POKE dane, MEM$ (45000+256*offset TO 45010+256*offset): POKE dane+11, MEM$ (45211+256*offset TO 45245+256*offset): DPOKE dane+46, DPEEK (45011+256*offset): REM IF PEEK dane >128 THEN POKE dane,PEEK dane-128
131 REM IF PEEK dane>64 THEN POKE dane,PEEK dane-64
132 LET dane=dane+krok,ilosc=ilosc+1: POKE 61005,ilosc
135 IF ilosc>max THEN CLS 1: PRINT AT 10,10;"Library full !!!": LET ilosc=ilosc-1,dane=dane-krok: PAUSE: GO TO 199
140 LET dl= PEEK (45011+256*offset)*256+ PEEK (45012+256*offset),dlug=dlug+dl,tr1= PEEK (45013+256*offset),sec1= PEEK (45014+256*offset)
145 IF (start+((ram-1)*16384)+dl*510)>450000 THEN CLS 1: PRINT AT 10,10;"Library full !!!": LET ilosc=ilosc-1,dane=dane-krok: PAUSE: GO TO 199
150 POKE 16387,tr1,sec1
153 IF start>=49152 THEN LET start=start-16384,ram=ram+1: GO TO 153
155 POKE 16389,ram: DPOKE 16390,start
160 CALL 16384: LET ram= PEEK 16389,start= DPEEK 16390
170 POW: PRINT #0; AT 0,1;"{14}{01}RETURN{14}{00} - one more , {14}{01}SPACE{14}{00} - Exit to Main Menu , {14}{01}c{14}{00} - List Files"
175 GET a$: IF a$= CHR$ 13 THEN GO TO 110
180 IF a$=" " THEN GO TO 199
185 IF a$="c" OR a$="C" THEN LET o=0:filelist: LET o=1: GO TO 170
190 ZAP: GO TO 175
199 INPUT "": END PROC
200 {14}{01} DEF PROC oblicz:{14}{00} LET tr= INT ((a-1)/20),offset= NOT (a BAND 1),sec= INT ((a-tr*20)/2)+ NOT offset: END PROC
250 {14}{01} DEF PROC filesave:{14}{00} CLS 1
255 PRINT TAB 19; PAPER 2;"Save a Library-File": WINDOW 0,63,2,21
256 PRINT AT 13,5;"Compress the File ? (y/{14}{01}n{14}{00})": GET a$: IF a$="y" OR a$="Y" THEN LET li= NOT PI: ELSE LET li=1
258 IF li THEN DIR 1"*.li*": LET s$=".lib": ELSE DIR 1;"*.lc*": LET s$=".lcb"
260 INPUT "Name: ( to 6 letters ): ";b$
265 IF b$="" THEN GO TO 299
267 IF INSTR (b$,".")<>0 THEN LET b$=b$( TO INSTR (b$,".")-1)
270 IF LEN b$>6 THEN LET b$=b$( TO 6)
275 LET x=61000,y=(start+(ram-1)*16384)+1-x: DPOKE 61000,x: POKE 61002, INT (y/16384): DPOKE 61003,(y-16384* INT (y/16384))
277 IF NOT li THEN compr: LET lib= NOT PI: GO SUB 30000
280 SAVE b$+s$ CODE x,y
285 CLS 1: PRINT AT 15,7;"File Loader (y/{14}{01}n{14}{00}) ?"''' TAB 9;"This Program will be corrupted": GET q$: IF q$="y" OR q$="Y" THEN GO TO 5000
299 END PROC
300 {14}{01} DEF PROC fileload:{14}{00} CLS 1
310 PRINT TAB 19; PAPER 2;"Load a Library-File": WINDOW 0,63,2,21
312 PRINT AT 13,5;"Load a Compress File ? (y/{14}{01}n{14}{00})": GET a$: IF a$="y" OR a$="Y" THEN LET li= NOT PI: ELSE LET li=1
315 IF li THEN DIR 1"*.li*": LET s$=".lib": ELSE DIR 1;"*.lc*": LET s$=".lcb"
320 INPUT "Name: ( to 6 letters ): ";b$
330 IF b$="" THEN GO TO 399
335 IF LEN b$>6 THEN LET b$=b$( TO 6)
336 CLS 1: PRINT AT 10,23;"Please Wait"
340 IF li THEN LOAD b$+s$ CODE 61000: ELSE LOAD b$+s$ CODE 59000: CALL 59000: GO SUB 30000
350 LET f=61000
352 LET x= DPEEK f: IF x<>f THEN CLS 1: PRINT AT 10,17;"Not a Library-Format !!!": ZAP: POW: PAUSE 60: POW: ZAP: LET lib=0: END PROC
355 LET ilosc= PEEK 61005,start=32768,ram=3,dane=61006,lib=1: FOR f=1 TO ilosc: LET start=start+510*(256* PEEK (dane+46)+ PEEK (dane+47)): LET dane=dane+krok
357 IF start>=49152 THEN LET start=start-16384,ram=ram+1: GO TO 357
360 NEXT f
399 END PROC
400 {14}{01} DEF PROC filelist:{14}{00} CLS 1
410 PRINT PAPER 2;" Nr. File: Length: Status: "
420 WINDOW 0,63,2,21: PRINT
430 LET dana1=61006,start=32768,ram=3: FOR f=1 TO ilosc
440 LET rodz= PEEK dana1,naz$= MEM$ (dana1+1 TO dana1+10),dl=510*( PEEK (dana1+47)+256* PEEK (dana1+46)),start=start+dl
443 IF start>=49152 THEN LET start=start-16384,ram=ram+1: GO TO 443
445 IF rodz>128 THEN LET rodz=rodz-128
447 IF rodz>64 THEN LET rodz=rodz-64
450 PRINT TAB 3;f; TAB 8;naz$; TAB 23;dl; TAB 39;rodz; TAB 47;: IF rodz=16 THEN PRINT "( Basic )": GO TO 460
455 IF rodz=19 THEN PRINT "( Code )": GO TO 460
457 PRINT "( ?! )"
460 LET dana1=dana1+krok: NEXT f: PRINT '"==============================================================="'
462 PRINT TAB 7;"Total Length: ";(start+((ram-1)*16384))-65536; TAB 40;"Free: ";450000-(start+(ram-1)*16384)
465 IF o THEN PAUSE
470 END PROC
500 {14}{01} DEF PROC remakelib:{14}{00} SCROLL CLEAR: CLS 1: PRINT TAB 17; PAPER 2;" Remake Library - File ": WINDOW 0,63,2,21: CLOSE SCREEN 2: OPEN SCREEN 2,3
502 PRINT ' PAPER 2;" Nr. File: Length: Status: ": WINDOW 0,63,5,21
505 LET dana1=61006,start1=65536: FOR f=1 TO ilosc
515 LET rodz= PEEK dana1,naz$= MEM$ (dana1+1 TO dana1+10),dl=510*( PEEK (dana1+47)+256* PEEK (dana1+46))
520 PRINT TAB 3;f; TAB 8;naz$; TAB 23;dl; TAB 39;rodz; TAB 47;: IF rodz=16 THEN PRINT "( Basic )": GO TO 530
525 IF rodz=19 THEN PRINT "( Code ) ": GO TO 530
527 PRINT "( ?! ) "
530 LET q$= MEM$ (dana1 TO dana1+10),w$= MEM$ (dana1+11 TO dana1+45)
535 DISPLAY 1: SCREEN 2: DISPLAY 1: CLOSE #4: OPEN #4;"$": SAVE OVER naz$ CODE start1+9,dl-9
540 RECORD TO a$
545 DIR #4,1""+naz$+""
550 RECORD STOP: LET a$=a$(17 TO 19),a= VAL a$: SCREEN 1
560 oblicz: READ AT 1,tr,sec,47000: POKE (47000+256*offset),q$: POKE (47211+256*offset),w$: LET dana1=dana1+krok
565 LET tr1= PEEK (47013+256*offset),sec1= PEEK (47014+256*offset): READ AT 1,tr1,sec1,45000: LET t= DPEEK (45510),r= DPEEK (start1+510): DPOKE start1+510,t: WRITE AT 1,tr1,sec1,start1: DPOKE start1+510,r
570 WRITE AT 1,tr,sec,47000
580 LET start1=start1+dl: NEXT f
590 SCROLL RESTORE: DIR 1: PAUSE: END PROC
1000 {14}{01} DEF PROC compr:{14}{00} LET start1=start+(ram-1)*16384: CLS 1: PRINT AT 8,23;"Please Wait"; AT 10,20;"{11}{02}{10}{01}**{11}{01}{10}{03} Compression {11}{02}{10}{01}**{11}{00}{10}{03}"
1030 LET l=start1-61000,FROM=61000+l-1,TO_=FROM+8000
1040 LET NSL=l DIV 65536,ML=l MOD 65536: DPOKE &76013,ML: POKE &76015,NSL
1050 LET FRP=(FROM DIV 16384)-1,FRA=FROM MOD 16384,TOP=(TO_ DIV 16384)-1,TOA=TO_ MOD 16384
1060 POKE &7600D,FRP: POKE &76010,TOP: DPOKE &7600E,FRA: DPOKE &76011,TOA
1070 LET DAT=&6C000+ USR &76000
1080 LET x=16384*( PEEK (DAT+3)+1)+ DPEEK (DAT+4),y= PEEK (DAT+2)*65536+ DPEEK (DAT)+4
1090 LET Z=1: LET DEPP=((FROM+Z) DIV 16384)-1,DEPA=(FROM+Z) MOD 16384: POKE &77057,DEPP: DPOKE &77058,DEPA
1100 POKE x-367, MEM$ (&77000 TO &77000+366): LET x=x-367,y=y+367
1110 LET o=0: SCROLL CLEAR: filelist: SCROLL RESTORE: PRINT ''"Compressed Block length is ";y;" Bytes."
1120 LET o=1: END PROC
2000 {14}{01} DEF PROC fileerase:{14}{00} CLS 1
2010 PRINT TAB 22; PAPER 2;"Erase a File": WINDOW 0,63,2,21
2015 LET o=0:filelist: LET o=1
2020 INPUT "File as Number ( 0 - Main Menu ): ";c: IF c>ilosc THEN GO TO 2020
2025 IF c=0 THEN GO TO 2099
2030 LET start1=start+(ram-1)*16384: FOR f=ilosc-1 TO c STEP -1: LET start1=start1-510*( PEEK (61006+f*krok+47)+256* PEEK (61006+f*krok+46)): NEXT f
2040 LET dl=start1-510*( PEEK (61006+(c-1)*krok+47)+256* PEEK (61006+(c-1)*krok+46))
2050 LET start=start+(ram-1)*16384: FOR f=start1 TO start STEP 2080: POKE dl, MEM$ (f TO f+2079): LET dl=dl+2080: NEXT f
2060 LET start=start-(start1-dl)
2065 LET ram=3: IF start>=49152 THEN LET start=start-16384,ram=ram+1: GO TO 2065
2070 LET dane1=61006+(c-1)*krok: POKE dane1, MEM$ (dane1+krok TO 61006+ilosc*krok): LET ilosc=ilosc-1,dane=dane-krok: POKE 61005,ilosc: IF NOT ilosc THEN LET lib= NOT PI
2080 GO TO 2015
2099 END PROC
2200 {14}{01} DEF PROC one_file:{14}{00} CLS 1: SCREEN 1: CLOSE SCREEN 2: OPEN SCREEN 2,3
2210 PRINT TAB 21; PAPER 2;"Extract one File": WINDOW 0,63,2,21
2215 LET o=0:filelist: LET o=1
2220 INPUT "File as Number ( 0 - Main Menu ): ";c: IF c>ilosc THEN GO TO 2220
2225 IF c<=0 THEN GO TO 2299
2230 LET start1=65536: LET f=0
2235 IF f=c-1 THEN GO TO 2240: ELSE LET start1=start1+510*( PEEK (61006+f*krok+47)+256* PEEK (61006+f*krok+46)),f=f+1: GO TO 2235
2240 LET dl=510*( PEEK (61006+(c-1)*krok+47)+256* PEEK (61006+(c-1)*krok+46)),dana1=61006+(c-1)*krok
2245 LET rodz= PEEK dana1,naz$= MEM$ (dana1+1 TO dana1+10),dl=510*( PEEK (dana1+47)+256* PEEK (dana1+46))
2250 LET q$= MEM$ (dana1 TO dana1+10),w$= MEM$ (dana1+11 TO dana1+45)
2255 DISPLAY 1: SCREEN 2: DISPLAY 1: CLOSE #4: OPEN #4;"$": SAVE OVER naz$ CODE start1+9,dl-9
2257 RECORD TO a$
2258 DIR #4,1""+naz$+""
2260 RECORD STOP: LET a$=a$(17 TO 19),a= VAL a$: SCREEN 1
2265 oblicz: READ AT 1,tr,sec,47000: POKE (47000+256*offset),q$: POKE (47211+256*offset),w$
2270 LET tr1= PEEK (47013+256*offset),sec1= PEEK (47014+256*offset): READ AT 1,tr1,sec1,45000: LET t= DPEEK (45510),r= DPEEK (start1+510): DPOKE start1+510,t: WRITE AT 1,tr1,sec1,start1: DPOKE start1+510,r
2275 WRITE AT 1,tr,sec,47000
2280 GO TO 2220
2299 END PROC
3000
5000 IF s$=".lib" THEN KEYIN "7010 load "+ CHR$ 34+b$+s$+ CHR$ 34+"code ": ELSE KEYIN "7010 load "+ CHR$ 34+b$+s$+ CHR$ 34+"code59000:print at10,17;"+ CHR$ 34+"Decompress"+ CHR$ 34+": call 59000"
5010 DELETE TO 199: DELETE 205 TO 340: DELETE 399 TO 470: DELETE 10000 TO: KEYIN "399 return"
5015 DELETE 1000 TO 5010
5020 SAVE "Load"+b$ LINE 7000: STOP
7000 CLEAR 44999: MODE 3: LET krok=48: CSIZE 8,8: PRINT #0; AT 1,19;"{7F}1993 S. Grodkowski"
7020 GO SUB 350: CLS 1: PRINT "Press any Key to Remake the "; PEEK 61005;" Files": PAUSE:remakelib: DELETE TO
9999 STOP
10000 CLEAR 44999: LOAD "COMPRES" CODE &76000: LOAD "DEC" CODE &77000: RUN
