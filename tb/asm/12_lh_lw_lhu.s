.text
.globl main
main:
    # Initialize memory with values using store instructions
    # t0 = 0x12345678 (32-bit word)
    li t0, 0x12345678    # t0 = 0x12345678 (word)
    sw t0, 0(t6)         # Store word at address 0(t6)
    
    # t1 = 0x7FFF (signed halfword)
    li t1, 0x7FFF         # t1 = 0x7FFF (signed halfword)
    sh t1, 4(t6)          # Store signed halfword at address 4(t6)
    
    # t2 = 0x8001 (signed halfword)
    li t2, 0x8001         # t2 = 0x8001 (signed halfword)
    sh t2, 6(t6)          # Store signed halfword at address 6(t6)
    
    # t3 = 0x7FFF (unsigned halfword)
    li t3, 0x7FFF         # t3 = 0x7FFF (unsigned halfword)
    sh t3, 8(t6)          # Store unsigned halfword at address 8(t6)
    
    # t4 = 0x8001 (unsigned halfword)
    li t4, 0x8001         # t4 = 0x8001 (unsigned halfword)
    sh t4, 10(t6)         # Store unsigned halfword at address 10(t6)

    # Load word (32 bits) from memory into t5
    lw t5, 0(t6)          # t5 = 0x12345678 (load word from address 0(t6))

    # Load signed halfword (16 bits) from memory into t0
    lh t0, 4(t6)          # t0 = 0x7FFF (signed halfword from address 4(t6))
    
    # Load signed halfword (16 bits) from memory into t1
    lh t1, 6(t6)          # t1 = 0x8001 (signed halfword from address 6(t6))

    # Load unsigned halfword (16 bits) from memory into t2
    lhu t2, 8(t6)         # t2 = 0x7FFF (unsigned halfword from address 8(t6))
    
    # Load unsigned halfword (16 bits) from memory into t3
    lhu t3, 10(t6)        # t3 = 0x8001 (unsigned halfword from address 10(t6))

    # Sum the results into a0 for validation
    li a0, 0              # Initialize a0 to 0
    add a0, a0, t5        # a0 += t5 (0x12345678)
    add a0, a0, t0        # a0 += t0 (0x7FFF, signed)
    add a0, a0, t1        # a0 += t1 (0x8001, signed)
    add a0, a0, t2        # a0 += t2 (0x7FFF, unsigned)
    add a0, a0, t3        # a0 += t3 (0x8001, unsigned)

    # Infinite loop to finish program
finish:     # expected result is 0x12365678
    bne     a0, zero, finish     # loop forever
    