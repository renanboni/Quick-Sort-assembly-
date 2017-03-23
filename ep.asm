.data
	buffer1:		.space	400000
	buffer2:		.space	400000
	buffer_save:		.space	400000
	list1_size:		.word 1
	list2_size:		.word 1
	list_size:		.word 1
	list:			.word 4
	space:			.asciiz " "
	newLine:		.asciiz "\r"
	newLine2:		.asciiz "\n"
	size1:			.word 1
	size2:			.word 1
.text
main:
	#-- $a0 argc
	#-- $a1 argv[]
	addi	$sp, $sp, -12
	
	lw	$t0, ($a1)	#-- first argument
	sw	$t0, ($sp)
	
	lw	$t0, 4($a1)	#-- second argument
	sw	$t0, 4($sp)
	
	lw	$t0, 8($a1)	#-- third argument
	sw	$t0, 8($sp)

	#-- call open file --#
	jal	open_file
	
	#-- call concatenate --#
	la	$a0, buffer1
	la	$a1, buffer2
	la	$a2, list1_size
	la	$a3, list2_size
	jal	concatena
	
	#-- call insertion sort --#
	la	$t0, list1_size
	lw	$t0, 0($t0)
	la	$t1, list2_size
	lw	$t1, 0($t1)
	add	$a0, $t0, $t1	#-- a0 lista size
	la	$a2, list
	lw	$a2, 0($a2)	#-- a2 list
	jal	ordena
	
	#-- call trim --#
	la	$t0, list1_size
	lw	$t0, 0($t0)
	la	$t1, list2_size
	lw	$t1, 0($t1)
	la	$a0, list
	lw	$a0, 0($a0)
	add	$a1, $t0, $t1		
	jal	trim
	
	#-- call save file --#
	move	$a0, $v0	#-- list size
	la	$a1, buffer_save#-- buffer
	la	$a2, list
	lw	$a2, 0($a2)
	jal	save_file
	
	#-- end program --#
	li $v0, 10
	syscall
	
open_file:
	#-- open file 1 --#
	li	$v0, 13		#open file parameter
	lw	$a0, ($sp)
	addi	$sp, $sp, 4
	li	$a1, 0		#flag to read
	li	$a2, 0		#another flag
	syscall
	
	#-- save the file descriptor --#
	move	$s2, $v0
	
	#-- read file contents --#
	move	$a0, $s2
	la	$a1, buffer1
	li	$a2, 1048576
	li	$v0, 14
	syscall
	
	#-- close the file --#
	li	$v0, 16
	move	$a0, $s2
	syscall
	
	#-- count numbers in file --#
	#-- $t0 = counter
	#-- $t1 = buffer pointer
	#-- $t2 = current char
	
	addi	$t0, $zero, 0
	la	$t1, buffer1
	addi	$t2, $zero, 0
	addi	$t5, $zero, 0
	
	#-- 0x00	null (end of file)
	#-- 0x0a	\n new line
	#-- 0x0d	\r
	#-- 0x20	space
	
	while1:
		lb	$t2, 0($t1)		# primeiro byte
		addi	$t5, $t5, 1		# quantidade de caracteres
		addi	$t1, $t1, 1		# incrementa contador
		beq	$t2, 0x00, exit1	# EOF
		beq	$t2, 0x0a, count1	# quebra de linha \n
		beq	$t2, 0x20, count1	# espaço
		beq	$t2, 0x0d, decrease1    # \r
		j 	while1
		
	decrease1:
		addi	$t5, $t5, -1
		j	while1
	count1:
		addi	$t0, $t0, 1
		j 	while1
	exit1:
		sw	$t5, size1
		addi	$t0, $t0, 1
		
	#-- salva a quantidade de itens na memória
	sw	$t0, list1_size
	
	#-- open file 2 --#
	li	$v0, 13
	lw	$a0, ($sp)
	addi	$sp, $sp, 4
	li	$a1, 0	
	li	$a2, 0
	syscall
	
	#-- save the file descriptor --#
	move	$s2, $v0
	
	#-- read file contents --#
	move	$a0, $s2
	la	$a1, buffer2
	li	$a2, 1048576
	li	$v0, 14
	syscall
	
	#-- close file --#
	li	$v0, 16
	move	$a0, $s2
	syscall
	
	#-- count numbers in file 2 --#
	#-- $t0 = counter
	#-- $t1 = buffer pointer
	#-- $t2 = current char
	
	addi	$t0, $zero, 0
	la	$t1, buffer2
	addi	$t2, $zero, 0
	addi	$t5, $zero, 0
	
	#-- 0x00	null (end of file)
	#-- 0x0a	\n new line
	#-- 0x0d	\r 
	#-- 0x20	space
	
	while2:
		lb	$t2, 0($t1)		# first byte
		addi	$t1, $t1, 1		# increment the counter
		addi	$t5, $t5, 1
		beq	$t2, 0x00, exit2	# end of file
		beq	$t2, 0x0a, count2	# new line
		beq	$t2, 0x20, count2	# space
		beq	$t2, 0x0d, decrease2	# \r
		j 	while2
	
	decrease2:
		addi	$t5, $t5, -1
		j	while2
	count2:
		addi	$t0, $t0, 1
		j 	while2
	exit2:
		sw	$t5, size2
		addi	$t0, $t0, 1
		
	#-- save the number of items to the memory
	sw	$t0, list2_size	
	
	jr	$ra
	
