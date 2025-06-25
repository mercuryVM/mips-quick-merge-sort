.data
	localArquivo: .asciiz "D:/OAC/EP2Clodoaldo/numeros.txt"
	conteudoArquivo: .space 1024
	erroArquivoMessagem: .asciiz "Erro ao abrir arquivo"
	newLine: .asciiz "\n"
	zeroPontoUm: .float 0.1
	dez: .float 10.0
	zero: .float 0.0
	um: .float 1.0
	dois: .float 2.0
	tres: .float 3.0
	quatro: .float 4.0
	cinco: .float 5.0
	seis: .float 6.0
	sete: .float 7.0
	oito: .float 8.0
	nove: .float 9.0
	menosUm: .float -1.0
	precisao: .float 100000.0
	algoritmoOrdenacao: .word 2 #1 para insertion, 2 para quick sort
	float_buffer: .space 1024

.text
.globl main
main:
	li $s2, 0 # quantos newlines tem o arquivo

	# Abrir o arquivo
	jal abrirArquivo
	
	# Ler buffer de linhas para descobrir quantas linhas tem o arquivo (pressupõe-se que cada número é uma linha)
	jal lerBufferNL

calcularVetor:
	# s2, número de quebra de linhas, logo, número de números
	addi $s2, $s2, 1
	
	# t1, quantos bytes vamos alocar (float 32 bits, 4 bytes) (tamanho = 4 bytes * s2)
	mul $t1, $s2, 4
	
	# aloca memória para nosso vetor de números (syscall 9)
	li $v0, 9
	move $a0, $t1
	syscall
	
	# s1 agora é o endereço do primeiro do nosso vetor
	move $s1, $v0
	
	# t1, qual o índice estamos agora no vetor
	li $t1, 0
	
	jal fecharArquivo
	jal abrirArquivo
	
	# Após a leitura, começar a interpretação de números
	la $s7, interpretarNumero
	j lerBufferNumeros
	
ordenacao:
	# Guarda nosso algoritmo de ordenação
	la $t0, algoritmoOrdenacao
	lw $t1, 0($t0)
	
	beq $t1, 1, insertionSort
	beq $t1, 2, iniciaQuickSort
	
	j fecharPrograma
	
printarVetor:
    	li $t2, 0  # iterator i
    	li $s3, 0 # bytes a serem escritos
    	li $t3, 0 # caracter do numero atual
    	li $t5, 0 # resto da divisão atual
    	li $t7, 10 # dez
    
    	jal fecharArquivo
    
    	# Configurar abertura de arquivo
	li $v0, 13
	la $a0, localArquivo
	# Apenas escrita
	li $a1, 1
	li $a2, 8
	syscall
	move $s0, $v0
	
	j test_for_print

test_for_print:
    	blt $t2, $s2, for_print
    	j failed_for_print
    
for_print:
    	# Calcula o offset: t3 = s1 + t2 * 4
    	mul $t4, $t2, 4
    	add $t4, $s1, $t4

    	# Carrega o float vetor[i] em f12
    	l.s $f12, 0($t4)
    
    	jal start_print_number
    
flush_print:
	la   $t4, float_buffer   # base do buffer
    	add  $t4, $t4, $s3       # offset = s3
    	li   $t3, 10             # ASCII LF
    	sb   $t3, 0($t4)
    	addi $s3, $s3, 1         # conta +1 byte

	# Escreve no arquivo
    	li $v0, 15        # syscall write
    	move $a0, $s0     # descritor do arquivo (já aberto em $s0)
    	la $a1, float_buffer
    	move $a2, $s3
    	syscall
    	
    	move $s3, $zero
    	add $t2, $t2, 1
    	
    	j test_for_print
    	
