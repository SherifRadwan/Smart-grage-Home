START:	LD A, 82H
	OUT 03H
	LD B, 00H
INCRB:	INC B
	OUT 00H
	JP INCRB