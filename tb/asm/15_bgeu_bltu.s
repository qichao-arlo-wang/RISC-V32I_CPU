.text
.globl main
main:
    # Initialize registers with test values
    li t0, 15         # t0 = 15
    li t1, 10         # t1 = 10
    li t2, 3          # t2 = 3
    li t3, -5         # t3 = -5

    # Test BLT (branch if t0 < t1)
    bltu t0, t1, branch_less    # Branch if t0 < t1 (15 < 10)

no_branch:
    # Code if BLT branch not taken
    li t4, 0x1234    # t4 = 0x1234 (not taken)
    j check_bge      # Skip the BLT branch taken code

branch_less:
    # Code if BLT branch taken
    li t4, 0x5678    # t4 = 0x5678 (branch taken)

check_bge:
    # Test BGE (branch if t2 >= t3)
    bgeu t2, t3, branch_ge      # Branch if t2 >= t3 (3 >= -5)

no_branch_ge:
    # Code if BGE branch not taken
    li t5, 0x9ABC    # t5 = 0x9ABC (not taken)
    j end            # Skip the BGE branch taken code

branch_ge:
    # Code if BGE branch taken
    li t5, 0xDEF0    # t5 = 0xDEF0 (branch taken)

end:
    # Validate results by summing into a0
    li a0, 0         # Initialize a0 = 0
    add a0, a0, t4   # a0 += t4 (result of BLT)
    add a0, a0, t5   # a0 += t5 (result of BGE)

    # Infinite loop to finish program
finish:     # Result in a0 will be 0xF124
    bne     a0, zero, finish     # loop forever

