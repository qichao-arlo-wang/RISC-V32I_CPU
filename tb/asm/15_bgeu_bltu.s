.text
.globl main
main:
    # Initialize registers with test values
    li t0, -5         # t0 = -5
    li t1, 10         # t1 = 10
    li t2, 3          # t2 = 3
    li t3, -5         # t3 = -5

    # Test BLT (branch if t0 < t1)
    bltu t0, t1, branch_less    # Branch if t0 < t1 (-5 < 10) in unsigned, -5 > 10 hence branch not taken

no_branch:
    # Code if BLT branch not taken
    li t4, 0x1234    # t4 = 0x1234 (not taken)
    jal check_bge      # Skip the BLT branch taken code

branch_less:
    # Code if BLT branch taken
    li t4, 0x5678    # t4 = 0x5678 (branch taken)

check_bge:
    # Test BGE (branch if t2 >= t3)
    bgeu t2, t3, branch_ge      # Branch if t2 >= t3 (3 >= -5) branch not taken since 3 smaller than 

no_branch_ge:
    # Code if BGE branch not taken
    li t5, 0x9ABC    # t5 = 0x9ABC (not taken)
    jal end            # Skip the BGE branch taken code

branch_ge:
    # Code if BGE branch taken
    li t5, 0xDEF0    # t5 = 0xDEF0 (branch taken)

end:
    # Validate results by summing into a0
    li a0, 0         # Initialize a0 = 0
    add a0, a0, t4   # a0 += t4 (result of BLT) = 0x1234
    add a0, a0, t5   # a0 += t5 (result of BGE) = 0x9ABC

    # Infinite loop to finish program
finish:     # Result in a0 will be 0xACF0
    bne     a0, zero, finish     # loop forever

