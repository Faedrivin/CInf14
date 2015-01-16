/*
 * factorial.asm
 *
 *  Created: 16.01.2015 22:03:19
 *   Author: Rasmus
 */ 

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
 * Register names
 */

.def n = R16 // argument

.def result = R18 // result location

.def tmp = R19 // temporary location for calcs


.cseg 

.org 0

/**
 * Runs the program after initializing the 
 * the stack pointer.
 *
 * An example arugment is supplied with INIT_FACTORIAL.
 *
 * After the program is finished, the TERMINATE macro is
 * called, resulting in an infinite loop.
 *
 * in:     void
 * out:    void
 * Effect: Runs the program.
 */
Main_Entry_Point:
    INIT_STACK_PTR RAMEND     // init stack pointer
    
    .ifndef INIT_FCATORIAL
        .message "Define INIT_FACTORIAL for your division. Using example."
    .endif
    CALL INIT_FACTORIAL       // shall create the correct array
    
    CALL FACTORIAL   // run the program
    
    TERMINATE                 // terminate in infinite loop


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
		CPI n, 0
		BREQ Abort	; if <= 0, this is bullshit 
		MOV tmp, n	; else save in tmp
		LDI result, 1 ; result is at least 1
	Loop:
		; while tmp != 0 do result *= tmp--
		TST tmp		; check if counter is down to zero
		BREQ Clean	; if yes, exit
		MUL result, tmp ; else multiply intermediate by current decrement
		MOV result, R0 ; product is placed in R0 so, move out (this can perhaps be avoided)
		DEC tmp		; decrement n
		RJMP Loop	; continue

	Abort:
		LDI result, 0 ; bad argument, set result to 0 (normally impossible)
		RJMP Clean	; restore shit

	Clean:			; get all status back to what it was before
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

.exit
