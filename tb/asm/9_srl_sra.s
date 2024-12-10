.text
.globl main
main:
    # Initialize registers with test values
    li t0, 0b11111111111111111111111111111000  # t0 = -8 (signed)
    li t1, 0b00000000000000000000000000001000  # t1 = 8 (unsigned positive)
    li t2, 2                                  # t2 = shift amount (2)

    # Test SRL (logical shift right)
    srl t3, t1, t2     # t3 = t1 >> 2 -> t3 = 0b10 = 2
    srl t4, t0, t2     # t4 = t0 >> 2 (logical, ignores sign) -> t4 = 0b00111111111111111111111111111110

    # Test SRA (arithmetic shift right)
    sra t5, t1, t2     # t5 = t1 >>> 2 (arithmetic, positive remains same) -> t5 = 0b10 = 2
    sra t6, t0, t2     # t6 = t0 >>> 2 (arithmetic, sign preserved) -> t6 = 0b11111111111111111111111111111110 (-2 signed)

    # Test SRLI (logical shift right immediate)
    srli t1, t1, 2     # t1 = t1 >> 2 (logical, using immediate) -> t1 = 0b10 = 2

    # Test SRAI (arithmetic shift right immediate)
    srai t0, t0, 2     # t0 = t0 >>> 2 (arithmetic, using immediate) -> t0 = 0b11111111111111111111111111111110 (-2 signed)

    # Validate results by summing into a0
    li a0, 0           # Initialize a0 = 0
    add a0, a0, t3     # a0 += t3 (2 from SRL)
    add a0, a0, t4     # a0 += t4 (t4 = 0b00111111111111111111111111111110)
    add a0, a0, t5     # a0 += t5 (2 from SRA)
    add a0, a0, t6     # a0 += t6 (-2 signed from SRA)
    add a0, a0, t1     # a0 += t1 (2 from SRLI)
    add a0, a0, t0     # a0 += t0 (-2 signed from SRAI)

    # Infinite loop to finish program
finish:     # expected result is 1073741824
    bne     a0, zero, finish     # loop forever
