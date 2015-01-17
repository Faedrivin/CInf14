/**
 * This program reads an array at address 0x200. The array gets 
 * reversed by emplying a stack, but all even values are ignored.
 * The array can be at most 30 elements long, however elements are
 * taken into account until a 255 (including) is found or the end 
 * of those 30 elements was reached.
 * 
 * The size of the final array can be taken from R26, as this 
 * points to the first address behind the array.
 * All addresses from 0x200 to 0x200+R26 (=X) are considered part 
 * of the mirrored array. For all values from 0x200+R26+1 onwards 
 * the values are undefined.
 *
 * An example:
 *
 * The array starting at 0x200:
 * addr   dec  hex
 * 0x200    3   03
 * 0x201  124   7c
 * 0x202    6   06
 * 0x203    2   02
 * 0x204  113   71
 * 0x205  255   ff
 * 0x206  154   9a
 * 0x207    9   09
 * ...    ...   ...
 *
 * Would result in the following:
 * 0x200  255   ff
 * 0x201  113   71
 * 0x202    3   03
 * 0x203  undefined
 * 0x204  undefined
 * ...    ...   ...
 *
 * R26 would then be 0x3.
 *
 * The program uses the X register (that means R26 and R27) to
 * address the array, and R24 and R25 for intermediate calculations
 * (R24 to work on the current array element and R25 to keep
 * track of the number of stack elements).
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
 * Holds the current value.
 */
.def current_value = R24

/**
 * Counts how many elements are currently on the stack.
 * Is also used as return value, thus the number of elements
 * in the modified array.
 */
.def stack_size = R25

/**
 * The array pointer is stored in the X register.
 * Thus the low byte array_ptr_low is stored in R26 (also XL)
 */
.def array_ptr_low = R26

/**
 * The array pointer is stored in the X register.
 * Thus the high byte array_ptr_high is stored in R27 (also XH)
 */
.def array_ptr_high = R27

/**
 * The maximum array length is 30.
 */
.set max_array_len = 30

/**
 * 255 is an early array terminal.
 */
.set array_terminal = 255

/**
 * The least significant bit (lsb) is the 0th.
 */
.set lsb = 0

/**
 * This macro initializes registers current_value, stack_size, 
 * array_ptr_low, array_ptr_high.
 *
 * in:     void
 * out:    void
 * Effect: All four registers are set to $ff.
 */
.macro INIT_REGISTERS
    SER current_value
    SER stack_size
    SER array_ptr_low
    SER array_ptr_high
.endmacro

/* 
 * This macro loads the array address "address" into the X register.
 *
 * in:     address (16 bit)
 * out:    X at address
 * Effect: X <- address (array_ptr_low <- low(address), 
 *                       array_ptr_high <- high(address))
 */
.macro RESET_ARRAY_PTR
    LDI array_ptr_low, low(@0)
    LDI array_ptr_high, high(@0)
.endmacro

/**
 * Initializes the stack pointer (SPL and SPH) to "address".
 *
 * in:     address (16 bit)
 * out:    stack pointer at address
 * Effect: SPL <- low(address), SPH <- high(address)
 */
.macro INIT_STACK_PTR 
    LDI current_value, low(@0)
    OUT SPL, current_value
    LDI current_value, high(@0)
    OUT SPH, current_value
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
 * Code segment for INIT_ARRAY.
 */
.cseg

/**
 * Leave enough space for the program code.
 */
.org 0x400

/**
 * Define INIT_ARRAY for custom array.
 */
/*
INIT_ARRAY:
  RESET_ARRAY_PTR array_begin // init array ptr

  // Load a value (5) and store it to the data space.
  // Repeat as needed.
  LDI current_value, 5
  ST X+, current_value

  // return from subroutine
  RET
*/

/**
 * Prepare array at 0x200 iff INIT_ARRAY is not defined.
 */
.dseg

/**
 * Start array at 0x200.
 */
