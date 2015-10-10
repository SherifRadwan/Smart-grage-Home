; init the PPI
; A IN, B IN, C OUT
START:	LD A, 92H
	OUT 03H
	LD B, 00H ; no login
	LD C, 00H ; password size
	LD HL, PASSA ; load password saving adderess
	LD D, 00H ; save input in D
	
; get password
GPASS:	IN 00H ; check for the first port
	LD D, A
	LD (2009H), A
	CALL SAVEIN

; wait until input changes
LOOP:	IN 00H
	CP D
	JP Z, LOOP


SAVEN:	LD (HL), A
	INC HL ; increment passoword pointer (address)
	INC C ; increament size
	RET

; compare password
CPASS:	


LOGIN 	EQU 01H ; login code status

PASSA	EQU 3E80H ; address of saving password  =  16000 decimal

PASS:	DB 07D
	DB 03D
	DB 00D
	DB 05D