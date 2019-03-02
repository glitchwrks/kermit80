;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CPXMIT.ASM -- KERMIT-80 Routines for MITS Interfaces
;
;This file contains system-dependent code for various MITS
;serial interface boards. These have the family name of
;CPXMIT.
;
;Written for CP/M-80 KERMIT 4.11. KERMIT is:
;
;	Copyright June 1981,1982,1983,1984,1985
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

IF m2sio
.printx	* Assembling for MITS 88-2SIO board *
ENDIF ;m2sio

IF m2sio ;MITS 88-2SIO at default addressing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Basic 2SIO Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
port0d	equ	011h		;Channel 0 data (console)
port0s	equ	010h		;Channel 0 status
port1d	equ	013h		;Channel 1 data (printer)
port1s	equ	012h		;Channel 1 status

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Setup to use 2SIO Channel 1 by default
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mnport	equ	port1d		;Data port
mnprts	equ	port1s		;Status port
output	EQU	02h		;Bit of 6850 ACIA status for TX empty
input	EQU	01h		;Bit of 6850 ACIA status for RX full
z80	EQU	FALSE		;Assume original 8080 CPU board

ENDIF ;m2sio

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Family string, used to idenfity system-dependent module
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
family:	db	'CPXMITS.ASM  (1)  2019-02-28$'    ; Used for family versions....

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSXIN -- System-dependent initialization code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysxin:	

IF m2sio
	mvi	a, 03h		;6850 ACIA reset
	out	mnprts
	mvi	a, 015h		;8N1
	out	mnprts

ENDIF ;m2sio

	ret			;return from SYSXIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSEXIT -- System-dependent termination processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysexit:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSCON -- System-dependent processing for start of
;          CONNECT command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
syscon:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONMSG -- Messages printed when entering CONNECT mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
conmsg:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSCLS -- System-dependent close routine called when
;          exiting CONNECT session
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
syscls:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSINH -- Print system-dependent special functions, in
;          response to <escape>?, after listing all
;          system-independent escape sequences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysinh:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INHLPS -- Additional system-dependent help for CONNECT
;          mode, two-character escape sequences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inhlps:
	db	'$'		; Table terminator for INHLPS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSINT -- System-dependent special functions called when
;          CONNECT mode escape character has been typed
;
;pre: second char of sequence is in A and B registers
;post: non-skip: sequence has been processed
;post: skip:     sequence was not recognized
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysint:	
	jmp	rskp		; take skip return - command not recognized.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSFLT -- System-dependent filter
;
;Preserves BC, HE, HL
;
;Note: <xon>, <xoff>, <del>, <nul> are always discarded.
;
;pre: character is in E register
;post: A = 0 if character should not be printed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysflt:
	mov	a,e		; get character for testing
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MDMFLT -- System-dependent filter for modem
;
;pre: character is in E register
;post: A = 0 if character should not be printed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mdmflt:
	mov	a,e		;get character to test
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRTFLT -- System-dependent filter for printer
;
;Historically, this has been used to handle printers that
;insert automatic <cr> for <lf> or <lf> for <cr>.
;
;pre: character is in E register
;post: A = 0 if character should not be printed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prtflt:
	mov	a,e		; [30] get character to test
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSBYE -- System-dependent processing for BYE command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysbye:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSSPD -- System-dependent command to change the bitrate
;
;pre: DE contains the two-byte value from the bitrate table
;post: bitrate is set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysspd:
	ret

;The following equates are legacy leftovers from a very
;large bitrate table. Set both to 0 to show SET BAUD is not
;supported.
spdtbl	EQU	0		;SET BAUD not supported
sphtbl	EQU	0		;Legacy split conditional

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSPRT -- System-dependent command to set the port used
;
;Not currently implemented for 2SIO as Channel 0 is almost
;always the console port.
;
;pre: HL contains the argument from the command table
;post: specified port is selected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysprt:
	ret

;The following equates should both be set to 0 to show
;SET PORT is not supported.
prttbl	equ	0		; SET PORT not supported
prhtbl	equ	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SELMDM -- Select modem port
;
;Called before using INPMDM or OUTMDM
;
;Preserves BC, DE, HL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
selmdm:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SELCON -- Select console port
;
;Called before using INPCON or OUTCON
;
;Preserves BC, DE, HL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
selcon:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPCON -- Get character from the console
;
;This function hands off to CP/M BDOS
;
;pre: console is initialized, CP/M is up
;post: A = result if char available
;      A = 0 if no char available
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inpcon:
	mvi	c,dconio	;Direct console I/O BDOS call.
	mvi	e,0FFH		;Input.
	call	BDOS
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTCON -- Output a character to the console
;
;This function hands off to CP/M BDOS
;
;pre: character to print is in E register
;post: character passed to CP/M BDOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outcon:
	mvi	c,dconio	;Console output bdos call.
	call	bdos		;Output the char to the console.
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTMDM -- Output a character to the modem
;
;Preserves BC, DE, HL
;
;pre: E register contains character to output
;post: character output to modem port
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outmdm:
	in	mnprts		;Get the output done flag.
	ani	output		;Is it set?
	jz	outmdm		;If not, loop until it is.
	mov	a,e
	out	mnport		;Output it.
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPMDM -- Input a character from the modem
;
;May destroy BC, DE, HL
;
;pre: modem port is initialized and selected
;post: A = result if byte available
;      A = 0 if no byte available
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inpmdm:
	in	mnprts		;Get the port status into A.
	ani	input		;See if the input ready bit is on.
	rz			;If not then return.
	in	mnport		;If so, get the char.
	ret			; return with character in A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FLSMDM -- Flush the modem communication line
;
;pre: modem is initialized and selected
;post: no characters remain in receiver register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flsmdm:	call	inpmdm		; Try to get a character
	ora	a		; Got one?
	jnz	flsmdm		; If so, try for another
	ret			; Receiver is drained.  Return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LPTSTAT -- Get the printer status
;
;post: A = 0FFh if printer is OK
;      A = 0 if printer is not OK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lptstat:
	xra	a		; assume it is ok.. this may not be necessary
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTLPT -- Output a character to the printer
;
;This function hands off to CP/M BDOS
;
;Preserves DE
;
;pre: E register contains character to print
;post: character printed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outlpt:
	push	d		;save DE in either case
	call	prtflt		;go through printer filter
	ana	a		
	jz	outlp1		;if A = 0 do nothing
	mvi	c,lstout
	call	bdos		;Char to printer
outlp1:	pop	d		;restore saved register pair
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DELCHR -- Make delete look like a backspace
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delchr:
	mvi	e,bs		;get a backspace
	jmp	outcon		;RET falls thru from OUTCON

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CLRSPC -- Erase the character at the current position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clrspc:	mvi	e,' '
	call	outcon
	mvi	e,bs		;get a backspace
	jmp	outcon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CLRLIN -- Erase the current line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clrlin:	lxi	d,eralin
	jmp	prtstr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CLRTOP -- Clear the screen and move to home position
;
;Preserves B, destroys C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clrtop:	lxi	d,erascr
	jmp	prtstr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSVER -- Version information string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF m2sio
sysver:	db	'MITS 88-2SIO channel 1$'
ENDIF ; m2sio

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Link in terminal routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF lasm
LINK CPXVDU.ASM
ENDIF   ;lasm - m80 will INCLUDE CPXVDU.ASM

IF lasm	; here if not a terminal selected and in LASM
ovlend	equ	$
	END
ENDIF	;lasm
