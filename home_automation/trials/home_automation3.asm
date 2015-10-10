; init the PPI
; A IN, B IN, C OUT
START:
	LD A, 92H
	OUT 03H
	LD SP, 7FF6H

CLEAR:	
	LD IX, PASSD
	LD HL, PASSA
	LD C, 00H ; password length (count of bytes entered)
	LD E, 00H ; log in state (flag) 0 = password hasn't been entered
		  ;			    wrong password
		  ;			    or cleared
		  ; 	      		1 = successful login
	JP CHECK


; FIXME: using interrupts is better here
LOGTST:
	LD A, E
	AND 01H ; logged in?
	JP NZ, TAKEIN

; check for password input
; data available "DA" pin at the first bit of PORT C (C4..C7)
CHECK:
	IN 01H ; get data from port B
	LD D, A

LOOP:	IN 01H
	CP D
	JP Z, LOOP
	
	; check for data availability
	LD A, D
	AND 00000001B
	JP Z, CHECK ; no key available

	IN 00H ; ok key is available, read it
	LD D, A ; temp storage

	CP 10D ; key is 10 (clear)?
	JP Z, CLEAR ; then clear

	LD A, D ; reload key

	CP 11D ; key is 11 (enter)?
	JP Z, INITC ; compare password

	; test reaching here
	JP SAVEIN ; else save data



TAKEIN:
	IN 01H
	LD A, 15D
	OUT 02H
	JP LOGTST ; go to test login again


; compare password and set the loggin flag
 ; FIXME: length checked every time
INITC:
	LD A, C
	LD B, C ; save current length to memory
	CP 04D ; check for current length
	JP NZ, CLEAR ; length is not equal to our password 7358
	
	; length is ok, start comparison

	LD IX, PASSD ; reset password address
	LD HL, PASSA ; reset password saving address

PASSC:	LD A, (IX+00H) ; get a byte
	CP (HL)	       ; and compare
	JP NZ, CLEAR ; the two bytes are not equal
	
	INC IX
	INC HL
	DEC B

	JP NZ, PASSC ; compare next byte

	LD E, 01H ; login success
	JP LOGTST
	

; save password byte stored in D
; in its location
SAVEIN:	
	LD (HL), D
	INC HL
	INC C
	JP CHECK

; login flag and password saving address
LOGF	EQU 2009H
PASSA	EQU 200AH

; define the password here
PASSD:
	DB 07D
	DB 03D
	DB 05D
	DB 08D
