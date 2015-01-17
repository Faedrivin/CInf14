
/**
 * This program is designed for an ATmega16.
 */
.device ATmega16

/**
 * Includes names.
 */
.include "m16def.inc"

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
