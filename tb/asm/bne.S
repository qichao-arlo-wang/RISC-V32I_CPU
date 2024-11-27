addi x1, x0, 5       # x1 = 5
addi x2, x0, 10      # x2 = 10
bne x1, x2, branch_target  # Branch if x1 != x2
nop                  # Delay slot (optional, alignment)
branch_target:       # Label for the target
