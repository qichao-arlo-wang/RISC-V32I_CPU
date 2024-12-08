.text
.globl main
main:
    # Initialize registers with test values
    li t0, 10         # t0 = 10 (positive number)
    li t1, 20         # t1 = 20 (positive number)
    li t2, -10        # t2 = -10 (negative signed number, positive unsigned number)
    li t3, 5          # t3 = 5 (positive number)
    
    # Test SLTU (unsigned: t0 < t1)
    sltu t4, t0, t1    # t4 = t0 < t1 -> t4 = 10 < 20 = 1
    
    # Test SLTU (unsigned: t2 < t0)
    sltu t5, t2, t0    # t5 = t2 < t0 -> t5 = -10 < 10 = 0
    
    # Test SLTU (unsigned: t0 < t2)
    sltu t6, t0, t2    # t6 = t0 < t2 -> t6 = 10 < -10 = 1

    
    # Validate results by adding them to a0 (sum all the results)
    li a0, 0          # Initialize a0 = 0
    add a0, a0, t4    # a0 += t4 (1)
    add a0, a0, t5    # a0 += t5 (0)
    add a0, a0, t6    # a0 += t6 (1)

    # Infinite loop to finish program
finish:
    j finish
    