concatena:
	#-- $t0 = list1 size
	#-- $t1 = list2 size
	#-- $t2 = (list1 + list2) size
	lw	$t0, 0($a2)
	lw	$t1, 0($a3)
	add	$t2, $t0, $t1	
	sw	$t2, list_size
	
	#-- save list2 size --#
	move	$t5, $t1
	
	#-- calculate the ammount of memory we need (4 bytes * $t2)
	mul	$t3, $t2, 4
	
	#-- allocate memory from heap
	addi	$a0, $t3, 0
	li	$v0, 9
	syscall
	
	#-- save the array address
	sw	$v0, list
	move	$s5, $v0
	
	move	$s0, $t0	#list1 size
	la	$s1, buffer1	#list1 buffer	
	addi	$t0, $zero, 0	#counter
	
	for1:
		beq	$t0, $s0, exit_for1
		lb	$t1, 0($s1)
		beq	$t1, 0x20, increment_buffer
		beq	$t1, 0,	exit_and_add
		sb	$t1, 0($s5)
		addi	$s5, $s5, 4
		addi	$s1, $s1, 1
		j	for1
	exit_for1:
		j	for2
	
	exit_and_add:
		li	$t1, 13
		sb	$t1, 0($s5)
		addi	$s5, $s5, 4
		li	$t1, 10
		sb	$t1, 0($s5)
		addi	$s5, $s5, 4		
	
	move 	$s0, $t5	#list2 size
	la	$s1, buffer2	#list2 buffer
	addi	$t0, $zero, 0	#counter
	
	for2:
		beq	$t0, $s0, exit_for2
		lb	$t1, 0($s1)
		beq	$t1, 0x20, increment_buffer2
		beq	$t1, 0, exit_eof
		sb	$t1, 0($s5)
		addi	$s5, $s5, 4
		addi	$s1, $s1, 1
		j	for2
				
	increment_buffer:
		addi	$t0, $t0, 1
		addi	$s1, $s1, 1
		sb	$t1, 0($s5)
		addi	$s5, $s5, 4
		j	for1
		
	increment_buffer2:
		addi	$t0, $t0, 1
		addi	$s1, $s1, 1
		sb	$t1, 0($s5)
		addi	$s5, $s5, 4
		j	for2

	exit_for2:
		j	convert
		
	exit_eof:
		li 	$t0, 0x00
		sb	$t1, 0($s5)
		j	convert

convert:
		#-- parse the string again, now loading the values
		#-- $t0 buffer pointer
		#-- $t1 counter
		#-- $t2 current list item address
		#-- $t3 list address
		#-- $t4 current char
		#-- $t5 loop counter
		#-- $t6 number of iterations
		
		la	$t0, list
		lw	$t0, 0($t0)
		addi	$t1, $zero, 0
		addi	$t5, $zero, 0
		lw	$t6, list_size
		move	$t7, $t0

		#-- save the return address in the stack
		addi		$sp, $sp, -4
		sw		$ra, 0($sp)
		
		#-- 0x00	null (end of file)
		#-- 0x0a	new line
		#-- 0x20	space
		
		convert_loop:
			#-- check if the char is valid
			lb		$t4, 0($t0)
			beq		$t4, 0x00, end
			beq		$t4, 0x0a, skip
			beq		$t4, 0x0d, skip
			
			#parse number
			move	$a0, $t0	
			jal		atoi
			
			move	$t0, $v1
			
			add		$t2, $t1, $t7
			sw		$v0, 0($t2)
			
			addi		$t1, $t1, 4
			addi		$t5, $t5, 1
			beq		$t5, $t6, end
			j		convert_loop
			
			skip:
				addi	$t0, $t0, 4
				j convert_loop
		
		# int atoi(char *c)
		atoi:
			li		$v0, 0
			lb		$t0, 0($a0)
			addi		$t2, $zero, 1
			beq		$t0, '-', negative_signal
			beq		$t0, '+', positive_signal
			j		parse
			
		negative_signal:
			addi		$t2, $zero, 0
			addi		$a0, $a0, 4
			j		parse
		
		positive_signal:
			addi		$a0, $a0, 4
			
		parse:
			lb		$t0, 0($a0)
			addi		$a0, $a0, 4
			
			blt		$t0, 48, atoi_final
			bgt		$t0, 58, atoi_final
			
			mul		$v0, $v0, 10
			
			addi		$t0, $t0, -48
			add		$v0, $v0, $t0
			
			j		parse
			
		atoi_final:
			beq		$t2, 0, atoi_multiply
			j		atoi_exit
			
		atoi_multiply:
			mul		$v0, $v0, -1
			
		atoi_exit:
			move	$v1, $a0
			jr		$ra
		
		end:
			lw		$ra, 0($sp)
			addi		$sp, $sp, 4
			jr		$ra

