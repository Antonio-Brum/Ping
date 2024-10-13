	#modificar vetor para o padrão que o prof pediu
	.data
	display: .space 0x8000 #espaço do display 32768 "pixels"
	lines: .word 0, 512, 1024, 1536, 2048, 2560, 3072, 3584, 4096, 4608, 5120, 5632, 6144, 6656, 7168, 7680,
                   8192, 8704, 9216, 9728, 10240, 10752, 11264, 11776, 12288, 12800, 13312, 13824, 14336, 14848, 15360, 15872,
                   16384, 16896, 17408, 17920, 18432, 18944, 19456, 19968, 20480, 20992, 21504, 22016, 22528, 23040, 23552, 24064,
                   24576, 25088, 25600, 26112, 26624, 27136, 27648, 28160, 28672, 29184, 29696, 30208, 30720, 31232, 31744, 32256, 32768
	origins: .space 8
	ball_x:	.space 4
	ball_y:	.space 4
	vel_x:  1
	vel_y:	-1
	ball_status:	1
	cpu_move_delay:  .word 0    
    	cpu_move_limit:  .word 100000  
	
.text
.globl main

main:
	la	$s0, origins #s0 recebe o vetor 'origins'
	
	move	$a0, $s0 #a0 é usado para enviar o vetor como argumento para a função 
	jal	startBoard
	
	li 	$s1, 0x00000000 #cor preta
	li 	$s2, 0x00d3d3d3 #cor cinza
	
	jal start
	
	jogo:
		move $a0, $s0
	
		jal check_input
		move	$s4, $v0
		beqz	$s4, no_input
		
		lw $s3, 0xFFFF0004
		
		move	$a1, $s1
		jal	uploadPaddlePosition
		
		beq	$s3, 0x00000077, moveUp
		beq	$s3, 0x00000073, moveDown
		beq	$s3, 0x00000071, quit
	
	no_input:
		sw 	$zero, 0xFFFF0004 #zera o input
		sw	$zero, 0xFFFF0000
		
		move	$a1, $s2
		move	$a0, $s0
		jal	uploadPaddlePosition #atualiza paddle do player
	
	#Logica da CPU:
		move $a0, $s0
		move $a1, $s1       # cor pra pintar a cpu (aqui apaga)
    		jal uploadCpuPaddlePosition  # pintar a cpu
		
		move $a0, $s0
		jal move_cpu
		
		move $a0, $s0
		move $a1, $s2      # cor pra pintar a cpu (aqui deesenha_
    		jal uploadCpuPaddlePosition  # pintar a cpu

    		
		move $a0, $s0
		jal	check_colision
		jal	moveBall

		li 	$v0, 32
		li 	$a0, 20
		syscall	
	
	j jogo

#falta empilhar os registradores antes de chamar 'draw_ball'
#e, depois, alterar os registradores usados em 'draw_ball'
moveBall:
	lw	$t0, ball_x #carrega x da bola
	lw	$t1, ball_y #carrega y da bola
	lw	$t2, vel_x
	lw	$t3, vel_y
	la	$t4, lines
	
	sll	$t5, $t0, 2 #pixels de x
	
	sll	$t6, $t1, 2
	add	$t6, $t6, $t4
	lw	$t7, 0($t6)
	
	add	$t7, $t7, $t5 #soma y com x
	addi	$t7, $t7, 0x10010000 #endereço no display
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	
	move	$a0, $t7
	li	$a1, 0x00000000
	jal	draw_ball
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	
	add	$t0, $t0, $t2 # movimenta 1 x
	add	$t1, $t1, $t3 # movimenta 1 y
	
	#salva a nova posição da bola
	sw	$t0, ball_x 
	sw	$t1, ball_y
	#
	
	sll	$t5, $t0, 2 #quantos pixels em x
	
	#acessando o elemento do array 'lines'
	sll	$t6, $t1, 2
	add	$t6, $t6, $t4
	lw	$t7, 0($t6)
	#
	
	add	$t7, $t7, $t5 #soma y com x
	
	addi	$t7, $t7, 0x10010000 #endereço no display
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	#draw_ball recebe cor, posição (em número bruto)
	move	$a0, $t7
	li	$a1, 0x00d3d3d3	
	jal	draw_ball
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	jr 	$ra


