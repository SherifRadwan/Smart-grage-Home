; init the PPI
; A IN, B IN, C OUT
START:	LD A, 92H
	OUT 03H
	LD HL, ARR; load password saving adderess
	LD C, 00H; sum
	LD B, ARRSIZE
	
CR:	JP SUMA ; call suma
OUTE:	LD A, C
	OUT 02H
	JP OUTE

SUMA:	LD A, (HL)
	OUT 02H
	ADD C
	INC HL
	DEC B
	LD A, B
	JP NZ, SUMA ; RET Z
	JP OUTE

ARRSIZE	EQU 10D;
	
ARR:	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;
	DB 01H;