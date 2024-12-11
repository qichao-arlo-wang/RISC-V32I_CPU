.text
.globl main
main:
    # Initialize registers with test values
    li t0, 0x12345678    # t0 = 0x12345678 (word)
    li t1, 0x89ABCDEF    # t1 = 0x89ABCDEF (word)
    li t2, 0x7FFF        # t2 = 0x7FFF (halfword, signed)
    li t3, 0x8001        # t3 = 0x8001 (halfword, signed)
    li t4, 0x7FFF        # t4 = 0x7FFF (halfword, unsigned)
    li t5, 0x8001        # t5 = 0x8001 (halfword, unsigned)

    # Store the values directly into registers for testing
    # Test SW (load word)
    sw t0, 0(t6)         # Store word at address 0 (t0 = 0x12345678)
    sw t1, 4(t6)         # Store word at address 4 (t1 = 0x89ABCDEF)

    # Test SH (load halfword, signed)
    sh t2, 8(t6)         # Store halfword at address 8 (t2 = 0x7FFF, signed)
    sh t3, 10(t6)        # Store halfword at address 10 (t3 = 0x8001, signed)

    # Test SH (load halfword, unsigned)
    sh t4, 12(t6)        # Store halfword at address 12 (t4 = 0x7FFF, unsigned)
    sh t5, 14(t6)        # Store halfword at address 14 (t5 = 0x8001, unsigned)

    # Validate results by adding them to a0 (sum all the results)
    li a0, 0             # Initialize a0 = 0
    add a0, a0, t0       # a0 += t0 (0x12345678)
    add a0, a0, t1       # a0 += t1 (0x89ABCDEF)
    add a0, a0, t2       # a0 += t2 (signed 0x7FFF -> 32767)
    add a0, a0, t3       # a0 += t3 (signed 0x8001 -> -32767)
    add a0, a0, t4       # a0 += t4 (unsigned 0x7FFF -> 32767)
    add a0, a0, t5       # a0 += t5 (unsigned 0x8001 -> 32769)

    # Infinite loop to finish program
finish:     # expected result is 0x9BE22467
    bne     a0, zero, finish     # loop forever

