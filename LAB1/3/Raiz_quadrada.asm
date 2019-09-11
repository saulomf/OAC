.data
a: .float 5.0
b: .float 2.0
c: .float 5.0

ZERO: .float 0.0
UM: .float 1.0
DOIS: .float 2.0
QUATRO: .float 4.0


R1: .asciiz "\nR(1)="
R2: .asciiz "\nR(2)="
mais: .asciiz " + "
menos: .asciiz " - "
complexo: .asciiz " i "


.text
main:			//#####################  MAIN  ####################
//CARREGANDO A B C NA PILHA

ADDI X8, XZR, #6
SVC 0
STURS S0, [X28,-4]
SUBI X28, X28, #4

ADDI X8, XZR, #6
SVC 0
STURS S0, [X28,-4]
SUBI X28, X28, #4

ADDI X8, XZR, #6
SVC 0
STURS S0, [X28,-4]
SUBI X28, X28, #4

ADDI X10, XZR, 0	//ICICIANDO O CONTADOR DE CPI

BL baskara
//Agora temos em X1 = 1 [raizes reais] e X1 = 2 [raizes complexas]
//para x1 = 1 pilha com valores das raizes 1 e 2
//para x1 = 2 pilha com valores da partes real e imaginaria [complexa conjugada]

BL show


B fim_programa


baskara:		//#####################  BASKARA  ####################

LDURS S5, [X28,8]//A carregando da pilha
LDURS S6, [X28,4]//B
LDURS S7, [X28,0]//C


//DELTA
FMULS S4, S6, S6//B^2

LDA X1, QUATRO //QUATRO EM FLOAT PARA 4*A*C
LDURS S12, [X1,0]

FMULS S12, S12, S5//4*A
FMULS S12, S12, S7//4*A*C
FSUBS S12, S4, S12//DELTA  B^2-4AC

LDA X1, ZERO 		//ZERO EM FLOAT
LDURS S0, [X1,0]

FCMPS S12, S0 		//COMPARANDO DELTA COM ZERO PARA BRANCH

ADDI X10, X10, 45 	//CONTADOR DE CPI

B.EQ UMARAIZ
B.MI RAIZ_COMPLEXA 	//PULO CONDICIONAL
B RAIZ_REAL        	//PULO INCONDICIONAL

BR X30

RAIZ_COMPLEXA:		//#####################  RAIZ COMPLEXA  ########################################
//salva a raiz compleXa na pilha
//no formato Real -> Imaginario [sabemos que é conjugado]

FSUBS S12, S13, S12	//DELTA ==== -DELTA

STUR X30, [X28,-4]	//SALVANDO O ENDERÇO LINKADO NO BRANCH
SUBI X28, X28, #4

ADDI X10, X10, 12	//CONTADOR CPI

BL SQRT //retorna raiz de delta positivo em S12

LDUR X30, [X28,0]	//RETORNANDO O ENDERÇO LINKADO NO BRANCH
ADDI X28, X28, #4

LDA X1, ZERO 		//ZERO EM FLOAT
LDURS S0, [X1,0] 	//S0=0.0

//S5 = A  S6 = B  S7 = C

FSUBS S6, S0, S6	//B = - B
FMULS S5, S5, S2	//A = 2*A

FDIVS S6, S6, S5	//-B/(2*A)
FDIVS S7, S12, S5	//SQRT(DETLTA)/(2*A)

			//AGORA TEMOS A PARTE REAL E A PARTE IMAGINARIA [CONJUGADA] em S6 REAL E EM S7 IMAGINARIA

STURS S6, [X28,-4]	//store na parte real
SUBI X28, X28, #4
STURS S7, [X28,-4]	//store na parte imaginaria
SUBI X28, X28, #4


ADDI X1, XZR, 2		//AVISANDO QUE SAO RAIZES COMPLEXAS CONJUGADAS
ADDI X10, X10, 50	//CONTADOR CPI
BR X30 //RETORNO PRA MAIN


RAIZ_REAL:		//#####################  RAIS REAL  ##################################

STUR X30, [X28,-4]	//SALVANDO O ENDERÇO LINKADO NO BRANCH
SUBI X28, X28, #4

ADDI X10, X10, 2 	//CONTADOR CPI
BL SQRT //retorna raiz de delta positivo em S12

LDUR X30, [X28,0]	//RETORNANDO O ENDERÇO LINKADO NO BRANCH
ADDI X28, X28, #4

LDA X1, ZERO 		//ZERO EM FLOAT
LDURS S0, [X1,0] 	//S0=0.0

FSUBS S6, S0, S6	//B = - B
FMULS S5, S5, S2	//A = 2*A

FDIVS S6, S6, S5	//-B/(2*A)
FDIVS S7, S12, S5	//SQRT(DETLTA)/(2*A)

FADDS S8, S6, S7	//RAIZ 1 
FSUBS S9, S6, S7	//RAIZ 2 


STURS S8, [X28,-4]	//store RAIZ 1
SUBI X28, X28, #4
STURS S9, [X28,-4]	//store RAIZ 2
SUBI X28, X28, #4

ADDI X1, XZR, 1		//AVISANDO QUE SÃO RAIZES REAIS
ADDI X10, X10, 68 	//CONTADOR CPI
BR X30 //RETORNO PRA MAIN

UMARAIZ:
STUR X30, [X28,-4]	//SALVANDO O ENDERÇO LINKADO NO BRANCH
SUBI X28, X28, #4

ADDI X10, X10, 2 	//CONTADOR CPI
BL SQRT //retorna raiz de delta positivo em S12

