addi $t1,$zero,8
addi $t0,$zero,8
addi $s1,$zero,28
ori $s2,$s1,30
srl $s3,$s1,1
sw $s3,0($t0)
sw $s2,4($t0)
lw $s4,4($t0)
sw $s4,12($t0)
add $s4,$s1,$t0
beq $s4,$s1,label1
sub $s4,$zero,$zero
label1: sll $s4,$t0,2
sw $t0,14($t1)
lw $t1,14($t1)
beq $t1,$t0,label2
addi $s5,$zero,236
addi $s6,$zero,326
label2: addi $t1,$zero,16
sw $t0,15($t1)
slt $t3,$t1,$t0
lw $s6,4($t0)
addi $t5,$zero,5
sw $t3,8($s6)