draw_ball:
	move	$t5, $a0
	move	$t6, $a1
	li	$t7, 2
	line1:
 		li 	$t8, 2
 		column1:
 			sw 	$t6, 0($t5)
 			addi 	$t5, $t5, 4
 			addi 	$t8, $t8, -1
 			bnez 	$t8, column1
 	
 		addi 	$t5, $t5, 504
 		addi 	$t7, $t7, -1
 		bnez 	$t7, line1
	jr	$ra


check_colision:
	lw	$t0, ball_x #carrega x da bola
	lw	$t1, ball_y #carrega y da bola
	lw	$t2, vel_x
	lw	$t3, vel_y
	lw	$t4, 0($a0) #y do paddle do player
	
	beq	$t1, 0, horizontal
	beq	$t1, 62, horizontal
	
	beq	$t0, 10, player_collision
	beq 	$t0, 502, cpu_collision 
	
	beq	$t0, 0, vertical
	beq	$t0, 126, vertical
	
	retorno:
	jr	$ra

	vertical:
		not	$t2, $t2
		addi	$t2, $t2, 1
		sw	$t2, vel_x
		
		j	retorno
	horizontal:
		not	$t3, $t3
		addi	$t3, $t3, 1
		sw	$t3, vel_y
		
		j 	retorno

	player_collision:
		addi	$t6, $t4, 1 #como a bola tem 2 de altura, ela precisa estar na posição maior que 'paddle + 1'
		blt	$t1, $t6, retorno #verifica se a bola passou por cima do paddle 
		
		addi	$t6, $t6, 17 #calcula a parte de baixo do paddle
		bgt	$t1, $t6, retorno
		
		not	$t2, $t2
		addi	$t2, $t2, 1
		sw	$t2, vel_x
		
		j 	retorno

	cpu_collision:
		lw  $t5, 4($a0)             # Load right paddle y position (origin[1])

		addi $t6, $t5, 1            # Paddle's top edge + 1 pixel
    		blt  $t1, $t6, retorno       # If ball is above paddle, return
    
    		addi $t6, $t6, 17           # Paddle's bottom edge (16 height)
    		bgt  $t1, $t6, retorno       # If ball is below paddle, return
    
    		not $t2, $t2                # Reverse horizontal velocity (ball bounce)
		addi $t2, $t2, 1
    		sw  $t2, vel_x
    
    		j   retorno

check_input:
    li  $t0, 0xFFFF0000
    lw  $v0, 0($t0)

    jr  $ra


moveUp:
	lw 	$s7, 0($s0) 
	beq	$s7, 0, no_input
	addi	$s7, $s7, -2
	sw 	$s7, 0($s0)
	
	j	no_input

moveDown:
	lw $s7, 0($s0)
	beq	$s7, 48, no_input
	addi	$s7, $s7, 2
	sw $s7, 0($s0)

	j	no_input

quit:
	li	$v0, 10
    	syscall


start:
	wait:
		li	$t0, 0xFFFF0000
		lw	$t1, 0($t0)
		beq	$t1, $zero, wait
	
	lw	$t2, 0xFFFF0004
	bne	$t2, 0x00000031, start
	
	jr $ra
	
