.section .text
.global main

main:
    la t0, instr_array   # Load the address of the instruction array into t0

    # Read Test
    lw t1, 0(t0)   # Read first instruction, expect cache miss
    lw t2, 4(t0)   # Read second instruction, expect cache miss
    lw t1, 0(t0)   # Read first instruction again, expect cache hit

    # Write Test (cache update)
    li t3, 0x55555555
    sw t3, 0(t0)   # Write to first instruction, expect hit (write-through)
    li t3, 0x66666666
    sw t3, 12(t0)  # Write to a new address, expect miss and replacement

    # Validation Read
    lw t4, 0(t0)   # Read first instruction, expect hit
    lw t4, 12(t0)  # Read new address, expect hit

    # End of test
hang:   j hang

.section .data
instr_array: .word 0x12345678, 0x9ABCDEF0, 0x11111111, 0x22222222