start_print_number:
	# para printarmos o número no console precisamos dividir a parte inteira do ponto flutuante por 10 e pegar o resto.
	# não existe como escrever float no assembly, então precisamos encontrar os caracteres específicos para escrevermos
	# para isso, vou truncar o float usando a pseudoinstrução trunc.w.s e copiar pro registrador com mfc1
	
	li $s6, 0 # printando decimal
	
	start_print_decimal:
	
	# obtém a parte inteira do float q estamos printando
	trunc.w.s $f0, $f12
	# move pro registrador
	mfc1      $t6, $f0 # parte inteira
	li $s7, 0 # quantos numeros empilhados
	
	l.s $f23, zero
	
		# verificação negativo
		c.lt.s $f12, $f23
		bc1t int_print_number_neg_number
	
	j int_print_number
	
	# se o número for negativo, multiplica por -1 e adiciona o - no buffer
	int_print_number_neg_number:
		mul $t6, $t6, -1
		# se estamos printando decimal, n precisa de sinal no buffer. apenas inverta o numero
		beq $s6, 1, int_print_number
	
		la $t4, float_buffer
		add $t4, $t4, $s3
		li $t3, 45
		sb $t3, 0($t4)   
		
		add $s3, $s3, 1 # mais um byte a escrever
		
		j int_print_number
	
	int_print_number:

		
		# divisão por 10
		div $t6, $t7
	
		mfhi      $t4 # resto da divisao
		
		# empilha os restos
		sub $sp, $sp, 4
		sw $t4, 0($sp)
		add $s7, $s7, 1
		
		mflo $t6 # resultado da divisão
		
		# se o valor da divisão <= 0, fim
		blez $t6, end_int_print_number
		
		# continua iterando até acabar
		j int_print_number
		
	decimal_start:
		# adicionar ponto no buffer
		la $t4, float_buffer
		add $t4, $t4, $s3
		li $t3, 46
		sb $t3, 0($t4)   
		
		add $s3, $s3, 1 # mais um byte a escrever
		
		# foi necessario essas duas pseudoinstrucoes para termos os valores corretamente representados em float, mas truncado
		# tentei sem o cvt.s.w mas aí ficou NaN
		trunc.w.s $f0, $f12
		cvt.s.w $f0, $f0
		
		l.s $f2, zero
		
		c.lt.s $f0, $f2
		bc1t absolute
			
		decimal_start_continue_next:
	
		# precisamos pegar o valor que estamos pritando - parte inteira para obtermos o decimal
		# f0 contém a truncada e f12 a f12 o valor que estamos printando
		sub.s $f1, $f12, $f0 # ex.: 3,12 - 3 = 0,12
		
		# flag printando decimal para reaproveitar mesmo código
		
		li $s6, 1
		
		l.s $f2, precisao
		
		# precisão, 5 casas
		mul.s $f12, $f1, $f2
		
		j start_print_decimal	
		
			
		absolute:
			l.s $f2, menosUm
			mul.s $f0, $f0, $f2
			mul.s $f12, $f12, $f2
			j decimal_start_continue_next
		
	check_decimal_start:
		#s6: printando decimal
		#s7: quantos na pilha
		
		li $t4, 0
		
		bgt $s7, $t4, goBackDecimalStart
		beq $s6, $t4, decimal_start
		j flush_print
		
		goBackDecimalStart:
			jr $ra
		
	end_int_print_number:
		jal check_decimal_start
		
		lw $t4, 0($sp) # resto desempilhado
		sub $s7, $s7, 1 # desempilha
		add $sp, $sp, 4
		add $t4, $t4, 48 # converte char

		
		# salva no buffer esse char
		la $t6, float_buffer
		add $t6, $t6, $s3
		sb $t4, 0($t6)   
		
		add $s3, $s3, 1 # mais um byte a escrever
		
		# continua escrevendo os chars
		
		j end_int_print_number
	

failed_for_print:
	jal fecharArquivo
    	j fecharPrograma
		
breakLine:
	li $v0, 4          # syscall 4 = print string
    	la $a0, newLine    # carrega o endereço da string "\n"
    	syscall
    	jr $ra

fimOrdena:
	j printarVetor
			
