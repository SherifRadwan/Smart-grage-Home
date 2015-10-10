; init the PPI
; A IN, B IN, C OUT
START:
	LD A, 92H
	OUT 03H
	LD SP, 7FF6H

CLEAR:	
	LD HL, PASSA
	LD DE, PASSD

	LD A, 00H
	LD (FANSTAT), A ; fan stat 0 = off, 1 = first speed, 2 = second speed
	LD (OUTSTAT), A ; output stat saved
	LD (LOGFLAG), A ; log in state (flag) 0 = password hasn't been entered
			;			    wrong password
		 	;			    or cleared
		  	; 	      		1 = successful login
	LD C, 00H ; password length (count of bytes entered)
	JP CHECK


; FIXME: using interrupts is better here
LOGTST:
	LD A, (LOGFLAG)
	CP 01H ; logged in?
	JP Z, TAKEIN	; logged in
	JP CLEAR	; not logged in, recheck

; check for password input
; data available "DA" pin at the first bit of PORT C (C4..C7)
CHECK:
	IN 01H ; get data from port B
	LD B, A

LOOP:	IN 01H
	CP B
	JP Z, LOOP
	
	; check for data availability
	LD A, B
	AND 00000001B
	JP Z, CHECK ; no key available

	IN 00H ; ok key is available, read it
	LD B, A ; temp storage

	CP 10D ; key is 10 (clear)?
	JP Z, CLEAR ; then clear

	LD A, B ; reload key

	CP 11D ; key is 11 (enter)?
	JP Z, INITC ; compare password

	JP SAVEIN ; else save data


; read the inputs of bits 4, 5, 6 of PORT B
; bit 4 	fan control
; bit 5, 6	two sensors control
TAKEIN:
	; open the door first
	CALL DOORO

	IN 01H ; take input
	LD B, A
	
; wait for input to change
LOOP2:	
	IN 01H
	CP B
	JP Z, LOOP2
	
	LD A, B
	BIT 4, A ; test bit 4
	CALL Z, TOGFAN ; toggle fan
	
	LD A, B
	BIT 5, A
	
	LD A, 15D
	OUT 02H
	JP LOGTST ; go to test login again

; open door
DOORO:	
	LD A, (OUTSTAT) ; load current output stat
	SET 0, A ; set the first bit, door is opened
	LD (OUTSTAT), A ; save output stat
	OUT 03H
	RET

; close door
DOORC:
	LD A, (OUTSTAT) ; load current output stat
	RES 0, A ; set the first bit, door is opened
	LD (OUTSTAT), A ; save output stat
	OUT 03H
	RET


; toggle fan
TOGFAN:
	LD A, (OUTSTAT) ; load current output stat
	LD B, (FANSTAT) ; load current fan stat
	
; compare password and set the loggin flag
; FIXME: length checked every time
INITC:
	LD A, C
	LD B, C ; save current length to memory
	CP 04D ; check for current length
	JP NZ, CLEAR ; length is not equal to our password 7358
	
	; length is ok, start comparison

	LD DE, PASSD ; reset password address
	LD HL, PASSA ; reset password saving address

PASSC:	LD A, (DE) ; get a byte
	CP (HL)	       ; and compare
	JP NZ, CLEAR ; the two bytes are not equal
	
	INC DE
	INC HL
	DEC B

	JP NZ, PASSC ; compare next two bytes
	
	LD A, 01H
	LD (LOGFLAG), A ; login success
	JP LOGTST
	

; save a byte stored in B
; in its location start from PASSA
SAVEIN:	
	LD (HL), B
	INC HL
	INC C
	JP CHECK

; password saving addresss (where it keypad input be saved in RAM)
OUTSTAT	EQU 200AH
SENSOR1	EUQ 200BH
SENSOR2 EQU 200CH
FANSTAT	EQU 200DH
LOGFLAG	EQU 200EH
PASSA	EQU 200FH

; define the password here
PASSD:
	DB 07D
	DB 03D
	DB 05D
	DB 08D
