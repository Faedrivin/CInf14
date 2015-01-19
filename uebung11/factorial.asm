/**
 * This program calculates the factorial of a number.
 * The factorial for positive numbers is recursively defined by:
 *
 * n! = n(n-1)! if n > 1
 * n! = 1       else
 */

 /**
 * Includes macros and names.
 */
.include "init_header.inc"

/**
 * Argument
 */
.def n = R16

/**
 * Result
 */
.def result = R18

/**
 * Temp register.
 */
.def tmp = R19

/**
 * Start of the code segment.
 */
.cseg

/**
 * Program starts at 0.
 */
.org 0

/**
 * Runs the program after initializing the 
 * the stack pointer.
 *
 * After the program is finished, the TERMINATE macro is
 * called, resulting in an infinite loop.
 *
 * in:     void
 * out:    void
 * Effect: Runs the program.
 */
Main_Entry_Point:
  INIT_STACK_PTR RAMEND, tmp  ; init stack pointer
  
  CALL FACTORIAL ; run the program
  
  TERMINATE      ; terminate in infinite loop


/**
 * Computes the factorial function
 *
 * in:  n, positive integer in R16
 * out: n!, positive integer truncated to 8 bits in R18
 */
FACTORIAL:
    PUSH tmp      ; save current gloabl state
    PUSH R0       ; Multiply operattions always write to R1.R0
    PUSH R1
    IN R1, SREG   ; R1 saved, so use to load SREG
    PUSH R1       ; push anew
    CPI n, 0
    BREQ Abort    ; if <= 0, this is bullshit 
    MOV tmp, n    ; else save in tmp
    LDI result, 1 ; result is at least 1
  LoopFact:
    ; while tmp != 0 do result *= tmp--
    TST tmp         ; check if counter is down to zero
    BREQ EndFact    ; if yes, exit
    MUL result, tmp ; else multiply intermediate by current decrement
    MOV result, R0  ; product is placed in R0 so, move out (this can perhaps be avoided)
    DEC tmp         ; decrement n
    RJMP LoopFact   ; continue

  Abort:
    LDI result, 0   ; bad argument, set result to 0 (normally impossible)
    RJMP EndFact    ; restore shit

  EndFact:          ; get all status back to what it was before
    POP R1
    OUT SREG, R1
    POP R1
    POP R0
    POP TMP
    RET

.exit