insertionSort:
	blt $s2, 2, fimOrdena
	
	li $t2, 1 # iterator i
	
	j test_for
	
	test_for:
		blt $t2, $s2, for
		j failed_for
		
	for:	
		#offset: $t2
		mul $t3, $t2, 4
		#aqui t2 vira endereço base (s1 + offset)
		#t3 endereço de cada
		add $t3, $s1, $t3
		
		# vetor[i]
		l.s $f0, 0($t3)   

		# j é t4, i - 1
		sub $t4, $t2, 1 # j = i - 1
		
		j test_while
		
		test_while:
			blt $t4, 0, end_while
			#endereço de j
			mul $t3, $t4, 4
			add $t3, $s1, $t3
			
			# vetor[j]
			l.s $f1, 0($t3)
			
			# vetor[j] <= vetor[i]
			c.le.s $f0, $f1 
			# se for falso, ou seja vetor[j] > vetor[i]
			bc1f end_while
			
			j while
		
		while:	
			mul $t7, $t4, 4
		
			# endereço j
			add $t5, $t7, $s1
			
			# endereço j + 1
			add $t6, $t5, 4
			
			#vetor[j]
			l.s $f2, 0($t5)
			  
			s.s $f2, 0($t6)
			
			sub $t4, $t4, 1
			
			j test_while
		
		end_while:
		
		# j = j + 1
		add $t4, $t4, 1
		# offset no vetor para j + 1
		mul $t3, $t4, 4
		#aqui t3 vira endereço base (s1 + offset)
		add $t3, $s1, $t3
		
		# salva no j+1 o key
		s.s $f0, 0($t3)   
		
		add $t2, $t2, 1 #i++
		j test_for
	
	failed_for:
		j fimOrdena
		
iniciaQuickSort:
	li $t0, 0 # 0
	sub $t1, $s2, 1
	
	# stack size
	li $s5, 1
	
	j quickSort
	
