.text
.globl main
main:
    # Initialize registers with test values
    li t0, 10         # t0 = 10 (positive number)
    li t1, 20         # t1 = 20 (positive number)
    li t2, -10        # t2 = -10 (negative number)
    li t3, 5          # t3 = 5 (positive number)
    
    # Test SLT (signed: t0 < t1)
    slt t4, t0, t1    # t4 = t0 < t1 -> t4 = 10 < 20 = 1
    
    # Test SLT (signed: t2 < t0)
    slt t5, t2, t0    # t5 = t2 < t0 -> t5 = -10 < 10 = 1
    
    # Test SLT (signed: t0 < t2)
    slt t6, t0, t2    # t6 = t0 < t2 -> t6 = 10 < -10 = 0

    # Test SLTI (signed: t0 < immediate 15)
    slti t1, t0, 15   # t1 = t0 < 15 -> t1 = 10 < 15 = 1
    
    # Test SLTI (signed: t2 < immediate 0)
    slti t2, t2, 0    # t2 = t2 < 0 -> t2 = -10 < 0 = 1
    
    # Test SLTI (signed: t0 < immediate -5)
    slti t3, t0, -5   # t3 = t0 < -5 -> t3 = 10 < -5 = 0
    
    # Validate results by adding them to a0 (sum all the results)
    li a0, 0          # Initialize a0 = 0
    add a0, a0, t4    # a0 += t4 (1)
    add a0, a0, t5    # a0 += t5 (1)
    add a0, a0, t6    # a0 += t6 (0)
    add a0, a0, t1    # a0 += t1 (1)
    add a0, a0, t2    # a0 += t2 (1)
    add a0, a0, t3    # a0 += t3 (0)

    # Infinite loop to finish program
finish:     # expected result is 0x4
    bne     a0, zero, finish     # loop forever