.org 0x200

/**
 * Declare max_array_len bytes as array.
 */
Array_Begin: .byte max_array_len

/**
 * Warn if INIT_ARRAY is not defined by the user.
 */
.ifndef INIT_ARRAY
    .warning "INIT_ARRAY not defined! Using default."
.else
    .message "Found custom INIT_ARRAY."
.endif

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
 * To run properly, an example array (see comment at the
 * beginning of this file) is written to the memory
 * first, as long as INIT_ARRAY is not defined to provide a
 * proper array.
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
    
    .ifndef INIT_ARRAY
        .message "Define INIT_ARRAY for your array. Using example."
    .endif
    CALL INIT_ARRAY       // shall create the correct array
    
    CALL REVERSE_ARRAY_ODDS   // run the program
    
    TERMINATE                 // terminate in infinite loop

/**
 * The program code to handle the effects
 * described in detail at the beginning of this file:
 *
 * It reverses an array with up to 30 elements starting at
 * 0x200. All even values are discarded, the stack is used
 * to mirror the array. If a 255 is found, the rest of the
 * array is ignored as well. The final array starts at
 * 0x200 again, going from 0x200 through 0x200 + XL.
 * 
 * For a more detailed description see at the beginning of this
 * file.
 *
 * in:     void
 * out:    XL will be the length of the resulting array
 * Effect: Reverses the array at X, ignores even values.
 *         Writes the length of the resulting array implicitly
 *         into XL.
 */
REVERSE_ARRAY_ODDS:
    Begin:                            // initialize the program
        RESET_ARRAY_PTR Array_Begin   // init array address (in X)
        LDI stack_size, 0
        
    Loop_Push:
        // load element and check if odd or even
        LD current_value, X+          // load next array element
        
        // if odd: push current_value and increment stack_size
        // if even: skip through
        SBRC current_value, lsb       // skip if lsb 0 (= if even)
        PUSH current_value            // push odd value onto stack
        SBRC current_value, lsb       // skip if lsb 0 (= if even)
        INC stack_size                // increment stack counter

        // check if value = 255 or at end of array (XL = 30)
        // if any applies: branch to Init_Pop
        // else: go to back to Loop_Push
        CPI current_value, array_terminal // if array terminal Z-flag <- 1
        BREQ Init_Pop                 // if Z-flag = 1 branch to Init_Pop

        CPI array_ptr_low, max_array_len  // if end of array Z-flag <- 1
        BRNE Loop_Push                // if Z-flag = 0 branch to Loop_Push
        
    Init_Pop:
        RESET_ARRAY_PTR Array_Begin   // return to array begin
        TST stack_size                // check if stack is <= 0 
                                      // (will never be < 0)
        BREQ End                      // end if no elements are on the stack

    Loop_Pop:
        POP current_value    // remove TOS
        ST X+, current_value // store value
        DEC stack_size       // decrement stack_size
        TST stack_size       // check if there are elements left
        BRNE Loop_Pop        // if there are, remove them, else end

    End:
        RET

/**
 * Prepares an array.
 * This subroutine resets the array pointer with RESET_ARRAY_PTR
 * and uses the register current_value (R24) to load some immediate
 * values and store them subsequently into the array.
 * 
 * in:     void
 * out:    void
 * Effect: (X) and following memory addresses are set
 */
.ifndef INIT_ARRAY
    INIT_ARRAY:
        RESET_ARRAY_PTR Array_Begin
        LDI current_value,   3
        ST X+, current_value
        LDI current_value, 124
        ST X+, current_value
        LDI current_value,   6
        ST X+, current_value
        LDI current_value,   2
        ST X+, current_value
        LDI current_value, 113
        ST X+, current_value
        LDI current_value, 255
        ST X+, current_value
        LDI current_value, 154
        ST X+, current_value
        LDI current_value,   9
        ST X+, current_value
        RET
.endif

.exit