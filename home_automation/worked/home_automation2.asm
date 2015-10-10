; init the PPI
; A IN, B IN, C OUT
START:
	LD A, 92H
	OUT 03H
	LD SP, 2710H

CLEAR:	
	LD HL, PASSA
	LD DE, PASSD

	LD A, 00H
	;LD (FANSTAT), A ; fan stat 0 = off, 1 = first speed, 2 = second speed
	LD (OUTSTAT), A ; output stat saved
	LD (SEN1STAT), A ; sensor1 stat saved
	LD (SEN2STAT), A ; sensor2 stat saved
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


; first open the door and toggle with speed 1
INITIN:
	CALL DOORO ; open door
	CALL TOGFAN  ; toggle fan
	CALL TOGLGHT ; toggle light
	RET

; read the inputs of bits 4, 5, 6 of PORT B
; bit 4 	fan control
; bit 5, 6	two sensors control
TAKEIN:	IN 01H ; take input
	LD B, A
	
; wait for input to change
LOOP2:	
	IN 01H
	CP B
	JP Z, LOOP2
	
	LD A, B ; restore

	BIT 4, B ; test bit 4
	CALL Z, TOGFAN ; toggle fan
	
	BIT 5, B ; test bit 5
	CALL Z, SENSOR1
	BIT 6, B ; test bit 6 
	CALL Z, SENSOR2
	;CALL TOGSEN ; toggle door and lights

	JP LOGTST ; go to test login again

; open door
DOORO:	
	LD A, (OUTSTAT) ; load current output stat
	SET 0, A ; set the first bit, door is opened
	LD (OUTSTAT), A ; save output stat
	OUT 02H
	RET

; close door
DOORC:
	LD A, (OUTSTAT) ; load current output stat
	RES 0, A ; set the first bit, door is opened
	LD (OUTSTAT), A ; save output stat
	OUT 02H
	RET


; toggle fan directly from last output
TOGFAN:
	LD A, (OUTSTAT) ; load current output stat
	LD (OUTSTAT), A
	BIT 2, A ; test for speed1?
	JP NZ, SPEED2 ; yes, go to speed2
	BIT 3, A ; test for speed2
	JP Z, SPEED1 ; no, go to speed1
	CALL SPEED0
	RET

SPEED0:	
	RES 2, A
	RES 3, A
	LD (OUTSTAT), A
	OUT 02H
	RET

SPEED1: 
	SET 2, A
	RES 3, A
	LD (OUTSTAT), A
	OUT 02H
	RET

SPEED2:	
	SET 3, A ; speed0 off
	RES 2, A
	LD (OUTSTAT), A
	OUT 02H
	RET


TOGLGHT:
	LD A, (OUTSTAT) ; load current output stat
	BIT 1, A
	JP NZ, LHTRES
	JP LHTSET
	RET

LHTRES:	RES 1, A
	LD (OUTSTAT), A
	OUT 02H
	JP TAKEIN

LHTSET:	SET 1, A
	LD (OUTSTAT), A
	OUT 02H
	RET
	JP TAKEIN

SENSOR1:
	LD A, (OUTSTAT) ; load current output stat
	RES 1, A
	LD (OUTSTAT), A
	OUT 02H
	RET

SENSOR2:
	LD A, (OUTSTAT) ; load current output stat
	SET 1, A
	LD (OUTSTAT), A
	OUT 02H
	RET

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
	CALL INITIN
	JP LOGTST
	

; save a byte stored in B
; in its location start from PASSA
SAVEIN:	
	LD (HL), B
	INC HL
	INC C
	JP CHECK

; password saving addresss (where it keypad input be saved in RAM)
OUTSTAT	EQU 2050H
SEN1STAT EQU 2051H
SEN2STAT EQU 2052H
;FANSTAT	EQU 2053H
LOGFLAG	EQU 2054H
PASSA EQU 2055H

; define the password here
PASSD:
		DB 07D
		DB 03D
		DB 05D
		DB 08D
