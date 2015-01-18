/*
 * calculator.asm
 *
 *  Created: 17.01.2015 13:53:36
 *   Author: Rasmus
 */ 


.device ATmega16

.include "m16def.inc"

.macro INIT_STACK_PTR 
    LDI result, low(@0)		; use result because it's gonna be overwritten anyway
    OUT SPL, result
    LDI result, high(@0)
    OUT SPH, result
.endmacro

/**
 * Provides a macro for an infinite loop to handle default
 * termination of the main program.
 *
 * in:     void
 * out:    void
 * Effect: infinite loop.
 */
.macro TERMINATE
    Termination_Loop:
        RJMP Termination_Loop
.endmacro


/**
 * Divide: The numerator.
 */
.def numerator = R16

/**
 * Factorial: Argument to factorial
 */
.def n = R16 

/**
 * Add: First summand
 */
.def summand1 = R16

/**
 * Subtract: Subtrahend
 */
.def subtrahend = R16

/**
 * Divide: The denominator.
 */
.def denominator = R17

/**
 * Add: Second summand1
 */
.def summand2 = R17

/**
 * Subtract: minuend
 */
.def minuend = R17

/**
 * Divide: The quotient.
 */
.def quotient = R18

/**
 * Factorial: Result of factorial
 * Subtract: result of subtraction
 */
.def result = R18 

/**
 * Divide: The remainder.
 */
.def remainder = R19

/**
 * Factorial: temporary location for calcs
 */
.def tmp = R19  

/**
 * Main program: Location to store the command selection
 */
 .def operation = R19


.cseg

.org 0

MAIN_PROGRAM_CALCULATOR:
		INIT_STACK_PTR RAMEND
		CALL INIT_PORTS         ; should we save contents of R16-19 here?
		IN operation, PINB      ; load everything from PINB
		ANDI operation, 0x03    ; mask out all but the lower two bits
		CPI operation, 0x00     ; controls == 00 => sum
		BREQ Sum
		CPI operation, 0x01     ; controls == 01 => difference
		BREQ Subtract
		CPI operation, 0x02     ; controls == 10 => quotient
		BREQ Div
		CPI operation, 0x03     ; controls == 11 => factorial
		BREQ Fact               ; the check can be avoided, but like this is easier to read
      ; there is no else case

	Sum:
		IN summand1, PINA       ; read 2 summands from input pins
		IN summand2, PINC
		ADD summand1, summand2  ; add
		OUT PORTD, summand1     ; write out
		RJMP End
	Subtract:
		IN subtrahend, PINA
		IN minuend, PINC
		SUB subtrahend, minuend
		OUT PORTD, subtrahend
		RJMP End
	Div:
		IN numerator, PINA      ; load arguments from input pins
		IN denominator, PINC
		CALL Divide             ; subroutine will operate on R16-R19
		OUT PORTD, quotient
		RJMP End
	Fact:
		IN n, PINA
		CALL Factorial          ; subroutine will operate on R16 and R18
		OUT PORTD, result

	End:
		TERMINATE               ; endless loop macro
		

INIT_PORTS:
	PUSH R16                   ; save whatever is in R16
	IN R16, SREG               ; use it to get status flags
	PUSH R16                   ; put them on stack

	/* init a and c */
	CLR R16                    ; set R16 to all 0s
	OUT DDRA, R16              ; set all bits of PORTA and PORTC to be inputs
	OUT DDRC, R16
	SER R16                    ; set R16 to all 1s
	OUT PORTA, R16             ; activate internal pull-up resistors for port a and c (necessary?)
	OUT PORTC, R16             ; now data can be read from PINA and PINC

	 /* init d */ 
	OUT DDRD, R16              ; set all bits of PORTD to be outputs, now data can be written to PORTD

	// init b
	CBI DDRB, PB0	            ; set 1st and 2nd bit of PINB to be inputs, rest will stay the same		
	CBI DDRB, PB1	
	SBI PORTB, PB0             ; set lower 2 pins of PORTB to 1 so PINB(0,1) will have activated pull-up resistors (whatever that means)
	SBI PORTB, PB1             ; now we can read from PINB0 and PINB1 to get the command select signals

	POP R16                    ; get status flags back from stack
	OUT SREG, R16              ; restore status flags
	POP R16                    ; get original R16 contents back from stack
	RET

DIVIDE:
    // check if denominator is 0, if yes interrupt
	TST denominator
	BRNE Init
	// if div 0, set quotient and remainder to $ff and return to terminate
	SER quotient
	SER remainder
	RET

	// copy numerator to remainder and initialize quotient
	Init:
	    MOV remainder, numerator
	    LDI quotient, 0

	// While remainder >= denominator, subtract denominator from
	// remainder and increment 
    LoopDiv:
	    CP remainder, denominator
		BRLO EndDiv
		SUB remainder, denominator
		INC quotient
		RJMP LoopDiv
	EndDiv:
        RET

FACTORIAL:
		PUSH tmp	; save current gloabl state
		PUSH R0		; Multiply operattions always write to R1.R0
		PUSH R1
		IN R1, SREG ; R1 saved, so use to load SREG
		PUSH R1		; push anew
		CPI n, 0
		BREQ Abort	; if <= 0, this is bullshit 
		MOV tmp, n	; else save in tmp
		LDI result, 1 ; result is at least 1
	LoopFact:
		; while tmp != 0 do result *= tmp--
		TST tmp		; check if counter is down to zero
		BREQ EndFact	; if yes, exit
		MUL result, tmp ; else multiply intermediate by current decrement
		MOV result, R0 ; product is placed in R0 so, move out (this can perhaps be avoided)
		DEC tmp		; decrement n
		RJMP LoopFact	; continue

	Abort:
		LDI result, 0 ; bad argument, set result to 0 (normally impossible)
		RJMP EndFact	; restore shit

	EndFact:			; get all status back to what it was before
		POP R1
		OUT SREG, R1
		POP R1
		POP R0
		POP TMP
		RET



.ifndef INIT_FACTORIAL
    INIT_FACTORIAL:
        LDI n, 5
        RET
.endif

.ifndef INIT_DIVISION
    INIT_DIVISION:
        LDI numerator, 10
		LDI denominator, 3
        RET
.endif

.exit
