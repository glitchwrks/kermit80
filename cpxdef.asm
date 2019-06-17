;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CPXDEF.ASM -- Common definitions for system-dependent
;               overlays
;
;This file contains common equates used for the various
;system-dependent overlays. This is part of the Glitch
;Works dependency restructure.
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

FALSE	EQU	0
TRUE	EQU	NOT FALSE

ovladr	EQU	7000H		; [18] address = 6c00h for Kermit v4.10

cpsker	EQU	FALSE		;Building an overlay, not main KERMIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Defaults for System Information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iobyt	SET	FALSE		;assume we dont want IOBYTE..
inout	SET	FALSE		;... or IN/OUT code
cpuspd	SET	20		;default to 2 MHz CPU speed
z80	SET	FALSE		;assume 8080, set TRUE for Z80 systems
gener	SET	FALSE		;Not a generic/IOBYTE version
cpm3	SET	FALSE		;assume not CP/M 3
apmmdm	SET	FALSE		;Not the Apple II
osi	SET	FALSE		;Not OSI
px8	SET	FALSE		;Not the Epson PX-8
torch	SET	FALSE		;Not the Torch
z80mu	SET	FALSE		;Not a Z80 Emulation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Defaults for Terminal Selection
;
;For systems with a serial console terminal, one of the
;following should be selected in the overlay.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
termin	SET	FALSE		; we are not using a terminal
crt	SET	FALSE		;Basic CRT, no cursor positioning
adm3a	SET	FALSE		;Adm3a Display (or CPT built-in display)
adm22	SET	FALSE		;ADM 22 terminal
h1500	SET	FALSE		;Hazeltine 1500
smrtvd	SET	FALSE		;Netronics Smartvid terminal.
soroq	SET	FALSE		;Soroq IQ-120.. this a guess [OBS]
am230	SET	FALSE		;Ampro 230 [13]
tvi912	SET	FALSE		;[10] TVI912/920
tvi925	SET	FALSE		;TVI925 Display/Freedom 100
vt52	SET	FALSE		;VT52 or equivalent (or H19)
vt100	SET	FALSE		;VT100 or equivalent
wyse	SET	FALSE		;Wyse 100 terminal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Equates for Toad Hall TAC Trap
;
;If you're going through a TAC, it will cough on its 
;Intercept Character (usually a @ (* - 40H)).  Sending it
;twice forces the TAC to recognize it as a valid ASCII
;character, and it'll send only one on to the host.  If 
;you've SET the TACTrap to OFF, it will be a null character
;and nothing will happen.  If you set it on, it will be 
;your selected TAC intercept character (or will default to
;the common intercept char, '@'. If you never expect to 
;have to work through such a beastie, just set TAC to false
; and forget all this mess.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tac	EQU	FALSE		; gonna work through a TAC?
tacval	EQU	'@'             ;Typical TAC intercept character

	INCLUDE "cpsdef.asm"	;Common definitions
	INCLUDE "cpxlnk.asm"	;Linkage area
