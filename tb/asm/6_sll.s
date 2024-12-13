.text
.globl main
main:
    # Initialize registers with test values
    li t0, 10         # t0 = 10

    # Test SLL (t0 << 3)
    li t1, 3          # t1 = 3 (shift amount)
    sll t2, t0, t1    # t2 = t0 << 3 = 10 << 3 = 80

    # Test SLL with a larger shift (t0 << 5)
    li t1, 5          # t1 = 5 (new shift amount)
    sll t3, t0, t1    # t3 = t0 << 5 = 10 << 5 = 320

    # Test SLLI (immediate version of SLL, t0 << 3)
    slli t4, t0, 3    # t4 = t0 << 3 = 10 << 3 = 80

    # Test SLLI with a larger shift (t0 << 5)
    slli t5, t0, 5    # t5 = t0 << 5 = 10 << 5 = 320

    # Test SLLI with maximum valid shift for 32-bit values (t0 << 31)
    slli t6, t0, 31   # t6 = t0 << 31 = 10 << 31 = 0x00000000

    # Validate results by reusing registers
    li t0, 0          # Reinitialize t0 as the accumulator
    add t0, t0, t2    # t0 += t2 (80)
    add t0, t0, t3    # t0 += t3 (320)
    add t0, t0, t4    # t0 += t4 (80)
    add t0, t0, t5    # t0 += t5 (320)
    add t0, t0, t6    # t0 += t6 (0x00000000)

    # Move the final result to a0
    mv a0, t0         # a0 = t0 (final result)

    # Infinite loop to finish program
    finish:     # expected result is 0x320
        bne     a0, zero, finish     # loop forever


