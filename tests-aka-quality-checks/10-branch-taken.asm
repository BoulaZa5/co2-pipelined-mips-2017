addi $t2, $zero, 112
addi $t1, $zero, 112
and $s0, $zero, $zero
beq $t1, $t2, L
add $s0, $t2, $t1
L: sub $s0, $t2, $t1