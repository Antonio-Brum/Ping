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
	la $s0, origins
	move $a0, $s0
	jal startBoard
	
	la $s1, origins
	lw $t9, 0($s1)
	
	li $s2, 0x000000FF
	sw $s2, 0($t9)
	
	lw $t9, 4($s1)
	sw $s2, 0($t9)
	
	lw $t9, 8($s1)
	sw $s2, 0($t9)
	
	li   $v0, 10      # Exit syscall
    	syscall









startBoard:

	la $t0, display #posição
	la $t1, lines
	li $t2, 0x00d3d3d3 #cor
	li $t3, 16 #altura raquete
	li $t4, 24 #quero a linha 24
	sll $t4 ,$t4, 2 #multiplica pelo tamanho de cada palavra
	add $t4, $t4, $t1 #$t4 contém o endereço do elemento 24 do array
	lw $t5, 0($t4) #t5 recebe o valor que representa a linha 24
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
	
