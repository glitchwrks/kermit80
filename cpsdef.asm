;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CPSDEF.ASM -- Common definitions for KERMIT
;
;This file contains common equates used for both the main
;KERMIT program and the system-dependent modules. This is
;part of the Glitch Works dependency restructure.
;
;Written for CP/M-80 KERMIT 4.11. KERMIT is:
;
;       Copyright June 1981,1982,1983,1984,1985
;       Columbia University
;
;The contents of this file are:
;
;Copyright (c) 2019 The Glitch Works
;http://www.glitchwrks.com
;
;See LICENSE included in the project root for licensing
;information.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ASCII Character Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
soh	EQU	01O	;ASCII SOH (Control-A)
ctrlc	EQU	03O	;ASCII ETX (Control-C)
cntlc	EQU	ctrlc	;Alternate definition, replace this
bell	EQU	07O	;ASCII BEL (Control-G)
bs	EQU	10O 	;ASCII backspace (Control-H)
tab	EQU	11O	;ASCII Tab (Control-I)
lf      EQU	12O	;ASCII Line Feed (CTRL-J)
ff      EQU	14O	;ASCII Form Feed (CTRL-L)
cr      EQU	15O	;ASCII Carriage Return (CTRL-M)
space	EQU	20h	;ASCII Space
xon     EQU	21O	;ASCII XON (Control-Q)
xoff    EQU	23O	;ASCII XOFF (Control-S)
esc     EQU	33O	;ASCII ESCape
semico	EQU	3bh	;ASCII Semicolon
ctrlz	EQU	32O	;ASCII SUB (Control-z)
subt    EQU	ctrlz	;Alternate definition, replace this
cntlz   EQU	ctrlz	;Alternate definition, replace this
del     EQU	177O	;ASCII DELete (rubout)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BDOS Call Equates
;
;All function numbers are passed in the C register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	IF NOT cpsker
bdos    EQU     0005H   ;BDOS entry point, for the following functions:
	ENDIF	;NOT cpsker

;Function Name          Function        Input Parameters Output Parameter
;=============          ========        ================ ================
conin   EQU     01H     ;Read Console   NONE             ASCII Char in A
conout  EQU     02H     ;Write Console  ASCII Char in E  NONE
auxin   EQU     03H     ;Auxiliary input
rdrin   EQU     03H     ;Read Reader    NONE             ASCII Char in A
lstout  EQU     05H     ;Write List     ASCII Char in E  NONE
dconio  EQU     06H     ;Direct Con I/O ASCII Char in E  I/O Status in A
			;                                if E=0FEH,
			;                                 Input if E=0FFH
prstr   EQU     09H     ;Print String   String-Address   NONE
			;               in DE (term=$)
rdstr   EQU     0AH     ;Read Buffer    Buffer-Address  Read Buffer filled
;                                       in DE
;       Read Buffer     Byte    Function
;                         1     Maximum Buffer Length
;                         2     Current Buffer Length (returned value)
;                       3-n     Data (returned values)
;
consta  EQU     0BH     ;Console Stat   NONE            LSB(A)=1 if char ready
getvnm  EQU     0CH     ;Version Number NONE            H=0 (CP/M), L=BDOS ver
inbdos  EQU     0DH     ;Init BDOS      NONE            NONE
logdsk  EQU     0EH     ;LOG-In disk    Value in E      NONE
			;               A=0,B=1,...
openf   EQU     0FH     ;Open File      FCB-Addr in DE  Byte Addr.of FCB,
			;                                or 0FFH if not
closf   EQU     10H     ;Close File     FCB-Addr in DE  Byte Addr.of FCB,
			;                                or 0FFH if not
sfirst  EQU     11H     ;Search File    FCB-Addr in DE  Byte Addr.of FCB(0-3),
			;                                or 0FFH if not
snext   EQU     12H     ;Search next    FCB-Addr in DE  Byte Addr.of next FCB,
			;                                or 0FFH if not
delf    EQU     13H     ;Delete File    FCB-Addr in DE  Byte Addr.of FCB(0-3),
			;                                or 0FFH if not
readf   EQU     14H     ;Read Record    FCB-Addr in DE  0=successful read
			;                               1=read past EOF
			;                               2=reading random data
writef  EQU     15H     ;Write Record   FCB-Addr in DE  0=successful write
			;                               1=ERROR extending
			;                               2=End of disk data
			;                               255=No more DIR space
makef   EQU     16H     ;Make File      FCB-Addr in DE  0-3= success,
			;                               255= no more dir space
renam   EQU     17H     ;Rename File    FCB-Addr in DE  0-3= success,
			;                               255= file not found
rdlog   EQU     18H     ;Ret. Log Code  NONE            Login Vector in HL
rddrv   EQU     19H     ;Read Drive #   NONE            # of logged in drive in
			;                               (A=0,B=1,C=2....)
setdma  EQU     1AH     ;Set DMA Addr.  Addr. of 128    NONE
			;               byte buffer in DE
wrtprt  EQU     1CH     ;Write prot dsk NONE            NONE
getrov  EQU     1DH     ;Get R/O Vect.  NONE            HL= R/O Vect. value
setfat  EQU     1EH     ;Set File Attr. FCB-Addr.in DE  Dir. code in A
gtdpar  EQU     1FH     ;Get DSK par.   NONE            HL=DPB Address
usrcod  EQU     20H     ;Get/Set Usr.Cd E=0FFH (get)    A=current code (get)
			;               E-code (set)    A=no value (set)
