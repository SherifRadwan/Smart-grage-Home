; init the PPI
; A IN, B IN, C OUT
START:	LD A, 92H
	OUT 03H
	LD HL, PASSA
	LD E, 00H ; log in state 0 = password hasn't been entered or wrong password
		 ; 	      1 = successful login


LOGTST:	LD A, E
	CP 01H ; logged in?
	CALL Z, TAKEIN

; take input, e.g password
; from port A (A0..A7)
; and from port B (B0..B3)
	
PASSG:	LD B, 00H
	LD C, 08H
	CALL SUBPG
	LD B, 01H
	LD C, 04H
	CALL SUBPG
	JP PASSCP ; jump to compare password with saved on

; sub routine to get bits from a port saved in B, with number of bits saved in C
SUBPG:	IN B ; B will have the port number, C will have the number of bits to be read
	LD D, A
	LD (IX+00), 00000001B ; mask byte, will be shifted to test all
 
; loop until input changes
LOOP:	IN 01H
	CP D
	JP Z, LOOP
	
	AND (IX+00)
	JP

	AND 00000001B
	JP NZ, TIN
	LD A, 07H
	OUT 02H
	RET; JP TIN

SAVEIN:	
; password address (where it will be saved)
PASSA	EQU 2009H

; define the password here
PASSD:	DB 07D
	DB 03D
	DB 05D
	DB 05D