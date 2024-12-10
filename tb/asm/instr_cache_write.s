.section .text
.global main

main:
    la t0, instr_array   # Load the address of the instruction array into t0

    # Initial Read
    lw t1, 0(t0)   # Read first instruction, expect cache miss
    lw t2, 4(t0)   # Read second instruction, expect cache miss

    # Write Test
    li t3, 0xCAFEBABE
    sw t3, 0(t0)   # Write to first instruction, expect hit
    li t3, 0xDEADC0DE
    sw t3, 8(t0)   # Write to third instruction, expect miss

    # Read Back to Verify
    lw t4, 0(t0)   # Read first instruction, expect hit
    lw t4, 8(t0)   # Read third instruction, expect hit

    # End of test
hang:   j hang

.section .data
instr_array: .word 0x12345678, 0x9ABCDEF0, 0x11111111, 0x22222222
