; initialize ports as following
; A OUT, B IN, C OUT (82H)
START:	LD A, 8BH ;LD A, 82H
	OUT 03H
	LD B, 00H ; for the up/down counter value

; take input from port B (01H)
TAKEIN:  IN 01H
	LD D, A ; save the input

; loop until input changes
LOOP:	IN 01H
	CP D
	JP Z, LOOP
	
CHECK:	LD A, D ; restore original input
	AND 00000001B ; check for the first input at bit 0
	CALL Z, INCRB
	LD A, D ; reload original input
	AND 00001000B ; check for the second input at bit 3
	CALL Z, DECRB
	JP TAKEIN

; increament and output on port A (00H)
INCRB:	INC B
	LD A, B
	OUT 00H
	RET

; decrement and output on port A (00H)
DECRB:	DEC B
	LD A, B
	OUT 00H
	RET

MATSIZE	EQU 12D ; size of matrix
KEYMAT:	DB 00010001B ; 1 
	DB 00100001B ; 2
	DB 01000001B ; 3
	DB 00010010B ; 4
	DB 00100010B ; 5
	DB 01000010B ; 6
	DB 00010100B ; 7 
	DB 00100100B ; 8
	DB 01000100B ; 9
	DB 00011000B ; del 
	DB 00101000B ; 0
	DB 01001000B ; enter