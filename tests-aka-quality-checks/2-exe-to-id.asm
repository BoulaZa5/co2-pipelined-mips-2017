addi $s0, $zero, 10
addi $s3, $zero, 5
addi $s4, $zero, 5
beq $s3, $s4, L1
add $s0, $s0, $s3
L1: sub $s0, $s0, $s3