quickSort:
	# Basicamente precisamos criar uma pilha de execução dos QuickSorts.
	# Nessa pilha iremos guardar cada chamada de execução do Quicksort, incluindo informações como (low, high e PC)
	# A ideia é que a cada "chamada recursiva" os valores atuais do Quicksort e a instrução chamada posteriormente sejam empilhados para a execução da recursão executada
	# E ao término dessa recursão, a pilha seja desempilhada assim retornando a chamada anterior junto com a instrução posterior a recursão para prosseguir com o código
	# Devemos alocar uma pilha e tratar as chamadas recursivas que usarão essa pilha
	
	#$t0: low, $t1: high
	
	bge $t0, $t1, quick_sort_retorno
	
	j partition
	
	partition:
		#offset: $t2
		mul $t2, $t0, 4
		
		#aqui t2 vira endereço base (s1 + offset)
		add $t2, $s1, $t2
		
		# vetor[low] (p)
		l.s $f0, 0($t2)
		
		# i = low
		move $t3, $t0   

		# j = high
		move $t4, $t1
		
		j test_while_partition
		
		test_while_partition:
			blt $t3, $t4, while_partition
			j end_while_partition
			
		while_partition:
			j test_while_first
			
			test_while_first:
				# high - 1
				sub $t5, $t1, 1
			
				#offset i no array
				mul $t2, $t3, 4
			
				# endereço arr[i]
				add $t2, $s1, $t2
			
				# vetor [i]
				l.s $f1, 0($t2)
			
				# vetor[i] <= p
				c.le.s $f1, $f0 
				# se for verdadeiro, go to end_while_first
				bc1f end_while_first
				
				# i <= high - 1
				bgt $t3, $t5, end_while_first
				
				j while_first
				
			while_first:
				#i++
				addi $t3, $t3, 1
				j test_while_first
			
			end_while_first:
				j test_while_second
			
			test_while_second:
				# low + 1
				add $t5, $t0, 1
			
				#offset j no array
				mul $t2, $t4, 4
			
				# endereço arr[j]
				add $t2, $s1, $t2
			
				# vetor [j]
				l.s $f1, 0($t2)
				
				# vetor[j] > p
				c.le.s $f1, $f0 
				# se for verdadeiro, go to end_while_first
				bc1t end_while_second
				
				# j >= low + 1
				blt $t4, $t5, end_while_second
				
				j while_second
			
			while_second:
				# j--
				sub $t4, $t4, 1
				j test_while_second
			
			end_while_second:	
			
			# swap
			
			bge $t3, $t4, test_while_partition
			
			#offset i no array
			mul $t2, $t3, 4
			
			# endereço arr[i]
			add $t2, $s1, $t2
			
			# vetor [i]
			l.s $f1, 0($t2)
			
			#offset j no array
			mul $t5, $t4, 4
			
			# endereço arr[j]
			add $t5, $s1, $t5
			
			# vetor [j]
			l.s $f2, 0($t5)
			
			# swap
			s.s $f1, 0($t5)
			s.s $f2, 0($t2)
			
			j test_while_partition
		
		end_while_partition:
			#swap
			
			#offset low no array
			mul $t2, $t0, 4
			
			# endereço arr[low]
			add $t2, $s1, $t2
			
			# vetor [low]
			l.s $f1, 0($t2)
			
			#offset j no array
			mul $t5, $t4, 4
			
			# endereço arr[j]
			add $t5, $s1, $t5
			
			# vetor [j]
			l.s $f2, 0($t5)
			
			# swap
			s.s $f1, 0($t5)
			s.s $f2, 0($t2)
			
			#s4 = retorno de j atual no quicksort
			move $s4, $t4
			
			j end_partition
			
	end_partition:
		j chamar_quick_sort
		
	chamar_quick_sort:
		# Chama quicksort para low = low e high = pi ($s4) - 1
		
		# Empilha o low, high e endereço
		sub $sp, $sp, 16
		sw $s4, 12($sp)
		sw $t0, 8($sp)
		sw $t1, 4($sp)
		la $t2 chamar_quick_sort2
		sw $t2, 0($sp)
		
		add $s5, $s5, 1
		
		# Atualiza os valores locais
		add $t1, $s4, -1 # Atualiza o high (pi - 1)
		
		j quickSort
		
	
	chamar_quick_sort2:
		# Chama quicksort para low = pi ($s4) + 1 e high = high
		
		# Empilha o low, high e endereço
		sub $sp, $sp, 16
		sw $s4, 12($sp)
		sw $t0, 8($sp)
		sw $t1, 4($sp)
		la $t2 quick_sort_retorno
		sw $t2, 0($sp)
		
		add $s5, $s5, 1
		
		# Atualiza os valores locais
		add $t0, $s4, 1 # Atualiza o low (pi + 1)
		
		j quickSort
	
	quick_sort_retorno:
		# se a pilha está vazia, fim
		sub $s5, $s5, 1
		
		blez $s5, fimOrdena
		
		# retorno
		lw $t7, 0($sp)
		# high
		lw $t1, 4($sp)
		# low
		lw $t0, 8($sp)
		# pivo
		lw $s4, 12($sp)
		
		add $sp, $sp, 16
		 
		 jr $t7 
	
interpretarNumero:
	#f0, 10
	l.s $f0, dez

	# Número armazenado
	l.s $f1, zero
	
	# Decimal place
	l.s $f3, zeroPontoUm
	
	# 0.1 como float
	l.s $f6, zeroPontoUm
	
	# Signal number
	l.s $f5, um
	
	# Se por acaso nosso buffer parar de ler no meio do número, ao obter o próximo buffer, já começar interpretando os caracteres e não um novo numero
	# Pra isso, durante a leitura iremos guardar no s7 o endereço da instrução q ele deve retomar ao acabar os bytes de leitura
	la $s7, interpretarNumeroCaracter
	
	j interpretarNumeroCaracter
	