##=============
# uploadPaddlePosition
#
#	recebe o endereço da origem da raquete do player e
#	a cor que ela será pintada
##=============
uploadPaddlePosition:#recebe a origem e a cor
	lw 	$t1, 0($a0)
	la	$t2, lines

	sll	$t1, $t1, 2
	add	$t1, $t1, $t2
	lw	$t3, 0($t1)
	li 	$t0, 16
	addi	$t3, $t3, 0x10010000
	addi	$t3, $t3, 36

	loop:
		sw $a1, 0($t3)
		addi $t3, $t3 ,512
		addi $t0, $t0, -1
		bnez $t0, loop

	jr 	$ra



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
	
	sw	$t4, 0($a0) #salvando posição da raquete esquerda
	
	sll $t4 ,$t4, 2 #multiplica pelo tamanho de cada palavra
	add $t4, $t4, $t1 #$t4 contém o endereço do elemento 24 do array
	lw $t5, 0($t4) #t5 recebe o valor que representa a linha 24

	add 	$t5, $t5, $t0 #t5 contém o endereço da linha
	addi	$t5, $t5, 36 #x=9
	move 	$t6, $t5
	
	# origins [0] contém a origem da raquete esquerda
	draw_player:
		sw $t2, 0($t6)
		addi $t6, $t6 ,512
		addi $t3, $t3, -1
		bnez $t3, draw_player
	
	move $t6, $t5
	addi $t6, $t6, 440
	li $t3, 16
	
	# origins [1] contém a origem da raquete direita
	draw_cpu: 
		sw $t2, 4($t6)
		addi $t6, $t6, 512
		addi $t3, $t3, -1
		bnez $t3, draw_cpu
	
	#bola
	
	li 	$t4, 31 #Y da origem da bola
	li	$t9, 63 #X da origem da bola
	
	sw	$t4, ball_y
	sw	$t9, ball_x
 	#calculando o índice do vetor
 	sll 	$t4, $t4, 2
 	sll	$t9, $t9, 2
 	add 	$t4, $t4, $t1
 	lw 	$t5, 0($t4)
 
 	#calculando a posição no display
 	add 	$t5, $t5, $t0
 	add	$t5, $t5, $t9
 
 	move $t6, $t5
	
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
	
	
move_cpu:
    lw    $t2, cpu_move_delay    
    lw    $t3, cpu_move_limit    
    
    blt   $t2, $t3, return_cpu   
    
    li    $t2, 0                 
    sw    $t2, cpu_move_delay    
    
    lw    $t0, 4($a0)            
    lw    $t1, ball_y            

   # blt   $t1, $t0, moveUpCPU    
    #bgt   $t1, $t0, moveDownCPU  
    
    j    return_cpu              

	moveUpCPU:
	    li    $t2, 0                  
	    beq   $t0, $t2, return_cpu    
	    addi  $t0, $t0, -2            
	    sw    $t0, 4($a0)             
	    j    return_cpu

	moveDownCPU:
	    li    $t2, 48                 
	    beq   $t0, $t2, return_cpu    
	    addi  $t0, $t0, 2             
	    sw    $t0, 4($a0)             

	return_cpu:
		jr    $ra     
	    
	       
uploadCpuPaddlePosition:   # Recebe a origem e a cor da raquete da CPU
	lw  $t1, 4($a0)         # Carrega a origem da raquete da CPU a partir de origins[1]
	la  $t2, lines          # Carrega o endereço base da linha (vetor de deslocamentos)
	
	sll $t1, $t1, 2         # Multiplica a posição da raquete por 4 (palavras)
	add $t1, $t1, $t2       # Adiciona o deslocamento no vetor lines
	lw  $t3, 0($t1)         # Carrega o valor do vetor lines correspondente à linha da raquete

	la $t3, display         # Posição
	li  $t0, 16             # Define a altura da raquete (16 pixels)
	addi $t3, $t3, 480     # X da raquete da CPU (linha à direita da tela)

	
	cpu_loop:
	    sw $a1, 0($t3)          # Escreve a cor da raquete no display
	    addi $t3, $t3, 512      # Move para a próxima linha da raquete
	    addi $t0, $t0, -1       # Decrementa a altura
	    bnez $t0, cpu_loop      # Continua até desenhar toda a raquete (16 linhas)

	    jr $ra         
