; init the PPI
; A IN, B IN, C0..C3 OUT, C4..c7 IN
START:
	LD A, 9AH
	OUT 03H
	LD SP, 7FF6H

CLEAR:	
	LD HL, PASSA
	LD IY, PASSLEN
	LD IX, PASSD
	LD C, 00H ; password length (count of bytes entered)
	LD E, 00H ; log in state (flag) 0 = password hasn't been entered
		  ;			    wrong password
		  ;			    or cleared
		  ; 	      		1 = successful login
	JP CHECK

; FIXME: using interrupts is better here
LOGTST:
	LD A, E
	CP 01H ; logged in?
	JP Z, TAKEIN

; check for password input
; data available "DA" pin at the first bit of PORT C (C4..C7)
CHECK:
	IN 02H ; get data from port C
	LD D, A

; wait until data changes
LOOP:	IN 02H
	CP D
	JP Z, LOOP ; loop
	
	LD A, D
	AND 01H
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


; compare password and set the loggin flah
 ; FIXME: length checked every time
INITC:
	LD A, C ; save current length to memory
	LD (IY+00), A
	CP 04D
	JP NZ, CLEAR ; length is not equal to our password 7358
	LD HL, PASSD ; password address to HL

	; test reaching here
	LD A, 31D
	OUT 02H

PASSC:	LD A, (IX+00H) ; get a byte
	CP (HL)	       ; and compare	
	JP NZ, CLEAR ; byte is not equal
	
	INC HL
	INC IX
	DEC (IY+00H)
	
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



; password and length addresss (where it will be saved)
PASSLEN	EQU 2009H
PASSA	EQU 200AH

; define the password here
PASSD:
	DB 07D
	DB 03D
	DB 05D
	DB 08D