interpretarNumeroCaracter:
	# Após lermos todos os caracteres, procurar mais
	beqz $t2, lerBufferNumeros
	
	# Lê o byte atual de t0
	lb $t3, 0($t0),
	
	# Se o byte atual for igual newline, fim do número
	beq $t3, 10, fimNumero
	# Se tiver ponto, ler decimal
	beq $t3, 46, comecarDecimal
	# Se tiver menos, é negativo
	beq $t3, 45, negativoNumero
	
	# Subtrai 0 ASCII (48) para obter os números "normalizados"
	sub $t4, $t3, 48
	
	# $f2 deve conter o ascii em float
	
	beq $t4, 0, nZero
	beq $t4, 1, nUm
	beq $t4, 2, nDois
	beq $t4, 3, nTres
	beq $t4, 4, nQuatro
	beq $t4, 5, nCinco
	beq $t4, 6, nSeis
	beq $t4, 7, nSete
	beq $t4, 8, nOito
	beq $t4, 9, nNove
	j nInvalido
	
	nZero:
		l.s $f2, zero
		j nCalcula
	nUm:
		l.s $f2, um
		j nCalcula
	nDois:
		l.s $f2, dois
		j nCalcula
	nTres:
		l.s $f2, tres
		j nCalcula
	nQuatro:
		l.s $f2, quatro
		j nCalcula
	nCinco:
		l.s $f2, cinco
		j nCalcula
	nSeis:
		l.s $f2, seis
		j nCalcula
	nSete:
		l.s $f2, sete
		j nCalcula
	nOito:
		l.s $f2, oito
		j nCalcula
	nNove:
		l.s $f2, nove
		j nCalcula
	nInvalido:
		j nZero
	
	nCalcula:
	
	# Número = Número * 10 + ASCII
	mul.s $f1, $f1, $f0
	add.s $f1, $f1, $f2
	
	j proximoNumeroCaracter
	
proximoNumeroCaracter:
	# Próximo caracter
	addi $t0, $t0, 1
	# Menos um a ser lido
	addi $t2, $t2, -1
	jr $s7
	
comecarDecimal:
	# Próximo caracter
	addi $t0, $t0, 1
	# Menos um a ser lido
	addi $t2, $t2, -1
	la $s7, interpretarDecimal
	j interpretarDecimal
	
interpretarDecimal:
	# Após lermos todos os caracteres, procurar mais
	beqz $t2, lerBufferNumeros
	
	# Lê o byte atual de t0
	lb $t3, 0($t0),
	
	# Se o byte atual for igual newline, fim do número
	beq $t3, 10, fimNumero
	
	# Subtrai 0 ASCII (48) para obter os números "normalizados"
	sub $t4, $t3, 48
	
	# $f2 deve conter o ascii em float
	
	beq $t4, 0, nDZero
	beq $t4, 1, nDUm
	beq $t4, 2, nDDois
	beq $t4, 3, nDTres
	beq $t4, 4, nDQuatro
	beq $t4, 5, nDCinco
	beq $t4, 6, nDSeis
	beq $t4, 7, nDSete
	beq $t4, 8, nDOito
	beq $t4, 9, nDNove
	j nDInvalido
	
	nDZero:
		l.s $f2, zero
		j nDCalcula
	nDUm:
		l.s $f2, um
		j nDCalcula
	nDDois:
		l.s $f2, dois
		j nDCalcula
	nDTres:
		l.s $f2, tres
		j nDCalcula
	nDQuatro:
		l.s $f2, quatro
		j nDCalcula
	nDCinco:
		l.s $f2, cinco
		j nDCalcula
	nDSeis:
		l.s $f2, seis
		j nDCalcula
	nDSete:
		l.s $f2, sete
		j nDCalcula
	nDOito:
		l.s $f2, oito
		j nDCalcula
	nDNove:
		l.s $f2, nove
		j nDCalcula
	nDInvalido:
		j nDZero
	
	nDCalcula:
	
	# ASCII * decimal place
	mul.s $f4, $f3, $f2
	
	add.s $f1, $f1, $f4
	
	# Decimal place *= 0.1
	mul.s $f3, $f3, $f6
	
	# Próximo caracter
	addi $t0, $t0, 1
	# Menos um a ser lido
	addi $t2, $t2, -1
	jr $s7
	
