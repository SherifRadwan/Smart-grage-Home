START:	LD A, 82H
	OUT 03H
	LD A, 00H
	LD B, 00H

TAKEIN:  IN 01H
	AND 01H
	JP NZ, TAKEIN
	INC B
	LD A, B
	OUT 00H
	JP TAKEIN