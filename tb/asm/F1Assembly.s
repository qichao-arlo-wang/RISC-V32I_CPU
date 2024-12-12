    .text
    .globl main

main:
    li      t2, 0x2000      # Address of some input (e.g., hardware/memory-mapped input)
    li      t3, 0           # Initialize delay counter
    li      t4, 30        # Seed for LFSR (must be nonzero), used for random delays

loop:
    lw      s0, 0(t2)       # Load input value (not used further in your script)
    jal     ra, subroutine  # Call the subroutine to perform operations


turn_off:
    li      a0, 0x0         # Turn all lights OFF
    jal     ra, random_delay # Generate a new random delay in t4
    li      t3, 0           # Reset the delay counter
        li      t1, 0x80
delay8:
    addi    t1, t1, -1
    bne     t1, zero, delay8
    j       loop

subroutine:
    addi    a0, zero, 0x1
    li      t1, 0x25
delay1:
    addi    t1, t1, -1
    bne     t1, zero, delay1

    addi    a0, zero, 0x3
    li      t1, 0x25
delay2:
    addi    t1, t1, -1
    bne     t1, zero, delay2

    addi    a0, zero, 0x7
    li      t1, 0x25
delay3:
    addi    t1, t1, -1
    bne     t1, zero, delay3

    addi    a0, zero, 0xf
    li      t1, 0x25
delay4:
    addi    t1, t1, -1
    bne     t1, zero, delay4

    addi    a0, zero, 0x1f
    li      t1, 0x25
delay5:
    addi    t1, t1, -1
    bne     t1, zero, delay5

    addi    a0, zero, 0x3f
    li      t1, 0x25
delay6:
    addi    t1, t1, -1
    bne     t1, zero, delay6

    addi    a0, zero, 0x7f
    li      t1, 0x25
delay7:
    addi    t1, t1, -1
    bne     t1, zero, delay7

    # At this point, a0 = 0xff
    addi    a0, zero, 0xff

# New loop added here:
sub_delay_loop:
    addi    t3, t3, 1            # Increment t3 by 2
    bge     t3, t4, turn_off     # If t3 >= t4, jump directly to turn_off (in main)
    j       sub_delay_loop       # Otherwise, keep looping

    # If we ever exit this loop normally (which we won't in this code), we would return here:
    ret

random_delay:
    # Simplified random delay using LFSR logic
    andi    t5, t4, 0b1      # Extract LSB of LFSR
    srli    t4, t4, 1        # Shift LFSR right by 1
    xor     t5, t5, t4       # XOR feedback with MSB (feedback tap)
    slli    t5, t5, 3        # Shift feedback to MSB
    or      t4, t4, t5       # Insert feedback into LFSR
    andi    t4, t4, 0b1111   # Ensure only lower 4 bits are used

    # Map the LFSR output to a delay value range [5..12]
    li      t6, 10
    add     t4, t4, t6
    slli    t4, t4, 2
    ret
