;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CPXMIT.ASM -- KERMIT-80 Routines for MITS Interfaces
;
;This file contains system-dependent code for MITS 88-2SIO
;serial boards. It allows use of either port for
;situations when the 88-2SIO is not the system console.
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

.printx	* Assembling for MITS 88-2SIO board *

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Basic 2SIO Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
port0s	equ	010h		;Channel 0 status
port0d	equ	011h		;Channel 0 data
port1s	equ	012h		;Channel 1 status
port1d	equ	013h		;Channel 1 data

output	equ	02h		;Bit of 6850 ACIA status for TX empty
input	equ	01h		;Bit of 6850 ACIA status for RX full

z80	equ	FALSE		;Assume original 8080 CPU board

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Family string, used to idenfity system-dependent module
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
family:	db	'CPXMITS.ASM  (1)  2019-02-28$'    ; Used for family versions....

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSXIN -- System-dependent initialization code
;
;Falls through to ACIARS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysxin:	
	mvi	a, port1s	;Set up default port to Channel 1
	sta	port		;I/O address of status register in PORT
	mvi	a, port1d
	sta	port+1		;I/O address of data register in PORT+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ACIARS -- Reset the selected 6850 ACIA
;
;This code is self-modifying, the I/O addresses will be
;dynamically updated when SET PORT is issued. It starts out
;defaulted to Channel 1.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
aciars:	
	mvi	a, 03h		;6850 ACIA reset
aciar1:	out	port1s		;Reset Channel 1 ACIA
	mvi	a, 015h		;8N1
aciar2:	out	port1s		;Configure Channel 1 ACIA
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
	mov	a,e		;get character to test
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
	ret			;SET SPEED not supported

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SPDTBL -- SET SPEED options table
;
;This table specifies bitrates available for the SET SPEED
;command. Set to 0 if SET SPEED is not supported.
;
;Note that SPDTBL *MUST* be in alphabetical order for
;later lookup procedures.
;
;First byte of SPDTBL is the number of bitrates available
;
;Subsequent entries are:
;	* byte count of option string
;	* $-terminated option string (what the user types)
;	* E register value
;	* D register value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spdtbl	EQU	0		;SET SPEED not supported


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SPHTBL -- SET SPEED help text
;
;This table pairs with SPDTBL to provide information on
;SET SPEED bitrates available. Set to 0 if SET SPEED is 
;not supported.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sphtbl	EQU	0		;SET SPEED not supported

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSPRT -- System-dependent command to set the port used
;
;This code modifies defaults in OUTMDM, INPMDM, and ACIARS
;due to the lack of an 8080 opcode with I/O port address
;specification.
;
;pre: HL contains the two-byte value from the command table
;pre: PRTTBL is set up
;post: specified port is selected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysprt:	
	mov	a,l		;Get the channel status register address
	sta	outmdm+1	;Dynamically modify status port addresses
	sta	inpmdm+1
	sta	aciar1+1
	sta	aciar2+1
	mov	a,h		;Get the channel data register address
	sta	outmd1+1	;Dynamically modify data port addresses
	sta	inpmd1+1
	call	aciars		;Reset the selected channel
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRTTBL -- SET PORT options table
;
;This table specifies which devices are available for the
;SET PORT command. Set to 0 if SET PORT is not supported.
;
;First byte of PRTTBL is the number of devices available
;
;Subsequent entries are:
;	* byte count of option string
;	* $-terminated option string (what the user types)
;	* port control/status address (in L when SYSPRT 
;	  called)
;	* port data address (in H when SYSPRT called)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prttbl:	db	02H
	db	01H, '0$', port0s, port0d
	db	01H, '1$', port1s, port1d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRHTBL -- SET PORT help text
;
;This table pairs with PRTTBL to provide information on
;SET PORT options available. Set to 0 if SET PORT is not
;supported.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prhtbl:	db	cr, lf, '0 for 88-2SIO Channel 0'
	db	cr, lf, '1 for 88-2SIO Channel 1$'

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
;This code is self-modifying, the I/O addresses will be
;dynamically updated when SET PORT is issued. It comes up
;defaulted to use Channel 1.
;
;pre: E register contains character to output
;post: character output to modem port
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outmdm:
	in	port1s		;Get the output done flag.
	ani	output		;Is it set?
	jz	outmdm		;If not, loop until it is.
	mov	a,e
outmd1:	out	port1d		;Output it.
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPMDM -- Input a character from the modem
;
;May destroy BC, DE, HL
;
;This code is self-modifying, the I/O addresses will be
;dynamically updated when SET PORT is issued. It comes up
;defaulted to use Channel 1.
;
;pre: modem port is initialized and selected
;post: A = result if byte available
;      A = 0 if no byte available
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inpmdm:
	in	port1s		;Get the port status into A.
	ani	input		;See if the input ready bit is on.
	rz			;If not then return.
inpmd1:	in	port1d		;If so, get the char.
	ret			; return with character in A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FLSMDM -- Flush the modem communication line
;
;pre: modem is initialized and selected
;post: no characters remain in receiver register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flsmdm:	
	call	inpmdm		; Try to get a character
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
clrspc:	
	mvi	e,' '
	call	outcon
	mvi	e,bs		;get a backspace
	jmp	outcon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CLRLIN -- Erase the current line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clrlin:	
	lxi	d,eralin
	jmp	prtstr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CLRTOP -- Clear the screen and move to home position
;
;Preserves B, destroys C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clrtop:	
	lxi	d,erascr
	jmp	prtstr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSVER -- Version information string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysver:	db	'MITS 88-2SIO$'

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