#-- void quick_sort(int l, int r, int* list)
#-- a0(s0) = l
#-- a1(s1) = r
#-- a2(s7) = base list
#-- s2 = pivo
#-- s3 = p
#-- s4 = i
#-- s5 = pos(partition)
#-- s6 = tmp
ordena:
	addi 	$a1, $a0, -1 #a1 = r
	addi 	$a0, $zero, 0 #a0 = l
	
.quick_inicio:
	
	# creates stack frame and then saves
	addi 	$sp, $sp, -20
	
	sw 	$s7, 0($sp)
	sw 	$s0, 4($sp)
	sw 	$s1, 8($sp)
	sw 	$s2, 12($sp)
	sw 	$ra, 16($sp)
	
	move 	$s0, $a0
	move 	$s1, $a1
	
	bge 	$a0, $a1, .quick_return_final #l >= r = quick_return
	
	add 	$s3, $a0, $a1 #$s3 = l + r
	div 	$s3, $s3, 2 #$s3 = (l + r) / 2 = p
	
	#int pos = partition(l, r, p, list)
	jal 	.quick_partition
	
.apos_partition:	
	move 	$s2, $v0
	
	#quick_sort(l, pos-1, list)
	subi 	$a1, $s2, 1
	jal 	.quick_inicio
	
	#quick_sort(pos+1, r, list)
	addi 	$a0, $s2, 1
	move 	$a1, $s1
	jal 	.quick_inicio

	move 	$a0, $s0	
	j 	.quick_return_final
	
.quick_partition:

	#swap(p, r, list)
	move 	$a3, $s3
	move 	$t6, $a1
	jal 	.quick_swap
	
	add 	$s4, $zero, $a0 #i = l
	add 	$s5, $zero, $a0 #pos = l

.partition_while:
	bge 	$s4, $a1, .partition_final #i >= r = .partition_final
	
	mul 	$t0, $s4, 4
	add 	$t0, $t0, $a2
	
	mul 	$t1, $a1, 4
	add 	$t1, $t1, $a2
	
	lw 	$t2, 0($t0) #$t2 = list[i]
	lw 	$t7, 0($t1) #$t7 = list[r]
	
	
	bge 	$t2, $t7, .partition_while_final #list[i] >= list[j] = .partition_while_final
	
	#swap(i, pos, list)
	move 	$a3, $s4
	move 	$t6, $s5
	jal 	.quick_swap
	
	addi 	$s5, $s5, 1 
	
.partition_while_final:
	addi 	$s4, $s4, 1
	j 	.partition_while
	
.partition_final:
	#swap(r, pos, list)
	move 	$a3, $a1
	move 	$t6, $s5
	jal 	.quick_swap
	
	move 	$v0, $s5 #return pos
	
	j 	.apos_partition
	
.quick_swap:
	# $a3 = a
	# $t6 = b
	# $t0 = list[a]
	# $s6 = tmp
	# t3 = list[] (a)
	# t4 = list[] (b)
	# t5 = conteudo de list[b]
	
	mul 	$t3, $a3, 4
	add 	$t3, $t3, $a2
	lw  	$s6, 0($t3) #tmp = list[a]

	mul 	$t4, $t6, 4
	add 	$t4, $t4, $a2
	lw  	$t5, 0($t4) #t5 = conteudo de list[b]
	sw  	$t5, 0($t3) #list[a] = list[b]
	
	sw 	$s6, 0($t4) #list[b] = tmp
	
	jr 	$ra

