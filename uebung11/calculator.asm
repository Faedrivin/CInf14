/*
 * calculator.asm
 *
 *  Created: 17.01.2015 13:53:36
 *   Author: Rasmus
 */ 

/**
 * Includes macros and names.
 */
.include "init_header.inc"

/**
 * Left Operand: numerator, factorial argument, first summand, minuend.
 */
.def operandLeft = R16

/**
 * Right Operand: denominator, second summand, subtrahend.
 */
.def operandRight = R17

/**
 * Result: result.
 */
.def result = R18

/**
 * Remainder: The remainder for division.
 */
.def remainder = R19

/**
 * Temp. Used by the main program to store the command selection.
 * Also used by the factorial.
 */
.def tmp = R20

 /**
 * Start of the code segment.
 */
.cseg

/**
 * Program starts at 0.
 */
.org 0

Main_Program_Calculator:
		INIT_STACK_PTR RAMEND, tmp
		CALL INIT_PORTS      ; should we save contents of R16-19 here?
		IN tmp, PINB      ; load everything from PINB
		ANDI tmp, 0x03    ; mask out all but the lower two bits
		CPI tmp, 0x00     ; controls == 00 => sum
		BREQ Sum
		CPI tmp, 0x01     ; controls == 01 => difference
		BREQ Subtract
		CPI tmp, 0x02     ; controls == 10 => quotient
		BREQ Div
		CPI tmp, 0x03     ; controls == 11 => factorial
		BREQ Fact         
		RJMP End          ; on invalid input terminate

	Sum:
		IN operandLeft, PINA       ; read 2 summands from input pins
		IN operandRight, PINC
		ADD operandLeft, operandRight  ; add
		OUT PORTD, operandLeft     ; write out
		RJMP End
	Subtract:
		IN operandLeft, PINA
		IN operandRight, PINC
		SUB operandLeft, operandRight
		OUT PORTD, operandLeft
		RJMP End
	Div:
		IN operandLeft, PINA    ; load arguments from input pins
		IN operandRight, PINC
		CALL DIVIDE             ; subroutine will operate on R16-R19
		OUT PORTD, result
		RJMP End
	Fact:
		IN operandLeft, PINA
		CALL FACTORIAL          ; subroutine will operate on R16 and R18
		OUT PORTD, result

	End:
		TERMINATE               ; endless loop macro
		

INIT_PORTS:
	PUSH tmp                   ; save whatever is in tmp
	IN tmp, SREG               ; use it to get status flags
	PUSH tmp                   ; put them on stack

	/* init a and c */
	CLR tmp                    ; set tmp to all 0s
	OUT DDRA, tmp              ; set all bits of PORTA and PORTC to be inputs
	OUT DDRC, tmp
	SER tmp                    ; set tmp to all 1s
	OUT PORTA, tmp             ; activate internal pull-up resistors for port a and c (necessary?)
	OUT PORTC, tmp             ; now data can be read from PINA and PINC

	 /* init d */ 
	OUT DDRD, tmp              ; set all bits of PORTD to be outputs, now data can be written to PORTD

	// init b
	CBI DDRB, PB0	            ; set 1st and 2nd bit of PINB to be inputs, rest will stay the same		
	CBI DDRB, PB1	
	SBI PORTB, PB0             ; set lower 2 pins of PORTB to 1 so PINB(0,1) will have activated pull-up resistors (whatever that means)
	SBI PORTB, PB1             ; now we can read from PINB0 and PINB1 to get the command select signals

	POP tmp                    ; get status flags back from stack
	OUT SREG, tmp              ; restore status flags
	POP tmp                    ; get original R16 contents back from stack
	RET

/**
 * Performs the division numerator / denominator = quotient remainder
 * The denominator must not be 0. If it is, quotient and remainder are 
 * set to 0 and $ff respectively and the subroutine returns.
 *
 * in: operandLeft (numerator), operandRight (denominator)
 * out: result (quotient) and remainder
 * Effect: divides numerator by denominator and stores the results.
 */
DIVIDE:
    // check if denominator is 0, if yes interrupt, else continue at InitDiv
	TST operandRight
	BRNE InitDiv
	// if div 0, set quotient to 0 and remainder to $ff and return to terminate
	LDI result, 0
	SER remainder
	RET

	// copy numerator to remainder and initialize quotient
	InitDiv:
	    MOV remainder, operandLeft
	    LDI result, 0

	// While remainder >= denominator, subtract denominator from
	// remainder and increment 
    LoopDiv:
	    CP remainder, operandRight
		BRLO EndDiv
		SUB remainder, operandRight
		INC result
		RJMP LoopDiv
	EndDiv:
        RET

/**
 * Computes the factorial function
 *
 * in:	n, positive integer in R16
 * out: n!, positive integer truncated to 8 bits in R18
 */
FACTORIAL:
		PUSH tmp	; save current gloabl state
		PUSH R0		; Multiply operattions always write to R1.R0
		PUSH R1
		IN R1, SREG ; R1 saved, so use to load SREG
		PUSH R1		; push anew
		CPI operandLeft, 0
		BREQ Abort	         ; if <= 0, this is bullshit 
		MOV tmp, operandLeft ; else save in tmp
		LDI result, 1        ; result is at least 1
	LoopFact:
		; while tmp != 0 do result *= tmp--
		TST tmp		; check if counter is down to zero
		BREQ EndFact	; if yes, exit
		MUL result, tmp ; else multiply intermediate by current decrement
		MOV result, R0  ; product is placed in R0 so, move out (this can perhaps be avoided)
		DEC tmp		    ; decrement n
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



.exit
