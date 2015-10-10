; initialize ports as following
; A OUT, B IN, C OUT (82H)
START:	LD A, 82H
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
	JP Z, INCRB
	LD A, D ; reload original input
	AND 00001000B ; check for the second input at bit 3
	JP Z, DECRB
	JP TAKEIN


; increament and output on port A (00H)
INCRB:	INC B
	LD A, B
	OUT 00H
	JP TAKEIN

; decrement and output on port A (00H)
DECRB:	DEC B
	LD A, B
	OUT 00H
	JP TAKEIN