
/**
 * This program is designed for an ATmega16.
 */
.device ATmega16

/**
 * Includes names.
 */
.include "m16def.inc"

/**
 * Initializes the stack pointer (SPL and SPH) to "address".
 * Uses register tmp as the temporary register
 *
 * in:     address (16 bit), tmp
 * out:    stack pointer at address
 * Effect: SPL <- low(address), SPH <- high(address)
 */
.macro INIT_STACK_PTR 
    LDI @1, low(@0)
    OUT SPL, @1
    LDI @1, high(@0)
    OUT SPH, @1
.endmacro

/* 
 * This macro loads the array address "address" into the X register.
 *
 * in:     address (16 bit)
 * out:    X at address
 * Effect: X <- address (XL <- low(address), 
 *                       XH <- high(address))
 */
.macro SET_X_REG
    LDI XL, low(@0)
    LDI XH, high(@0)
.endmacro

/* 
 * This macro loads the array address "address" into the Y register.
 *
 * in:     address (16 bit)
 * out:    Y at address
 * Effect: Y <- address (YL <- low(address), 
 *                       YH <- high(address))
 */
.macro SET_Y_REG
    LDI YL, low(@0)
    LDI YH, high(@0)
.endmacro

/* 
 * This macro loads the array address "address" into the Z register.
 *
 * in:     address (16 bit)
 * out:    Z at address
 * Effect: Z <- address (ZL <- low(address), 
 *                       ZH <- high(address))
 */
.macro SET_Z_REG
    LDI ZL, low(@0)
    LDI ZH, high(@0)
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