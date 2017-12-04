sw $zero, 4($zero)
addi $t2, $zero, 26
addi $t3, $zero, -26
lw $s3, 4($zero)
beq $s3, $t2, L
addi $t2, $t2, 26
L: addi $t2, $t2, -26