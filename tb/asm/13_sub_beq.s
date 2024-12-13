.text
.globl main
main:
    # Initialize registers with test values
    li t0, 15        # t0 = 15
    li t1, 10        # t1 = 10

    # Test SUBI (t2 = t0 - immediate value 5)
    li t2, 5         # Immediate value for subtraction
    sub t3, t0, t2  # t3 = t0 - 5 -> t3 = 15 - 5 = 10

    # Test BEQ (branch if t3 == t1)
    beq t3, t1, branch_equal  # Branch if t3 == t1 (BRANCH TAKEN)

    # Code if branch not taken
    li t4, 0xDEAD    # t4 = 0xDEAD (not taken)
    j end            # Skip the branch taken code

branch_equal:
    # Code if branch taken
    li t4, 0xBEEF    # t4 = 0xBEEF (branch taken)

end:
    # Validate result
    li a0, 0         # Initialize a0 = 0
    add a0, a0, t3   # a0 += t3 = 10
    add a0, a0, t4   # a0 += t4 = 0xBEEF

    # Infinite loop to finish program
finish:     # expected result is 0xBEF9 = 0xBEEF + 10
    bne     a0, zero, finish     # loop forever

