;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CPXLNK.ASM -- Linkage between KERMIT and overlays
;
;This file describes the areas used to communicate between
;KERMIT and the customizing overlay.  It is included by the 
;overlay. This file should be changed only to reflect 
;changes in the system-independent portion of Kermit 
;(enhancements, I hope).
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

	print	"* CPXLNK.ASM *"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Entry Section Equates
;
;These addresses contain jumps to useful routines in
;KERMIT.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
entry	equ	105H	; start of entry section
kermit	equ	entry+0	; reentry address
nout	equ	entry+3	; output HL in decimal
entsiz	equ	2*3	; 2 entries, so far.
;
;       End of entry section.
;
;       Linkage section.  This block (through the definition of lnksiz)
;       is used by Kermit to reach the routines and data in the overlay.
;       The section length is stored at the beginning of the overlay
;       area so Kermit can verify that the overlay section is (a) present,
;       (b) in the right place, and (c) the same size as (and therefore
;       presumably the same as) the linkage section Kermit is expecting.
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Linkage Section Equates
;
;This block (defined by linksiz) is used by KERMIT to reach
;the routines and data in the overlay. The section length
;is stored at the beginning of the overlay area so KERMIT
;can verify that the overlay section is (a) present, (b) in
;the right place, and (c) the same size as (and therefore
;presumably the same as) the linkage section KERMIT is
;expecting.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	ovladr

lnkflg:	dw	lnksiz	; linkage information for consistency check.
	dw	entsiz	; length of entry table, for same.
	dw	swtver	;Address of switcher
	dw	family	;*NEW* for V4.08. Address of the family string

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Jump Table for System-Dependent Routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp	selmdm	; select modem for I/O
	jmp	outmdm	; output character in E to modem
	jmp	inpmdm	; read character from modem. return character or 0 in A.
	jmp	flsmdm	; flush pending input from modem
	jmp	selcon	; select console for I/O
	jmp	outcon	; output character in E to console
	jmp	inpcon	; read char from console. return character or 0 in A
	jmp	outlpt	; output character in E to printer
	jmp	lptstat	;*NEW*  get the status for the printer. 
			; 0=>ok, 0ffh=> not ok
	jmp	0	;*NEW for 4.09* Terminal Emulation code (optional)
			; If terminal is set to EXTERNAL and this address
			; has been filled, then user uses their own code.
xbdos:	jmp	0	;*NEW* Address of the BDOS trap in the independent 
			; code. Use this enty for BDOS calls if you want 
			; the printer handler to work properly.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Screen Formatting Routine Jumps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp	clrlin	; erase current line
	jmp	clrspc	; erase current position (after backspace)
	jmp	delchr	; make delete look like backspace
	jmp	clrtop	; erase screen and go home

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Routines to Display a Field on Screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp	scrend	; move to prompt field
	jmp	screrr	; move to error message field
	jmp	scrfln	; move to filename field
	jmp	scrnp	; move to packet count field
	jmp	scrnrt	; move to retry count field
	jmp	scrst	; move to status field
	jmp	rppos	; move to receive packet field (debug)
	jmp	sppos	; move to send packet field (debug)

	jmp	sysinit	; program initialization
	jmp	sysexit	; program termination
	jmp	syscon	; remote session initialization
	jmp	syscls	; return to local command level
	jmp	sysinh	; help text for interrupt (escape) extensions
	jmp	sysint	; interrupt (escape) extensions, including break
	jmp	sysflt	; filter for incoming characters.
			;  called with character in E.
	jmp	sysbye	; terminate remote session
	jmp	sysspd	; baud rate change routine.
			; called with value from table in DE
	jmp	sysprt	; port change routine.
			; called with value from table in HL
	jmp	sysscr	; screen setup for file transfer
			; called with Kermit's version string in DE
	jmp	csrpos	; move cursor to row B, column C
	jmp	sysspc	; calculate free space for current drive
	jmp	mover	; do block move
	jmp	prtstr	; *** NEW *** Link from system indep equivalent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Local Parameter Storage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pttab:	dw	ttab	; points to local equivalents to VT52 escape sequences
spdtab:	dw	spdtbl	; address of baud rate command table, or zero
spdhlp:	dw	sphtbl	; address of baud rate help table, or zero
prttab:	dw	prttbl	; address of port command table, or zero
prthlp:	dw	prhtbl	; address of port help table, or zero
timout:	dw	fuzval	; Fuzzy timeout.
vtflg:	db	vtval	; VT52 emulation flag
escchr:	db	defesc	; Storage for the escape character.
speed:	dw	0FFFFH	; storage for the baud rate (initially unknown)
port:	dw	0FFFFH	; storage for port value (initially unknown) [hh]
prnflg:	db	0	; printer copy flag [hh]
dbgflg:	db	0	; debugging flag
ecoflg:	db	0	; Local echo flag (default off).
flwflg:	db	1	; File warning flag (default on).
ibmflg:	db	0	; IBM flag (default off).
cpmflg:	db	0	;[bt] file-mode flag (default is DEFAULT)
incflg:	db	0		;[MF]incomplete-file flag (default is DISCARD)
parity:	db	defpar	; Parity.
spsiz:	db	dspsiz	; Send packet size.
rpsiz:	db	drpsiz	; Receive packet size.
stime:	db	dstime	; Send time out.
rtime:	db	drtime	; Receive time out.
spad:	db	dspad	; Send padding.
rpad:	db	drpad	; Receive padding.
spadch:	db	dspadc	; Send padding char.
rpadch:	db	drpadc	; Receive padding char.
seol:	db	dseol	; Send EOL char.
reol:	db	dreol	; Receive EOL char.
squote:	db	dsquot	; Send quote char.
rquote:	db	drquot	; Receive quote char.
chktyp:	db	dschkt	; Checksum type desired

tacflg:			; TACtrap status:
	IF	tac
	db	tacval	; when non-zero, is current TAC intercept character;
	ENDIF;tac
	IF	NOT tac
	db	0	; when zero, TACtrap is off.
	ENDIF;tac

tacchr:	db	tacval	; Desired TAC intercept character (even when off)

bufadr:	dw	buff	; Address of possibly multi-sector buffer for I/O
bufsec:	db	1	; Number of sectors big buffer can hold (0 means 256)
ffussy:	db	1	; if nonzero, don't permit <>.,;?*[] in CP/M filespec.
; space used by directory command; here because space calculation is
;  (operating) system-dependent
bmax:	ds	2	; highest block number on drive
bmask:	ds	1	; (records/block)-1
bshiftf: ds	1	; number of shifts to multiply by rec/block
nnams:	ds	1	; counter for filenames per line

lnksiz	equ	$-lnkflg ; length of linkage section, for consistency check.
