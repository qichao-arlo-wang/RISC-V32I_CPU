.section .text
.global _start

_start:
    # Initialize base address for LEDs 
    li t0, 0x80000000    # Load base address of memory-mapped LEDs into t0

    # Initialize the light pattern to the first LED
    li t1, 0x01          # t1 = 0x01 (turn on first LED)

loop:
    # Light the current LED
    sw t1, 0(t0)         # Store t1 to LED base address
    
    # Delay loop for visible light transition
    li t2, 0x100000      # t2 = delay counter
delay:
    addi t2, t2, -1      # Decrement delay counter
    bnez t2, delay       # Repeat until counter reaches zero

    # Shift the light to the next LED
    slli t1, t1, 1       # Shift t1 left by 1 (move to the next light)
    
    # Check if all lights have been lit
    li t3, 0x100         # t3 = 0x100 (one bit beyond the 8th light)
    bne t1, t3, loop     # If t1 != t3, continue the loop

    # Reset to the first light
    li t1, 0x01          # Reset t1 to the first light
    j loop               # Repeat the sequence
