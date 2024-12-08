.text
.globl main
main:
    # Initialize registers with test values
    li t0, 10         # t0 = 10 (binary: 00000000000000000000000000001010)
    li t1, 3          # t1 = 3 (shift amount)
    
    # Test SLL (t0 << t1)
    sll t2, t0, t1    # t2 = t0 << 3 = 10 << 3 = 80 (binary: 00000000000000000000000001010000)
    
    # Test SLL with a larger shift (t0 << 5)
    li t1, 5          # t1 = 5 (new shift amount)
    sll t3, t0, t1    # t3 = t0 << 5 = 10 << 5 = 320 (binary: 00000000000000000000000010100000)

    # Test SLL with a shift that causes overflow (t0 << 32)
    li t1, 32         # t1 = 32 (shift amount is 32)
    sll t4, t0, t1    # t4 = t0 << 32 = 10 << 32 = 0 (overflow causes all bits to be shifted out)

    # Test SLL with shift of 0 (t0 << 0)
    li t1, 0          # t1 = 0 (shift amount)
    sll t5, t0, t1    # t5 = t0 << 0 = 10 << 0 = 10 (no shift, should be unchanged)

    # Validate results by adding them to a0 (sum all the results)
    li a0, 0          # Initialize a0 = 0
    add a0, a0, t2    # a0 += t2 (80)
    add a0, a0, t3    # a0 += t3 (320)
    add a0, a0, t4    # a0 += t4 (0)
    add a0, a0, t5    # a0 += t5 (10)

    # Infinite loop to finish program
finish:
    j finish


