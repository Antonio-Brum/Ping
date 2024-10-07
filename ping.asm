	.data
	display: .space 0x8000 #espaço do display 32768 "pixels"
	lines: .word 0, 512, 1024, 1536, 2048, 2560, 3072, 3584, 4096, 4608, 5120, 5632, 6144, 6656, 7168, 7680,
                   8192, 8704, 9216, 9728, 10240, 10752, 11264, 11776, 12288, 12800, 13312, 13824, 14336, 14848, 15360, 15872,
                   16384, 16896, 17408, 17920, 18432, 18944, 19456, 19968, 20480, 20992, 21504, 22016, 22528, 23040, 23552, 24064,
                   24576, 25088, 25600, 26112, 26624, 27136, 27648, 28160, 28672, 29184, 29696, 30208, 30720, 31232, 31744, 32256, 32768
	origins: .space 12
.text
.globl main

main:
	la	$s0, origins #s0 recebe o vetor 'origins'
	move	$a0, $s0 #a0 é usado para enviar o vetor como argumento para a função 
	jal	startBoard
	
	li 	$s1, 0x00000000 #cor preta
	li 	$s2, 0x00d3d3d3 #cor cinza
	
	
	mover:
	move $a0, $s0
	#jal moveBall
	#li 	$v0, 12 #input de caractere
	#syscall
	lw $t9, 0xFFFF0004
	#move 	$s3, $v0 #passa o caractere para $s3
	#li 	$s4, 'w'
	#li 	$s5, 's'
	#li 	$s6, 'q'
	beq	$t9, 0x00000077, moveUp
	beq	$t9, 0x00000073, moveDown
	beq	$t9, 0x00000071, quit
	
	li 	$a0, 250	#
	li 	$v0, 32	# pause for 250 milisec
	syscall	
	
	j mover
moveUp:
	sw 	$zero, 0xFFFF0004
	move	$a0, $s0
	move 	$a1, $s1 #recebe a cor preta
	
	jal	uploadPaddlePosition
	
	lw 	$s7, 0($s0) 
	nop
	nop
	nop
	addi	$s7, $s7, -1024
	sw 	$s7, 0($s0)
	
	move	$a0, $s0
	move	$a1, $s2
	
	jal	uploadPaddlePosition
	
	j	exitMoving

moveDown:
	sw 	$zero, 0xFFFF0004
	move	$a0, $s0
	move 	$a1, $s1 #recebe a cor preta
	
	jal	uploadPaddlePosition
	
	lw $s7, 0($s0)
	nop
	nop
	nop
	addi	$s7, $s7, 1024
	sw $s7, 0($s0)
	
	move	$a0, $s0
	move 	$a1, $s2
	
	jal	uploadPaddlePosition
	
	j	exitMoving

quit:
	li	$v0, 10
    	syscall
    	
exitMoving:
j mover


##=============
# startBoard
#
#	gera as posições iniciais dos elementos do jogo e
#	passa, por referência, os endereços dos pixels de 
#	origem destes elementos para o vetor 'origins'
##=============
startBoard:

	la $t0, display #posição
	la $t1, lines
	li $t2, 0x00d3d3d3 #cor
	li $t3, 16 #altura raquete
	li $t4, 24 #quero a linha 24
	sll $t4 ,$t4, 2 #multiplica pelo tamanho de cada palavra
	add $t4, $t4, $t1 #$t4 contém o endereço do elemento 24 do array
	lw $t5, 0($t4) #t5 recebe o valor que representa a linha 24
	nop
	nop
	nop
	add $t5, $t5, $t0 #t5 contém o endereço da linha
	move $t6, $t5
	
	sw $t5, 0($a0)# origins [0] contém a origem da raquete esquerda
	draw1:
	sw $t2, 0($t6)
	addi $t6, $t6 ,512
	addi $t3, $t3, -1
	bnez $t3, draw1
	
	
	move $t6, $t5
	addi $t6, $t6, 508
	li $t3, 16
	
	sw $t6, 4($a0)# origins [1] contém a origem da raquete direita
	draw2: 
	sw $t2, 0($t6)
	addi $t6, $t6, 512
	addi $t3, $t3, -1
	bnez $t3, draw2
	
	#bola
	
	li $t4, 31 #primeira linha na linha 31
 	#calculando o índice do vetor
 	sll $t4, $t4, 2
 	add $t4, $t4, $t1
 	lw $t5, 0($t4)
 	nop
	nop
	nop
 	#calculando a posição no display
 	add $t5, $t5, $t0
 	move $t6, $t5
 	addi $t6, $t6, 252
	
	sw $t6, 8($a0) #origins [2] contém a origem da bola
	li $t7, 2
 	line:
 		li $t8, 2
 		column:
 			sw $t2, 0($t6)
 			addi $t6, $t6, 4
 			addi $t8, $t8, -1
 			bnez $t8, column
 	
 		addi $t6, $t6, 504
 		addi $t7, $t7, -1
 		bnez $t7, line
 	
	jr $ra
	
##=============
# uploadPaddlePosition
#
#	recebe o endereço da origem da raquete do player e
#	a cor que ela será pintada
##=============
uploadPaddlePosition:#recebe a origem e a cor

li $t0, 16
lw $t1, 0($a0)
nop
	nop
	nop
loop:
	sw $a1, 0($t1)
	addi $t1, $t1 ,512
	addi $t0, $t0, -1
	bnez $t0, loop
	
jr 	$ra


moveBall:
	lw 	$t0, 8($a0)
	nop
	nop
	nop
	addi 	$t0, $t0, 1000
	sw 	$t0, 8($a0)
	
	li 	$t1, 2
	
	li 	$t3, 0x00d3d3d3
	
 	line1:
 		li 	$t2, 2
 		column1:
 			sw 	$t3, 0($t0)
 			addi 	$t0, $t0, 4
 			addi 	$t2, $t2, -1
 			bnez 	$t2, column1
 	
 		addi 	$t0, $t0, 504
 		addi 	$t1, $t1, -1
 		bnez 	$t1, line1
 	
jr 	$ra
