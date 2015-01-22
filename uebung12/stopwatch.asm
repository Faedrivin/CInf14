/**
 * This is a stopwatch to count seconds from 0
 * through 59 and write the digits to PORTB
 * and PORTC as seven-segment-numbers.
 * (See INIT_TABLE for information on the 
 *  seven-segment-codes)
 * 
 * It is possible to pause the stopwatch
 * by setting PA1 or reset it via PA0.
 */

/**
 * Includes macros and names.
 */
.include "init_header.inc"

/**
 * Temp register.
 */
.def tmp = R16

/**
 * Holds the current time as compact BCD numbers.
 * That means the high byte represents the 10s,
 * while the low byte represents the 1s.
 */
.def time = R17

/**
 * Initialize the Lookup_Table. It is crucial that
 * its low byte is 0. See INIT_TABLE and SSEG_OUT.
 */
.dseg .org 0x400 Lookup_Table: .byte 10

/**
 * Start of code and interrupt vector table.
 * Jumps to STOPWATCH initially.
 * Sets INT0 jump target to ISR_CLOCK.
 */
.cseg 

.org 0 JMP STOPWATCH        ; Main program
.org INT0addr JMP ISR_CLOCK ; INT0 routine
.org OC0addr JMP ISR_CLOCK  ; T/C0 routine

.org SPMRaddr               ; program memory

/**
 * Initializes the I/O ports.
 *
 * in: -
 * out: -
 * Effect:
 *    PA0, PA1: IN, with pull-up
 *    PA2, PA3, PORTB, PORTC: OUT
 *    PD2: IN, no pull-up
 */
INIT_PORTS:
  PUSH tmp       ; save state

  ; PA0, PA1: in with pull-up
  CBI DDRA, PA0  ; switch to in
  CBI DDRA, PA1 
  SBI PORTA, PA0 ; enable pull-up
  SBI PORTA, PA1

  ; PA2, PA3: out
  SBI DDRA, PA2  ; switch to out
  SBI DDRA, PA3

  ; PORTB, PORTC: out
  SER tmp        ; switch to out
  OUT DDRB, tmp
  OUT DDRC, tmp

  ; PD2: in without pull-up
  CBI DDRD, PD2  ; switch to in
  CBI PORTD, PD2 ; disable pull-up

  POP tmp        ; restore state
  RET

/**
 * Initializes the lookup table Lookup_Table
 * in the data memory.
 * The Lookup_Table must start at an address
 * with the low-Byte being 0 to function 
 * properly with SSEG_OUT.
 * 
 * The values stored inside the Lookup_Table
 * are seven-segment-display codes for the 
 * digits 0-9, starting at 0.
 *
 * Each digit is represented in the form
 * 0b0gfedcba
 * where a-g are set to 1 if the segment
 * should be turned on for their respective
 * digit.
 *
 * The segments are ordered like this:
 * (+ separates the segments, - is just
 *  for visualization, a-g are the names)
 *      +-a-+
 *      f   b
 *      +-g-+
 *      e   c
 *      +-d-+
 *
 * in: -
 * out: -
 * Effect: Array of seven-segment display
 *         codes at Lookup_Table
 */
INIT_TABLE:
  PUSH tmp        ; save state
  PUSH XL
  PUSH XH

  SET_X_REG Lookup_Table
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
  RET

/**
 * Reads the current time and writes it to
 * the OUT ports for a seven-segment display.
 * The bits for the seven-segment display are
 * ordered like this:
 *   0b0gfedcba
 * For more explanations see INIT_TABLE.
 * 
 * The time has two digits, each written to 
 * an individual port.
 * The right digit, the low nibble, is 
 * written to PORTC, the high nibble to
 * PORTB.
 *
 * This method assumes that the 
 * Lookup_Table was stored with its
 * first value's lowbyte being 0,
 * to allow for fast lookups.
 *
 * in:  time compact BCD coded time
 *           10s in the high, 1s in the 
 *           low nibble
 * out: PORTB 7-segment coded high nibble
 *      PORTC 7-segment coded low nibble
 * Effect: -
 */
SSEG_OUT:
  PUSH tmp        ; save state
  PUSH XL
  PUSH XH

  SET_X_REG Lookup_Table
  ; 1s
  MOV XL, time   ; load time
  ANDI XL, 0x0f  ; keep low nibble of time
  LD tmp, X      ; load BCD code
  OUT PORTC, tmp ; write out

  ; 10s
  MOV XL, time   ; load time
  SWAP XL        ; swap high and low nibble
  ANDI XL, 0x0f  ; keep low nibble
  LD tmp, X      ; load BCD code
  OUT PORTB, tmp ; write out

  POP XH         ; restore state
  POP XL
  POP tmp
  RET

/**
 * Increments time by 1.
 * If the BCD number of the low nibble
 * is bigger than 9, an overflow to the 
 * high nibble is done to correctly represent
 * the compact BCD number.
 * If the high nibble flows over, the time
 * is reseted to 0.
 *
 * This does not restore the tmp register!
 *
 * in: time
 * out: time = time + 1 % 60 as BCD.
 * Effect: time is incremented correctly.
 */
