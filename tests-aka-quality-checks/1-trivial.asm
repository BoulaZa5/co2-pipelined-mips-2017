addi $s3, $zero, 18
sw $zero, 4($zero)
ori $s4, $zero, 16
nor $s5, $zero, $s3
or $s3, $zero, $s3
lw $s6, 4($zero)
slt $t8, $s5, $s4
sll $t2, $s4, 2
srl $t3, $s3, 1