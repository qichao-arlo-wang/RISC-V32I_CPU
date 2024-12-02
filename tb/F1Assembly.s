.section .text
.global _start

# F1 Starting Lights Assembly Program

_start:
    # Set up initial values in registers

    addi s1, zero, 0x1       # s1 = 1; used as a constant for trigger comparison
    addi s2, zero, 0xFF      # s2 = 0xFF; represents all 8 lights turned on
    addi s3, zero, 0x3       # s3 = 3; delay value for light timing
    addi a3, zero, 0x1       # a3 = 1; initial seed for the LFSR

rst:
    # Reset the system state and registers.

    nop                      # timing alignment
    nop
    addi a0, zero, 0x0       # a0 = 0; reset the light pattern register
    addi a4, zero, 0x0       # a4 = 0; reset the delay counter for 'increment'
    addi t0, zero, 0x1       # t0 = 1; activate the trigger (change to 1 to start FSM)

mainloop:
    # Wait for the trigger and update the LFS

    nop
    nop
    beq  t0, s1, fsm         # If t0 == s1 (trigger is active), jump to 'fsm' label
    
    # Update  LFSR to generate pseudo-random numbers for delays

    srli a2, a3, 0x3         # a2 = a3 >> 3; extract bit 3 of LFSR state
    nop
    nop
    nop
    andi a2, a2, 0x1         # a2 = a2 & 0x1; isolate bit 0 (feedback bit)
    nop
    nop
    nop
    xor  a2, a2, a3          # a2 = a2 ^ a3; XOR feedback bit with LFSR state
    nop
    nop
    nop
    andi a2, a2, 0x1         # a2 = a2 & 0x1; ensure feedback bit is 1 bit
    nop
    nop
    nop
    slli a3, a3, 0x1         # a3 = a3 << 1; shift LFSR state left by 1
    nop
    nop
    nop
    add  a3, a3, a2          # a3 = a3 + a2; update LFSR with feedback bit
    nop
    nop
    nop
    andi a3, a3, 0xF         # a3 = a3 & 0xF; limit LFSR state to 4 bits
    beq zero, zero, mainloop # unconditional jump back to mainloop

fsm:
    # Control the sequence of turning on the lights one by one

    nop
    nop
    jal  ra, lightdelay      # Call lightdelay subroutine to add delay between lights
    nop
    nop
    nop
    slli t1, a0, 0x1         # t1 = a0 << 1; shift current light pattern left by 1
    nop
    nop
    addi a0, t1, 0x1         # a0 = t1 + 1; turn on the next light
    nop
    nop
    bne  a0, s2, fsm         # If a0 != s2 (not all lights are on), repeat 'fsm'

    jal ra, increment        # aft all lights on, call increment subroutine
    beq zero, zero, rst      # unconditional jump to rst
increment:
    # Introduce a delay after all lights are on before resetting

    nop
    nop
    beq  a4, a3, end_increment # If a4 == a3 exit increment subroutine
    nop
    nop
    jal  ra, lightdelay      # Call 'lightdelay' subroutine for delay
    nop
    nop
    addi a4, a4, 0x1         # a4 = a4 + 1; increment delay counter
    beq zero, zero, increment #unconditional jump back to icnrement

end_increment:
    addi a4, zero, 0x0 #reset a4 to 0
    rst     #return from increment subroutine

lightdelay:
    # Create a delay between light changes

    nop
    nop
    addi a1, a1, 0x1         # a1 = a1 + 1; increment the delay counter
    nop
    nop
    nop
    bne  a1, s3, lightdelay  # If a1 != s3, loop back to 'lightdelay' (continue delay)
    nop
    nop
    addi a1, zero, 0x0       # a1 = 0; reset the delay counter
    ret                      # Return from subroutine to caller



#   - s1 (x9): Trigger constant 1
#   - s2 (x18): Value representing all lights on 0xFF
#   - s3 (x19): Delay value 3
#   - a0 (x10): Light pattern register
#   - a1 (x11): Delay counter for lightdelay
#   - a2 (x12): Temporary register for LFSR calculations
#   - a3 (x13): LFSR state register
#   - a4 (x14): Delay counter for increment
#   - t0 (x5): Trigger register
#   - t1 (x6): Temporary register for shifting light patterns
