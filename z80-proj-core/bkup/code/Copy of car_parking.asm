START:	LD A, 82H
	OUT 03H
	LD B, 00H
TAKEIN:	IN 01H
	AND 01H
	CALL Z, INCRB
	JP TAKEIN


INCRB:	INC B
	LD B, A
	OUT 00H
	RET