.quick_return_final:

	lw 	$ra, 16($sp)
	lw 	$s2, 12($sp)
	lw 	$s1, 8($sp)
	lw 	$s0, 4($sp)
	lw 	$s7, 0($sp)
	addi 	$sp, $sp, 20
	
	jr 	$ra	

#-- remove os elementos repetidos
#-- $a0 = list
#-- $a1 = list_size
trim:
	move	$t0, $a0	# lista
	mul	$t1, $a1, 4	# tamanho da lista em bytes
	add	$t1, $a0, $t1	# final da lista
	
	
	.for1:
		beq	$t0, $t1, .end	# se chegou ao final, entao...
		lw	$s1, 0($t0)	# carrega primeiro numero
		move	$t2, $t0	# salva $t0
		
		.for2:
			addi	$t2, $t2, 4	# incrementa para posicao i + 1
			beq	$t2, $t1, back  # se i + 1 = i (dois valores iguais)
			lw	$s2, 0($t2)
			beq	$s1, $s2, remove
			j	.for2
	
	back:
		addi	$t0, $t0, 4	
		j	.for1
							
	remove:
		move	$s3, $t2
		j	remove_loop
		
	remove_loop:
		addi	$s3, $s3, 4
		beq	$s3, $t1, remove_end
		add	$t5, $s3, -4
		lw	$t6, 0($s3)
		sw	$t6, 0($t5)
		j	remove_loop
		
	remove_end:
		addi	$t2, $t2, -4
		addi	$t1, $t1, -4
		j	.for2
	.end:
		sub	$v0, $t1, $a0
		div	$v0, $v0, 4
		jr	$ra
	
save_file:
	#-- a0 list size
	#-- a1 buffer
	move	$s1, $a0	# tamanho da lista 
	move	$s2, $a1	# buffer

	li	$s3, 0		# contador
	
	add	$t7, $a2, $zero	# lista
	
	addi	$sp, $sp, -4	# salva endereco de retorno
	sw	$ra, 0($sp)
	
	save_while:
		beq	$s1, $s3, end_save	# teste se chegou ao final da lista
		
		lw	$t0, 0($t7)	# carrega primeiro numero
		li	$t1, 0x0E
		jal	start_conversion # converte pra ASCII
		
		la	$s6, 0x0a	# adiciona quebra de linha
		sb	$s6, 0($s2)	# salva no buffer
		
		addi	$s2, $s2, 1	# incrementa contador do buffer
		addi	$t7, $t7, 4	# incrementa contador do vetor
		
		addi	$s3, $s3, 1	# incrementa contador do loop
		j	save_while
		
	end_save:
		j	write	# escreve no arquivo

#-- processo inverso ao atoi
#-- dado um número, transforma ele no código
#-- correspondente da tabela ASCII
#-- e entao adiciona no buffer para salvar		
start_conversion:
	li	$t0, 1000000000
	lw	$t1, 0($t7)
	li	$t5, 0
	move	$t2, $t1
	blt	$t2, 0, negative_conversion
	j	continue_start
	
negative_conversion:
	addi	$t0, $zero, '-'
	sb	$t0, 0($s2)
	addi	$s2, $s2, 1
	mul	$t2, $t2, -1
	move	$t1, $t2
	li	$t0, 1000000000
continue_start:
	bnez	$t2, division_conversion
	li	$t0, 0
	j	store_conversion
	
division_conversion:
	div	$t2, $t1, $t0
	mfhi	$t1
	div	$t0, $t0, 10
	seq	$t3, $t2, $zero
	bnez	$t3, division_conversion
	
store_conversion:
	addi	$t2, $t2, 48
	sb	$t2, 0($s2)
	addi	$s2, $s2, 1
	beqz	$t0, end_conversion
	div	$t2, $t1, $t0
	mfhi	$t1
	div	$t0, $t0, 10
	j	store_conversion
	
end_conversion:
	jr	$ra
#-- salva no arquivo	
write:
	li	$v0, 13
	lw	$a0, 4($sp)
	li	$a1, 1
	li	$a2, 0
	syscall	
	move	$t5, $v0
	
	li	$v0, 15
	move	$a0, $t5
	la	$t0, size1
	lw	$t0, 0($t0)
	la	$t1, size2
	lw	$t1, 0($t1)
	la	$a1, buffer_save
	add	$a2, $t0, $t1
	syscall
	
	li	$v0, 16
	move	$a0, $t5
	syscall
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
	
	
	
	
