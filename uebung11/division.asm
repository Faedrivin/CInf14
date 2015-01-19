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
 * Includes macros and names.
 */
.include "init_header.inc"

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
 * Start of the code segment.
 */
.cseg

/**
 * Program starts at 0.
 */
.org 0

/**
 * Runs the program after initializing the registers and 
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
  INIT_STACK_PTR RAMEND, quotient ; init stack pointer
  
  CALL DIVISION ; run the program
  
  TERMINATE     ; terminate in infinite loop

/**
 * Performs the division numerator / denominator = quotient remainder
 * The denominator must not be 0. If it is, quotient and remainder are 
 * set to 0 and $ff respectively and the subroutine returns.
 *
 * in: numerator and denominator
 * out: quotient and remainder
 * Effect: divides numerator by denominator and stores the results.
 */
DIVISION:
  ; check if denominator is 0, if yes interrupt, else continue at Init
  TST denominator
  BRNE Init

  ; if div 0, set quotient to 0 and remainder to $ff and return to terminate
  LDI quotient, 0
  SER remainder
  RET

  ; copy numerator to remainder and initialize quotient
  Init:
      MOV remainder, numerator 
      LDI quotient, 0

  ; While remainder >= denominator, subtract denominator from
  ; remainder and increment 
  LoopDiv:
    CP remainder, denominator
    BRLO EndDiv
    SUB remainder, denominator
    INC quotient
    RJMP LoopDiv
  EndDiv:
    RET

.exit
