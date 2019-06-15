;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CPXACI.ASM -- KERMIT-80 Overlay for the Alspa ACI-2
;
;This file contains the system-dependent overlay for the
;Alspa ACI-2. It allows use of either the MODEM or PRINTER
;port.
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

	print	"* Assembling for Alspa ACI-2 *"

	INCLUDE "cpxdef.asm"	;Overlay definitions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set up Terminal Parameters
;
;Replace 'crt SET TRUE' with your selection of terminal. A
;list is available in CPXDEF.ASM or you can search through
;CPXVDU.ASM.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
termin	SET	TRUE
crt	SET	TRUE

	INCLUDE "cpxvdu.asm"	;Terminal/emulation code
	INCLUDE "cpxcom.asm"	;Common code, must come after CPXVDU

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CPU Specific Equates
;
;The ACI-2 comes with a 4 MHz Z80.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cpuspd	SET	40		;4.0 MHz CPU
z80	SET	TRUE		;Always a Z80

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Basic 2SIO Equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modems	equ	05h		;MODEM port status
modemd	equ	04h		;MODEM port data
prints	equ	01h		;PRINTER port status
printd	equ	00h		;PRINTER port data

output	equ	01h		;Bit of 8251 USART status for TX ready
input	equ	02h		;Bit of 8251 USART status for RX full
txempty	equ	04h		;Bit of 8251 USART status for TX empty

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Family string, used to idenfity system-dependent module
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
family:	db	'CPXACI.ASM  (1)  2019-06-14$'    ; Used for family versions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SYSXIN -- System-dependent initialization code
;
;Falls through to UARTRS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysxin:	
	mvi	a, modems	;Set up default port to MODEM
	sta	port		;I/O address of status register in PORT
	mvi	a, modemd
	sta	port+1		;I/O address of data register in PORT+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UARTRS -- Reset the selected 8251A USART
;
;This code is self-modifying, the I/O addresses will be
;dynamically updated when SET PORT is issued. It starts out
;defaulted to the MODEM port.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
uartrs:	
	lxi	h,urtini	;HL -> init sequence
	mvi	b,inilen	;Length of init sequence in B
uartr1:	mov	a,m		
uartr2:	out	modems		;Send byte to control/status port
	inx	h		;Increment init sequence pointer
	dcr	b		;Decrement count
	jnz	uartr1		;Send more bytes until B == 0
	ret			

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;URTINI -- Initialization sequence for 8251A USART
;
;This init string resets the USART into x16 clock, 8N1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
urtini: db	0, 0, 0, 40h, 4Eh, 37h
inilen	equ	$-urtini

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
	lxi	d,inhlps	;Pointer to help messages
	call	prtstr		;Print it
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INHLPS -- Additional system-dependent help for CONNECT
;          mode, two-character escape sequences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inhlps:
	db	cr,lf,'B  Transmit a BREAK'
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
	ani	5Fh		;Convert to uppercase
	cpi	'B'		;Send BREAK?
	jz	sendbr		;Yes, go send BREAK
	jmp	rskp		;Take skip return - command not recognized.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SENDBR -- Send a BREAK condition
;
;pre: none
;post: BREAK sent, line returned to normal operation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sendbr:
	in	modems		;Get status register
	ani	txempty		;Transmit register empty?
	jz	sendbr		;No, wait for line to clear
	mvi	a,3Fh		;TX ena, DTR, RX ena, BREAK, ERR reset, RTS
sendb1:	out	modems
	mvi	a,25		;Delay time in 10s of milliseconds
	call	delay		;Execute the delay
	mvi	a,37h		;TX ena, DTR, RX ena, ERR reset, RTS
sendb2:	out	modems
	ret

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
;This code modifies defaults in OUTMDM, INPMDM, UARTRS, and
;SENDBR due to the lack of an 8080 opcode with I/O port
;address specification.
;
;pre: HL contains the two-byte value from the command table
;pre: PRTTBL is set up
;post: specified port is selected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sysprt:	
	mov	a,l		;Get the channel status register address
	sta	outmdm+1	;Dynamically modify status port addresses
	sta	inpmdm+1
	sta	uartr2+1
	sta	sendbr+1
	sta	sendb1+1
	sta	sendb2+1
	mov	a,h		;Get the channel data register address
	sta	outmd1+1	;Dynamically modify data port addresses
	sta	inpmd1+1
	call	uartrs		;Reset the selected channel
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
	db	05H, 'MODEM$', modems, modemd
	db	07H, 'PRINTER$', prints, printd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRHTBL -- SET PORT help text
;
;This table pairs with PRTTBL to provide information on
;SET PORT options available. Set to 0 if SET PORT is not
;supported.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prhtbl:	db	cr, lf, 'MODEM port (4/5)'
	db	cr, lf, 'PRINTER port (0/1)$'

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
	call	bdos
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
	in	modems		;Get the output done flag.
	ani	output		;Is it set?
	jz	outmdm		;If not, loop until it is.
	mov	a,e
outmd1:	out	modemd		;Output it.
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
	in	modems		;Get the port status into A.
	ani	input		;See if the input ready bit is on.
	rz			;If not then return.
inpmd1:	in	modemd		;If so, get the char.
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
sysver:	db	'Alspa ACI-2$'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The following is included to keep the linkage section
;happy. We can't change the format as the main KERMIT
;module depends on it for now.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
swtver:	db	'CPXSWT.ASM (-1)  2019-06-14 $'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OVLEND -- Mark the end of the system-dependent overlay
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ovlend	equ	$	; End of overlay

	END
