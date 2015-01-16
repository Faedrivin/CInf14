/**
 * This program performs the division numerator / denominator = quotient 
 * and remainder.
 * The denominator must not be 0. If it is, quotient and remainder are 
 * set to $ff.
 *
 * It uses the registers R16 and R17 for the numerator and denominator.
 * The result is stored in R18 (quotient) and R19 (remainder).
 */

/**
 * This program is designed for an ATmega16.
 */
.device ATmega16

/**
 * Includes names.
 */
.include "m16def.inc"

/**
 * The numerator.
 */
.def numerator = R16

/**
 * The denominator.
 */
.def denominator = R17

/**
 * The quotient.
 */
.def quotient = R18

/**
 * The remainder.
 */
.def remainder = R19

/**
 * This macro initializes registers numerator, denominator,
 * quotient and remainder
 *
 * in:     void
 * out:    void
 * Effect: All four registers are set to $ff.
 */
.macro INIT_REGISTERS
	SER numerator
	SER denominator
	SER quotient
	SER remainder
.endmacro

/**
 * Initializes the stack pointer (SPL and SPH) to "address".
 *
 * in:     address (16 bit)
 * out:    stack pointer at address
 * Effect: SPL <- low(address), SPH <- high(address)
 */
.macro INIT_STACK_PTR 
    LDI remainder, low(@0)
    OUT SPL, remainder
    LDI remainder, high(@0)
    OUT SPH, remainder
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
 * Start of the code segment.
 */
.cseg

/**
 * Leave enough space for the main program.
 */
.org 0x400

/**
 * Define INIT_DIVISION for a custom division.
 */
/*
INIT_DIVISION:
  LDI numerator, 10
  LDI denominator, 3
  RET
*/

/**
 * Warn if INIT_DIVISION is not defined by the user.
 */
.ifndef INIT_DIVISION
    .warning "INIT_DIVISION not defined! Using default."
.else
    .message "Found custom INIT_DIVISION."
.endif

/**
 * Program starts at 0.
 */
.org 0

/**
 * Runs the program after initializing the registers and 
 * the stack pointer.
 *
 * An example divison is supplied with INIT_DIVISION.
 *
 * After the program is finished, the TERMINATE macro is
 * called, resulting in an infinite loop.
 *
 * in:     void
 * out:    void
 * Effect: Runs the program.
 */
Main_Entry_Point:
    INIT_REGISTERS            // init registers
    INIT_STACK_PTR RAMEND     // init stack pointer
    
    .ifndef INIT_DIVISION
        .message "Define INIT_DIVISION for your division. Using example."
    .endif
    CALL INIT_DIVISION       // shall create the correct array
    
    CALL DIVIDE   // run the program
    
    TERMINATE                 // terminate in infinite loop

/**
 * Performs the division numerator / denominator = quotient remainder
 * The denominator must not be 0. If it is, quotient and remainder are 
 * set to $ff and the subroutine returns.
 *
 * in: numerator/denominator
 * out: quotient and remainder
 * Effect: divides numerator by denominator and stores the results.
 */
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
    Loop:
	    CP remainder, denominator
		BRLO End
		SUB remainder, denominator
		INC quotient
		RJMP Loop
	End:
        RET

/**
 * Prepares the division 10 / 3 in the registers numerator and denominator.
 * 
 * in:     void
 * out:    void
 * Effect: numerator <- 10, denominator <- 3
 */
.ifndef INIT_DIVISION
    INIT_DIVISION:
        LDI numerator, 10
		LDI denominator, 3
        RET
.endif

.exit