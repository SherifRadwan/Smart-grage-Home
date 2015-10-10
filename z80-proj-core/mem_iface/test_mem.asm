START:	LD A, (3233H) ; read from EEPROM
	LD (2009H), A ; write from RAM
	JP START