COUNT_UP:
  INC time       ; +1 second
  MOV tmp, time
  ANDI tmp, 0x0f ; clear high nibble
  CPI tmp, 0x0a  ; if < 10: everything done
  BRLO Count_up_ret

  LDI tmp, 6     ; add 6 to time:
  ADD time, tmp  ;   increment high, zero low
  
  MOV tmp, time  ; check for overflow of high
  SWAP tmp       ; swap nibbles
  ANDI tmp, 0x0f ; clear high
  CPI tmp, 0x06  ; if < 6: everything done
  BRLO Count_up_ret

  CLR time       ; on overflow: clear

  Count_up_ret:
    RET

/**
 * Interrupt-Handler to increment the time.
 * Calls COUNT_UP if PA1 is not set.
 *
 * in: PA1
 * out: time + 1 if PA1 is not set, else void
 * Effect: calls COUNT_UP if PA1 is not set,
 *         always resets TCNT0 to 0.
 */
ISR_CLOCK:
  PUSH tmp       ; save state
  IN tmp, SREG
  PUSH tmp

  SBIS PINA, PA1 ; if PA1: pause!
  RCALL COUNT_UP
  
  POP tmp      ; restore state
  OUT SREG, tmp
  POP tmp
  RETI

/**
 * Configures interrupt handling, such that
 * a rising edge at INT0 (PD2) calls ISR_CLOCK.
 *
 * in: -
 * out: -
 * Effect: Configures the interrupt handling.
 *         If INT0 is set, ISR_CLOCK is called.
 *         Enables INT0 interrupt.
 *         Has an effect on SREG: sets I.
 */
INIT_EXT_INTERRUPT:
  PUSH tmp         ; store state

  IN tmp, MCUCR    ; get MCUCR state and set 
                   ; rising edge handling for MCUCR
  ORI tmp, (1 << ISC00)|(1 << ISC01)
  OUT MCUCR, tmp   ; rising edge: ISC00: 1
                   ;              ISC01: 1
  
  IN tmp, GICR     ; get GICR state and
  ORI tmp, (1 << INT0)
  OUT GICR, tmp    ; enable INT0 locally

  SEI              ; enable global interrupts

  POP tmp          ; restore state
  RET

/**
 * Configures interrupt handling, such that
 * every second an interrupt calls ISR_CLOCK.
 *
 * Uses the comparison method on timer/counter 0.
 * The prescale factor is 256, thus the comparison
 * value is set to 128, assuming a clock frequency
 * of 32,768 Hz.
 *
 * in: -
 * out: -
 * Effect: Configures the interrupt handling.
 *         TCNT0 <- 0, OCR0 <- 64, 
 *         TIMSK |= (1 << OCIEO),
 *         TCCR0 |= (1 << CS02)
 *         Has an effect on SREG: sets I.
 */
INIT_TCO_INTERRUPT:
  PUSH tmp         ; store state

  IN tmp, TIMSK    ; get TIMSK state and set 
  ORI tmp, (1 << OCIE0)
  OUT TIMSK, tmp   ; to compare match method
  
  IN tmp, TCCR0    ; get TCCR0 state and
  ANDI tmp, 0xf8   ; clear the CS00/01/02 bits
  ORI tmp, (1 << WGM01) | (1 << CS02)
  OUT TCCR0, tmp   ; set prescale 256 and reset
                   ; timer on reaching compare val

  LDI tmp, 128     ; set compare value to 2^7
  OUT OCR0, tmp

  CLR tmp          ; init counter to 0
  OUT TCNT0, tmp

  SEI              ; enable global interrupts

  POP tmp          ; restore state
  RET

/**
 * The main program.
 * Initializes the stack pointer, the 
 * Lookup_Table, the I/O ports and the
 * time.
 * 
 * Then loops infinitely and increments
 * the time whenever PD2 is set, unless
 * PA1 is also set (which pauses the 
 * counter).
 *
 * If PA0 is set, the time is reset to 0.
 *
 * In each loop iteration, the current time 
 * is written to the I/O ports (see SSEG_OUT).
 *
 * In: -
 * Out: never returns
 * Effect: infinite loop:
 *           resets time on PA0,
 *           calls SSEG_OUT on each iteration,
 *           calls COUNT_UP if PD2 but PA1 is set, 
 */
Stopwatch:
  INIT_STACK_PTR RAMEND, tmp
  RCALL INIT_TABLE
  RCALL INIT_PORTS
  ; ====== neccessary with interrupts ======
  ;RCALL INIT_EXT_INTERRUPT ; for INT0 interrupt
  RCALL INIT_TCO_INTERRUPT ; for T/C0 interrupt
  ; ========================================
  
  CLR time ; init time as 00

  Stopwatch_Loop: 
    ; reset watch before SSEG_OUT
    SBIC PINA, PA0 ; check for reset
    CLR time       ; reset: clear time

    RCALL SSEG_OUT ; output time

    ; ===== unneccessary with interrupts =====
    ; poll for PD2
    ;SBIS PIND, PD2 ; if PD2: COUNT_UP
    ;RJMP Loop
    ;SBIS PINA, PA1 ; if PA1: pause!
    ;CALL COUNT_UP
    ; ========================================

    RJMP Stopwatch_Loop ; continue infinite loop

.exit
