.text
.globl main
main:
    # Test AUIPC instruction
    auipc t0, 0x1    # t0 = PC + (0x1 << 12)
                     # PC is 0x0, then t0 = 0x0 + 0x1000 = 0x1000

    auipc t1, 0x2    # t1 = PC + (0x2 << 12)
                     # Assuming PC at this instruction is 0x4, t1 = 0x4 + 0x2000 = 0x2004

    auipc t2, 0xFFFFF      # t2 = PC + (-1 << 12)
                     # Assuming PC is 0x008, t2 = 0x008 - 0x1000 = 0xFFFFF008

    # Validate results
    add t3, t3, t0   # t3 += t0 = 0x1000
    add t3, t3, t1   # t3 += t1 = 0x1000 + 0x2004 = 0x3004
    add t3, t3, t2   # t3 += t2 = 0x3004 + 0xFFFFF008 = 0x200C

    # Store the result in a0 for testing
    add a0, a0, t3   # a0 = t3 (sum of results) = 0x200C

finish:     # Result in a0 will be 0x200C
    bne     a0, zero, finish     # loop forever
