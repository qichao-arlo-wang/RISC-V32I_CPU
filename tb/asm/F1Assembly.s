.text
.globl main

main:
    li 		t2, 0x2000
    li      t3, 0            # Initialize delay counter
    li      t4, 0            # Random off timer storage    
loop:
    lw 		s0, 0(t2)
    jal 	ra, subroutine

    # Lights remain ON
    li      a0, 0xFF         # All lights ON
    addi    t3, t3, 1        # Increment delay counter
    bge     t3, t4, turn_off # Check if counter >= random delay
    j       loop

turn_off:
    li      a0, 0x0          # All lights OFF
    jal     ra, random_delay # new random delay
    j       loop

subroutine:
    addi 	a0, zero, 0x1
    addi 	a0, zero, 0x3
    addi 	a0, zero, 0x7
    addi 	a0, zero, 0xf
    addi 	a0, zero, 0x1f
    addi 	a0, zero, 0x3f
    addi 	a0, zero, 0x7f
    addi    a0, zero, 0xff
    ret
    
random_delay:
    li      t5, 10000000     #  max random value
    li      t6, 10           #  min random value
    # pseudo-random generator
    add     t4, t3, t6       # t4 = t3 + min
    rem     t4, t4, t5       # t4 = delay % max
    add     t4, t4, t6       # within range 
    ret
