; initialize ports
; A OUT, B IN, C OUT (82H)
START:	LD A, 82H
	OUT 03H
	LD A, 00H
	LD B, 00H

; take input from port B (01H)
TAKEIN:  IN 01H
	AND 00000001B
	JP NZ, TAKEIN

; loop until input changes
LOOP:	IN 01H
	AND 00000001B
	JP Z, LOOP

; increament and output on port A (00H)
INCRB:	INC B
	LD A, B
	OUT 00H
	JP TAKEIN