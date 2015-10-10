
    LD SP, 0FFFH
    LD A, 3FH
    OUT 03H
    OUT 06H
    OUT 07H
    LD A, 7FH
    OUT 02H
    LD H, 00H
    LD L, 00H
 START:   LD B, 80H
    LD C, 01H
    LD D,14H
    LD A,00H
    OUT(01H)
    OUT(04H)
    OUT(05H)
  IN A, (00H)
    CP 00H

    LD E, A
    LD A, B
    CP E

    CP E
    NOP
    NOP
   JP START 
  NOP
   NOP
   NOP
   NOP


   LD A, 20H
   OUT (01H)
   LD A, 40H
   OUT (01H)
   NOP
   NOP
   NOP
   INC H
   LD A, H
   DAA
   OUT (05H)
   JP SPACE
 
   LD A, 02H
   OUT (01H)
   LD A, 08H
   OUT (01H)
   NOP
   NOP
   NOP
   INC L
   LD A, L
   DAA
   OUT (04H)
   JP SPACE
 
SPACE:   LD A, H
    SUB L
    CP D
   JP NZ, START