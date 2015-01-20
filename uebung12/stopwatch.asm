/**
 */

/**
 * Includes macros and names.
 */
.include "init_header.inc"

.def tmp = R16
.def time = R17

.dseg .org 0x400 BCD_Table: .byte 10

/**
 * Start of the code segment: Jump to main program.
 */
.cseg .org 0 JMP Stopwatch

INIT_TABLE:
  PUSH tmp        ; save state
  IN tmp, SREG
  PUSH tmp
  PUSH XL
  PUSH XH

  SET_X_REG BCD_Table
         ; 0b0gfedcba
  LDI tmp, 0b00111111 ; 0
  ST X+, tmp
  LDI tmp, 0b00000110 ; 1
  ST X+, tmp
  LDI tmp, 0b01011011 ; 2
  ST X+, tmp
  LDI tmp, 0b01001111 ; 3
  ST X+, tmp
  LDI tmp, 0b01100110 ; 4
  ST X+, tmp
  LDI tmp, 0b01101101 ; 5
  ST X+, tmp
  LDI tmp, 0b01111101 ; 6
  ST X+, tmp
  LDI tmp, 0b00000111 ; 7
  ST X+, tmp
  LDI tmp, 0b01111111 ; 8
  ST X+, tmp
  LDI tmp, 0b01101111 ; 9
  ST X, tmp

  POP XH          ; restore state
  POP XL
  POP tmp
  OUT SREG, tmp
  POP tmp
  RET

SSEG_OUT:
  PUSH tmp        ; save state
  IN tmp, SREG
  PUSH tmp
  PUSH XL
  PUSH XH

  SET_X_REG BCD_Table
  ; 1s
  MOV XL, time  ; load time
  ANDI XL, 0x0f ; keep low nibble of time
  LD tmp, X     ; load BCD code
  OUT PORTC, tmp ; write out

  ; 10s
  MOV XL, time   ; load time
  SWAP XL        ; swap high and low nibble
  ANDI XL, 0x0f  ; keep low nibble
  LD tmp, X      ; load BCD code
  OUT PORTB, tmp  ; write out

  POP XH          ; restore state
  POP XL
  POP tmp
  OUT SREG, tmp
  POP tmp
  RET

/**
 *
 */
INIT_PORTS:
  PUSH tmp       ; save state
  IN tmp, SREG
  PUSH tmp

  ; PA0, PA1: in with pull-up
  CBI DDRA, PA0  ; switch to in
  CBI DDRA, PA1 
  SBI PORTA, PA0 ; enable pull-up
  SBI PORTA, PA1

  ; PA2, PA3: out low
  SBI DDRA, PA2  ; switch to out
  SBI DDRA, PA3
  ;CBI PORTA, PA2 ; set to low
  ;CBI PORTA, PA3

  ; PORTB, PORTC: out low
  SER tmp        ; switch to out
  OUT DDRB, tmp
  OUT DDRC, tmp
  ;CLR tmp        ; set to low
  ;OUT PORTB, tmp
  ;OUT PORTC, tmp

  ; PD2: in without pull-up
  CBI DDRD, PD2  ; switch to in
  CBI PORTD, PD2 ; disable pull-up

  POP tmp        ; restore state
  OUT SREG, tmp
  POP tmp
  RET

COUNT_UP:
  PUSH tmp       ; save state
  IN tmp, SREG
  PUSH tmp

  INC time       ; +1 second
  MOV tmp, time
  ANDI tmp, 0x0f ; clear high nibble
  CPI tmp, 0x0a  ; if < 10: everything done
  BRLO Count_up_ret
  LDI tmp, 6     ; add 6 to time to
  ADD time, tmp  ;   inc high, zero low
  
  MOV tmp, time  ; check for overflow high
  SWAP tmp       ; swap nibbles
  ANDI tmp, 0x0f ; clear high
  CPI tmp, 0x06  ; if < 6: everything done
  
  BRLO Count_up_ret
  CLR time       ; on overflow: clear

  Count_up_ret:
    POP tmp        ; restore state
    OUT SREG, tmp
    POP tmp
    RET

Stopwatch:
  INIT_STACK_PTR RAMEND, tmp
  CALL INIT_TABLE
  CALL INIT_PORTS
  
  CLR time ; init time as 00

  Loop:
    CALL SSEG_OUT ; output time
    
    SBIC PINA, PA0 ; check for reset
    CLR time       ; reset: clear time

    ; poll for PD2
    SBIS PIND, PD2 ; if PD2: COUNT_UP
    RJMP Loop
    SBIS PINA, PA1 ; if PA1: pause!
    CALL COUNT_UP

    RJMP Loop ; continue infinite loop



  TERMINATE


.exit