LDUR X30, [X28,0]	//RETORNANDO O ENDERÇO LINKADO NO BRANCH
ADDI X28, X28, #4

LDA X1, ZERO 		//ZERO EM FLOAT
LDURS S0, [X1,0] 	//S0=0.0

FSUBS S6, S0, S6	//B = - B
FMULS S5, S5, S2	//A = 2*A

FDIVS S6, S6, S5	//-B/(2*A)

FADDS S8, S6, S7	//RAIZ 1 


STURS S6, [X28,-4]	//store RAIZ 1
SUBI X28, X28, #4


ADDI X1, XZR, 0		//AVISANDO QUE SÃO RAIZES REAIS
ADDI X10, X10, 68 	//CONTADOR CPI
BR X30 //RETORNO PRA MAIN


SQRT:			//#####################  SQUARE ROOT  ##################################
//SQRT(S12)->S12	
//algoritmo para encontrar a raiz quadrada de S12 e retornar em S12
//Aproximações feitas reduzindo pela metade a margem de aproximação
//e testando seu valor intermediário Temp*Temp == num ?? 
	
	LDA X1, DOIS 		//DOIS EM FLOAT
	LDURS S2, [X1,0] 	//S2=2.0
	
	LDA X1, UM 		//UM EM FLOAT
	LDURS S0, [X1,0]
	FCMPS S12, S0		//se delta = 1 , retorna ele mesmo
	
	ADDI X10, X10, 5 	//CONTADOR CPI
	B.EQ RETURN1 
	
	LDA X1, ZERO 		//ZERO EM FLOAT
	LDURS S13, [X1,0] 	//S13 = lower_bound=0
	FADDS S14, S12, S13 	//S14 = upper_bound=num
	LDURS S15, [X1,0] 	//S15 = temp=0
	
	LDA X1, ZERO 		//ZERO EM FLOAT
	LDURS S0, [X1,0] 	//S0=0.0
	
	
	ADDI X2, XZR, 30 	//contador para loop
	ADDI X10, X10, 16 	//CONTADOR CPI
	loop1:
		//S15 = temp = (lower_bound+upper_bound)/2;
		FADDS S15, S13, S14
		FDIVS S15, S15, S2 
		
		//IF(temp*temp==num){ RETURN TEMP }
		FMULS S16, S15, S15
		FSUBS S16, S16, S12	// fazendo temp*temp - num  e testando se é menor, maior ou igual a zero
		FCMPS S16, S0
		ADDI X10, X10, 42 	//CONTADOR CPI
		B.EQ RETURN		// se encontrou a raiz, sai da função e retorna a raiz
		
		
		B.MI  LESS		// se é menor que zero então coloca esse resultado no lower_bound
		FADDS S14, S0, S15//upper_bound = temp
		
		B GRATHER
		LESS:
		FADDS S13, S0, S15//lower_bound = temp
		
		GRATHER:
		
		SUBI X2, X2, 1		//andando com o contador X2--
		SUBS XZR, X2, XZR
		ADDI X10, X10, 6 	//CONTADOR CPI
		B.GT loop1
	//END LOOP1
	
	RETURN:
	FADDS S12, S0, S15 	//S12 = TEMP   ARPOXIMAÇAO DA RAIZ
	ADDI X10, X10, 11 	//CONTADOR CPI
	BR X30			// volta pro BL 
	RETURN1:
	ADDI X10, X10, 1 	//CONTADOR CPI
	BR X30
	
show:			//#####################  SHOW  ##################################
//Agora temos em X1 = 1 [raizes reais] e X1 = 2 [raizes complexas]
//para x1 = 1 pilha com valores das raizes 1 e 2
//para x1 = 2 pilha com valores da partes real e imaginaria [complexa conjugada]
	
	//carregar as raizes R1 e R2 ou partes da raiz complexa conjugada
	
	LDURS S1, [X28, 4]	//raiz 1 ou parte real
	LDURS S2, [X28, 0]	// raiz 2 ou parte imaginaria
	ADDI X28, X28, 8
	
	SUBIS XZR, X1, 1
	B.EQ imprime_real
	B.MI imprime_uma_raiz
	B imprime_complexo
	
	imprime_real:
		ADDI X8, XZR, #4
		LDA X7, R1 
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S1, S0 
		SVC 0 
		ADDI X8, XZR, #4
		LDA X7, R2
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S2, S0 
		SVC 0 
		
		BR X30
	
	imprime_complexo:
		// imprimindo a parte real com R1
		ADDI X8, XZR, #4
		LDA X7, R1 
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S1, S0 
		SVC 0 
		// imprimindo parte complexa
		ADDI X8, XZR, #4
		LDA X7, mais
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S2, S0 
		SVC 0 
		ADDI X8, XZR, #4
		LDA X7, complexo
		SVC 0 
		
		// imprimindo a parte real com R2
		ADDI X8, XZR, #4
		LDA X7, R1 
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S1, S0 
		SVC 0 
		// imprimindo parte complexa
		ADDI X8, XZR, #4
		LDA X7, menos
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S2, S0 
		SVC 0 
		ADDI X8, XZR, #4
		LDA X7, complexo
		SVC 0
		
		BR X30
		
		
	imprime_uma_raiz:
		ADDI X8, XZR, #4
		LDA X7, R1 
		SVC 0 
		ADDI X8, XZR, #2
		FADDS S12, S2, S0 
		SVC 0 
		
		BR X30

	
fim_programa:		//#####################  FIM DO PROGRAMA  ##################################
	ADDI X8, XZR, 10
	SVC 0
	
	
	
