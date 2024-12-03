.section .text
.global _start

# F1 Starting Lights Assembly Program

_start:
    # Set up initial values in registers

    addi s1, zero, 0x1       # s1 = 1; used as a constant for trigger comparison
    addi s2, zero, 0xFF      # s2 = 0xFF; represents all 8 lights turned on
    addi s3, zero, 0x20      # s3 = 32; delay value for light timing
    addi a3, zero, 0x1       # a3 = 1; initial seed for the LFSR

rst:
    # Reset the system state and registers.

    addi a0, zero, 0x1       # a0 = 1; initialize light pattern register
    addi a4, zero, 0x0       # a4 = 0; reset the delay counter for 'increment'
    addi t0, zero, 0x1       # t0 = 1; activate the trigger
    jal ra, mainloop         # Jump to main loop

mainloop:
    # Wait for the trigger and update the LFSR

    beq  t0, s1, fsm         # If t0 == s1 (trigger is active), jump to 'fsm'
    
    # Update LFSR to generate pseudo-random numbers for delays
    srli a2, a3, 0x3         # a2 = a3 >> 3; extract bit 3 of LFSR state
    andi a2, a2, 0x1         # a2 = a2 & 0x1; isolate bit 0 (feedback bit)
    xor  a2, a2, a3          # a2 = a2 ^ a3; XOR feedback bit with LFSR state
    andi a2, a2, 0x1         # a2 = a2 & 0x1; ensure feedback bit is 1 bit
    slli a3, a3, 0x1         # a3 = a3 << 1; shift LFSR state left by 1
    add  a3, a3, a2          # a3 = a3 + a2; update LFSR with feedback bit
    andi a3, a3, 0xF         # a3 = a3 & 0xF; limit LFSR state to 4 bits
    jal  ra, mainloop        # Loop until trigger is active

fsm:
    # Control the sequence of turning on the lights one by one

    jal  ra, lightdelay      # Call lightdelay subroutine to add delay between lights
    slli t1, a0, 0x1         # t1 = a0 << 1; shift current light pattern left by 1
    addi a0, t1, 0x0         # a0 = t1; turn on the next light (no extra addition)
    bne  a0, s2, fsm         # If a0 != s2 (not all lights are on), repeat 'fsm'

increment:
    # Introduce a delay after all lights are on before resetting

    beq  a4, a3, rst         # Reset when delay counter matches the LFSR value
    jal  ra, lightdelay      # Call 'lightdelay' subroutine for delay
    addi a4, a4, 0x1         # Increment delay counter
    jal  ra, increment       # Repeat increment loop

lightdelay:
    # Create a delay between light changes

    addi a1, a1, 0x1         # Increment delay counter
    bne  a1, s3, lightdelay  # Loop until counter matches delay value
    addi a1, zero, 0x0       # Reset counter
    ret                      # Return from subroutine
