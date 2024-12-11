.text
.globl main
main:
    # Initialize registers with test values
    li t0, 0b10101010101010101010101010101010  # t0 = 0xAAAAAAAA
    li t1, 0b01010101010101010101010101010101  # t1 = 0x55555555
    li t2, 0xFFFFFFFF                          # t2 = 0xFFFFFFFF
    li t3, 0x0                                 # t3 = 0x0

    # Test OR (t0 | t1)
    or t4, t0, t1     # t4 = t0 | t1 -> t4 = 0xFFFFFFFF

    # Test ORI (t1 | immediate)
    ori t5, t1, 0xFF  # t5 = t1 | 0xFF -> t5 = 0x555555FF

    # Test XOR (t0 ^ t1)
    xor t6, t0, t1    # t6 = t0 ^ t1 -> t6 = 0xFFFFFFFF

    # Test XORI (t1 ^ immediate)
    xori t0, t1, 0xF0  # t0 = t1 ^ 0xF0 -> t0 = 0x555555A5

    # Test AND (t0 & t1)
    and t1, t0, t1    # t1 = t0 & t1 -> t1 = 0x55555505

    # Test ANDI (t2 & immediate)
    andi t2, t2, 0x00FF  # t2 = t2 & 0x00FF -> t2 = 0x000000FF

    # Validate results by summing into a0
    li a0, 0           # Initialize a0 = 0
    add a0, a0, t4     # a0 += t4 (0xFFFFFFFF)
    add a0, a0, t5     # a0 += t5 (0x555555FF)
    add a0, a0, t6     # a0 += t6 (0xFFFFFFFF)
    add a0, a0, t0     # a0 += t0 (0x555555A5)
    add a0, a0, t1     # a0 += t1 (0x55555505)
    add a0, a0, t2     # a0 += t2 (0x000000FF)

    # Infinite loop to finish program
finish:     # expected result is 0x1A6
    bne     a0, zero, finish     # loop forever