rrand   EQU     21H     ;Read  Random   FCB-Addr in DE  A=Return code
wrand   EQU     22H     ;Write Random   FCB-Addr in DE  1=read'g unwritten data
			;                               2=(not used)
			;                               3=can't close curr. ext
			;                               4=seek to unwr. ext.
			;                               5=dir overflow(write)
			;                               6=seek past End of DSK
cflsz   EQU     23H     ;Comp File Sz.  FCB Addr.in DE  Rand.Rec.field set to
			;                                File size
setrar  EQU     24H     ;Set Rand. Rec. FCB-Addr.in DE  Rand.Rec.field set

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CP/M 2 Specific BDOS Calls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
punout  EQU     04H     ;Write Punch    ASCII Char in E  NONE
gtiob   EQU     07H     ;Get I/O status NONE             I/O Status in A
ptiob   EQU     08H     ;Put I/O status I/O Status in E  NONE
getalv  EQU     1BH     ;Get All.Vect.  NONE            All.Vect in HL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CP/M 3 Specific BDOS Calls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
auxout  EQU     04H     ;Auxiliary output
auxist  EQU     07H     ;Get AUXIN: status               A=FF if character
			;                                ready, A=0 if none
auxost  EQU     08H     ;Get AUXOUT: status              A=FF if ready, A=0
			;                                if not ready
getfs   EQU     2EH     ;Get free space E=drive         # rec free in dma addr
parevn  EQU     00H     ;Even parity.
parmrk  EQU     03H     ;Mark parity.
parnon  EQU     06H     ;No parity (eighth bit is data).
parodd  EQU     09H     ;Odd parity.
parspc  EQU     0CH     ;Space parity.

defpar  EQU     parnon  ;Default parity.
ibmpar  EQU     parmrk  ;IBM COMTEN's parity.

fcb     EQU     5CH     ;Location of File Control Block.
fcbext  equ     fcb+12
fcbrno  equ     fcb+33
buff    EQU     80H     ;Location of file output buffer (DMA).
bufsiz  EQU     80H     ;Size of DMA.

maxfcb  equ     64      ; maximum of 64 fcbs to be stored in multiple fcb bock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IOBYTE Equates
;
;       I/O Byte assignments (2-bit fields for 4 devices at loc 3)
;
;bits 6+7               LIST field
;       0               LIST is Teletype device (TTY:)
;       1               LIST is CRT device (CRT:)
;       2               LIST is Lineprinter (LPT:)
;       3               LIST is user defined (UL1:)
;
;bits 4+5               PUNCH field
;       0               PUNCH is Teletype device (TTY:)
;       1               PUNCH is high speed punch (PUN:)
;       2               PUNCH is user defined #1 (UP1:)
;       3               PUNCH is user defined #2 (UP2:)
;
;bits 2+3               READER field
;       0               READER is Teletype device (TTY:)
;       1               READER is high speed reader (RDR:)
;       2               READER is user defined #1 (UR1:)
;       3               READER is user defined #2 (UR2:)
;
;bits 0+1               CONSOLE field
;       0               CONSOLE is console printer (TTY:)
;       1               CONSOLE is CRT device (CRT:)
;       2               CONSOLE is in Batch-mode (BAT:);READER = Input,
;                       LIST = Output
;       3               CONSOLE is user defined (UC1:)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

iobyte  EQU     03H     ;Location of I/O byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Protocol Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

maxpkt  EQU    '~'-' '+2O;Maximum size of a packet.
maxtry  EQU     05O     ; Number of retries on a packet.
imxtry  EQU     20O     ; Number of retries send initiate.
prfair  EQU     50     ;[pcc008] Prtchr fairness count

; opcodes for command parser
cmkey   EQU     01H     ;Parse a keyword.
cmifi   EQU     02H     ;Parse an input file spec (can be wild).
cmofi   EQU     03H     ;Parse an output file spec.
cmcfm   EQU     04H     ;Parse a confirm.
cmtxt   EQU     05H     ;Parse text.
cmnum   EQU     06h     ;Parse a number
cmifin  EQU     10H     ;Parse an input file spec (but no
			;Error output

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Protocol Parameter Equates
;
;Some of these parameters can be changed with commands.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drpsiz  SET     50H     ;Default receive packet size. (maximum is 5EH)
dspsiz  SET     50H     ;Default send packet size. (maximum is 5EH)
dstime  SET     08H     ;Default send time out interval.
drtime	SET	05	;Default receive time out interval

dspad   EQU     00H     ;Default send padding.
drpad   EQU     00H     ;Default receive padding.
dspadc  EQU     00H     ;Default send padding char.
drpadc  EQU     00H     ;Default receive padding char.
dseol   EQU     cr      ;Default send EOL char.
dreol   EQU     cr      ;Default receive EOL char.
dsquot  EQU     '#'     ;Default send quote char.
drquot  EQU     '#'     ;Default receive quote char.
dschkt  EQU     '1'     ;Default checksum type

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Terminal Emulation Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vtdefo	EQU	0	;VT52 emulation by terminal itself.
vtdefv	EQU	1	;VT52 emulation by ttab tables in CPXVDU.ASM etc
vtdefd	EQU	2	;Dumb Terminal (Just prints)
vtdefe	EQU	3	;Termianl emulation done outside (in overlay)
