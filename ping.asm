.data
	display: .space 0x8000 #espaço do display 32768 "pixels"
	lines: .word 0, 512, 1024, 1536, 2048, 2560, 3072, 3584, 4096, 4608, 5120, 5632, 6144, 6656, 7168, 7680,
                   8192, 8704, 9216, 9728, 10240, 10752, 11264, 11776, 12288, 12800, 13312, 13824, 14336, 14848, 15360, 15872,
                   16384, 16896, 17408, 17920, 18432, 18944, 19456, 19968, 20480, 20992, 21504, 22016, 22528, 23040, 23552, 24064,
                   24576, 25088, 25600, 26112, 26624, 27136, 27648, 28160, 28672, 29184, 29696, 30208, 30720, 31232, 31744, 32256, 32768

.text
.globl main

main:
	jal startBoard
	









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
	
	draw1:
	sw $t2, 0($t6)
	addi $t6, $t6 ,512
	addi $t3, $t3, -1
	bnez $t3, draw1
	
	move $t6, $t5
	addi $t6, $t6, 508
	li $t3, 16
	
	draw2: 
	sw $t2, 0($t6)
	addi $t6, $t6, 512
	addi $t3, $t3, -1
	bnez $t3, draw2
	
	jr $ra
	