fimNumero:
	# Número esta no f1
	
	# Multiplica por signal number ($f5) para alterar o sinal
	mul.s $f1, $f1, $f5
	
	mul $t5, $t1, 4
	add $t5, $t5, $s1
	
	# t3 agora tem o nosso endereço no vetor com base no indice
	
	# salva f1 no endereco t3
	s.s $f1, 0($t5)  

	# add +1 no indice do vetor
	addi $t1, $t1, 1
	
	la $s7, interpretarNumero
	j proximoNumeroCaracter
	
negativoNumero:
	l.s $f5, menosUm
	
	# Próximo caracter
	addi $t0, $t0, 1
	# Menos um a ser lido
	addi $t2, $t2, -1
	
	jr $s7
	
lerBufferNumeros:
	move $a0, $s0
	li $v0, 14
	la $a1, conteudoArquivo
	li $a2, 1024
	syscall
	
	la $t0, conteudoArquivo # ponteiro para os dados
	move $t2, $v0  # armazena t2 bytes a processar
	
	# Se t2 (numero de bytes lidos) for menor que nosso buffer (1024), quer dizer que não há mais nada a ser lido depois
	blez $t2, fimNumeros
	
	# Qual instrução ele deve voltar para continuar a iteração
	jr $s7
	
fimNumeros:
	# Número esta no f1
	
	# Multiplica por signal number ($f5) para alterar o sinal
	mul.s $f1, $f1, $f5
	
	mul $t5, $t1, 4
	add $t5, $t5, $s1
	
	# t3 agora tem o nosso endereço no vetor com base no indice
	
	# salva f1 no endereco t3
	s.s $f1, 0($t5)  

	# add +1 no indice do vetor
	addi $t1, $t1, 1
	
	j ordenacao
			
contarNL:
	# Após contarmos todos newlines desse buffer, verificar se há mais
	beqz $t2, lerBufferNL
	
	# Lê o byte atual de t0
	lb $t3, 0($t0),
	# Ascii para newline
	li $t4, 10
	
	# Se o byte atual for igual newline, incrementa NL
	beq $t3, $t4, incrementaNL
	
	j proximoNL
	
incrementaNL:
	addi $s2, $s2, 1
	j proximoNL
	
proximoNL:
	addi $t0, $t0, 1
	addi $t2, $t2, -1
	j contarNL
	
lerBufferNL:
	move $a0, $s0
	li $v0, 14
	la $a1, conteudoArquivo
	li $a2, 1024
	syscall
	
	move $s1, $v0
	
	la $t0, conteudoArquivo # ponteiro para os dados
	move $t2, $s1 # armazena t2 bytes a processar
	
	# Se t2 (numero de bytes lidos) for menor que nosso buffer (1024), quer dizer que não há mais nada a ser lido depois
	blez $t2, calcularVetor
	
	j contarNL
	
fecharArquivo:
	li $v0, 16
	move $a0, $s0
	syscall
	
	jr $ra

fecharPrograma:
	li $v0, 10
	syscall
	
erroAbrirArquivo:
	li $v0, 4
	la $a0, erroArquivoMessagem
	syscall
	
	j fecharPrograma

abrirArquivo:
	# Configurar abertura de arquivo
	li $v0, 13
	la $a0, localArquivo
	# Apenas leitura
	li $a1, 0
	syscall
	
	# Move de v0 para s0
	move $s0, $v0
	
	# Se s0 < 0, deu erro ao abrir o arquivo
	bltz $s0, erroAbrirArquivo
	
	# s0 agora contém o FileDescriptor
	
	# Voltar a função main após abrir
	jr $ra
