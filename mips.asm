.data
	localArquivo: .asciiz "C:/Users/offic/Downloads/numeros.txt"
	conteudoArquivo: .space 1024
	erroArquivoMessagem: .asciiz "Erro ao abrir arquivo"
	newLine: .asciiz "\n"
	zeroPontoUm: .float 0.1
	dez: .float 10.0
	zero: .float 0.0
	um: .float 1.0
	deuBom: .asciiz "ola deu bom"
	menosUm: .float -1.0
	algoritmoOrdenacao: .word 1 #1 para insertion, 2 para quick sort

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
	beq $t1, 2, quickSort
	
	j fecharPrograma
	
printarVetor:
	li $t2, 0 # iterator i
	
	test_for_print:
		blt $t2, $s2, for_print
		j failed_for_print
		
	for_print:
		#offset: $t2
		mul $t3, $t2, 4
		#aqui t2 vira endereço base (s1 + offset)
		add $t3, $s1, $t3
		
		#key ($f12)
		l.s $f12, 0($t3)   
		
		li $v0, 2
		syscall
		jal breakLine
		
		add $t2, $t2, 1
		
		j test_for_print
	
	failed_for_print:
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
	li $t0 0 # 0
	li $t1 $s2 # tamanho vetor
	j quickSort
	
quickSort:
	# Basicamente precisamos criar uma pilha de execução dos QuickSorts.
	# Nessa pilha iremos guardar cada chamada de execução do Quicksort, incluindo informações como (low, high e PC)
	# A ideia é que a cada "chamada recursiva" os valores atuais do Quicksort e a instrução chamada posteriormente sejam empilhados para a execução da recursão executada
	# E ao término dessa recursão, a pilha seja desempilhada assim retornando a chamada anterior junto com a instrução posterior a recursão para prosseguir com o código
	# Devemos alocar uma pilha e tratar as chamadas recursivas que usarão essa pilha
	
	#$t0: low, $t1: high
	
	partition:
		#offset: $t2
		mul $t2, $t0, 4
		
		#aqui t2 vira endereço base (s1 + offset)
		add $t2, $s1, $t2
		
		# vetor[low]
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
			
		
		end_while_partition:
			
	j fimOrdena
	
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
	
	# Carrega o t4 (ASCII convertido número normalizado) para float
	mtc1 $t4, $f2
	cvt.s.w $f2, $f2
	
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
	
	# Carrega o t4 (ASCII convertido número normalizado) para float
	mtc1 $t4, $f2
	cvt.s.w $f2, $f2
	
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
