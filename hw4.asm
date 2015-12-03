.text
.globl main

########################################
### MACROS USED ########################
.macro print_int(%string)
move $t9, $a0
move $a0, %string
li $v0, 1
syscall 
move $a0, $t9
.end_macro

.macro end
li $v0, 10
syscall
.end_macro

.macro printf (%int) 
move $t9, $a0
li $v0, 4
la $a0, fprint
syscall

move $a0, $t9

li $v0, 1
move $a0, %int
syscall

print_line
.end_macro

.macro printm (%int)
move $t9, $a0
li $v0, 4
la $a0, mprint
syscall 

move $a0, $t9

li $v0, 1
move $a0, %int
syscall 

print_line
.end_macro


.macro clearSet(%set) 
sb $0, 0(%set)
sb $0, 1(%set)
sb $0, 2(%set)
sb $0, 3(%set)
sb $0, 4(%set)
sb $0, 5(%set)
sb $0, 6(%set)
sb $0, 7(%set)
sb $0, 8(%set)
.end_macro

.macro swap(%reg1, %reg2)
move $t0, %reg1
move %reg1, %reg2
move %reg2, $t0
.end_macro

.macro loadfromstacktak
lw $a0, 4($sp)
lw $a1, 8($sp)
lw $a2, 12($sp)
.end_macro



.macro print_string(%string)
move $t9, $a0
li $v0, 4
la $a0, %string
syscall
move $a0, $t9
.end_macro

.macro print_space
move $t9, $a0
li $v0, 4
la $a0, space
syscall
move $a0, $t9
.end_macro

.macro print_line
move $t9, $a0
li $v0, 4
la $a0, nextline
syscall
move $a0, $t9
.end_macro

.macro board_value(%board, %row, %col)
li $t9, 9
la $t8, (%board)
mul $t9, $t9, %row
mflo $t9
add $t9, $t9, %col
add %board, %board, $t9
lb $t9, (%board)
move $v0, $t9
move %board, $t8
.end_macro

.macro setboardvalue(%board, %row, %col, %value)
li $t9, 9
la $t8, (%board)
mul $t9, $t9, %row
mflo $t9
add $t9, $t9, %col
add %board, %board, $t9
sb %value, (%board)
move %board, $t8
.end_macro

.macro getcandidatearrayvalue(%candidatearray, %int) 
la $t9, (%candidatearray)
add %candidatearray, %candidatearray, %int
lb $v0, (%candidatearray)
move %candidatearray, $t9
.end_macro

.macro searchsets(%address, %object)
li $t8, 0
loopsearch:
lb $t9, (%address)
beq $t9, %object, truesearch
addi %address, %address, 1
addi $t8, $t8, 1
blt $t8, 9, loopsearch
j falsesearch

truesearch:
li $v0, 1
j endsearch

falsesearch:
li $v0, 0
j endsearch

endsearch:
.end_macro

#########################################
main: 
	
	
	la $a0, 5
	jal F
	
	end
	
#
# Computes the Nth number of the Hofsadter Female Sequence
# public int F (int n)
#
F:
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	printf($a0)
	bnez $a0, elseF
	li $v0, 1
	addi $sp, $sp, 8
	jr $ra
elseF:

	addi $a0, $a0, -1
	jal F
	move $a0, $v0
	jal M 
	lw $t0, 0($sp)
	sub $v0, $t0, $v0
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	

#
# Computes the Nth number of the Hofsadter Male Sequence
# public int M (int n)
#	
M:
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	printm($a0)
	bnez $a0, elseM
	li $v0, 0
	addi $sp, $sp, 8
	jr $ra
elseM:

	addi $a0, $a0, -1
	jal M
	move $a0, $v0
	jal F 
	lw $t0, 0($sp)
	sub $v0, $t0, $v0
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

#
# Tak Function
# public int tak (int x, int y, int z)
#
tak:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	blt $a1, $a0, elseTak
	move $v0, $a2 
	addi $sp, $sp, 16
	jr $ra

elseTak:
	loadfromstacktak
	addi $a0, $a0, -1
	jal tak
	move $s0, $v0 
	loadfromstacktak
	swap($a0, $a1)
	swap($a1, $a2)
	addi $a0, $a0, -1
	jal tak
	move $s1, $v0
	loadfromstacktak
	swap($a0, $a2)
	swap($a1, $a2)
	addi $a0, $a0, -1
	jal tak
	move $s2, $v0 
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal tak
	lw $ra 0($sp)
	addi $sp, $sp, 16
	jr $ra 	
#
# Helper function for solving sudoku
# public boolean isSolution (int row, int col)
#
isSolution:
	beq $a0, 8, equaleight 
	j false
equaleight:
	beq $a0, $a1, true
	j false
true:
	li $v0, 1
	jr $ra
false:
	li $v0, 0
	jr $ra

#
# Helper function for solving sudoku
# public void printSolution (byte[][] board)
#
printSolution:
	addi $sp, $sp, -16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	la $s3, ($a0)
	print_string(solution)
	print_line
	li $s0, 0	# counter for i
	outerlooppSol:
	li $s1, 0	#counter for j
		innerlooppSol:
		lb $s2, ($s3)
		print_int($s2)
		print_space
		addi $s1, $s1, 1
		addi $s3, $s3, 1
		blt $s1, 9, innerlooppSol
	print_line
	addi $s0, $s0, 1	
	blt $s0, 9, outerlooppSol
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) gridSet (byte[][] board, int row, int col)
#
gridSet:
	addi $sp, $sp, -16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	
	
	li $t0, 3
	div $a1, $t0
	mflo $a1	#divide by 3
	div $a2, $t0
	mflo $a2	#divide by 3
	
	mul $a1, $a1, $t0
	mflo $a1	#multiply by 3 stored in a1
	mul $a2, $a2, $t0
	mflo $a2	#multiply by 3 stored in a2
	
	li $t0, 0	#count 
	addi $t1, $a1, 3	#loop counter 
	addi $t2, $a2, 3	#loop counter 
	la $s1, gSet
	clearSet($s1)
	move $s3, $a2		#original row counter 
	gridouterloop:
		
		innergridloop:
		move $s0, $a0
		board_value($s0, $a1, $a2)
		beqz $v0, nextinnergridloop
		
		la $s2, ($s1)
		#mulby4($t0)
		add $s2, $s2, $t0
		sb $v0, ($s2)
		#divby4($t0)
		addi $t0, $t0, 1
		addi $a2, $a2, 1
		blt $a2, $t2, innergridloop
		j nextouterloop
		
		nextinnergridloop:
		addi $a2, $a2, 1
		bge  $a2, $t2, nextouterloop
		j innergridloop
	
	nextouterloop:
	addi $a1, $a1, 1
	move $a2, $s3	
	blt $a1, $t1, gridouterloop
	
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	move $v0, $t0
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int col)
#	
colSet:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	li $t0, 0	#counter
	li $t1, 0	#loop
	la $s1, cSet
	clearSet($s1)
	colSetLoop:
		move $s0, $a0
		board_value($s0, $t1, $a1)
		beqz $v0, nextcolsetloop
		
		la $s2, ($s1)
		#mulby4($t0)
		add $s2, $s2, $t0
		sb $v0, ($s2)
		#divby4($t0)
		addi $t0, $t0, 1
		
		nextcolsetloop:
		addi $t1, $t1, 1
		blt $t1, 9, colSetLoop
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	move $v0, $t0
	
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) rowSet (byte[][] board, int row)
#		
rowSet:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	
	
	li $t0, 0	#count 
	li $t1, 0	#loopcounter
	la $s1, rSet
	clearSet($s1)
	rowSetLoop:
		move $s0, $a0
		board_value($s0, $a1, $t1)
		beqz $v0, nextrowsetloop
		
		la $s2, ($s1)
		#mulby4($t0)
		add $s2, $s2, $t0
		sb $v0, ($s2)
		#divby4($t0)
		addi $t0, $t0, 1
		
		nextrowsetloop:
		addi $t1, $t1, 1
		blt $t1, 9, rowSetLoop
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	move $v0, $t0
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int row, int col)
#			
constructCandidates:
	addi $sp, $sp, -28
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	li $s0, 0 	#count 
	la $s5, ($ra)
	move $s6, $a3
	jal rowSet
	move $s1, $v0	#rlength
	
	swap($a1, $a2)
	jal colSet 
	move $s2, $v0	#clength
	
	swap ($a1, $a2)
	jal gridSet
	move $s3, $v0	#glength
	
	li $t0, 1	#loop counter or i
	
	candidateloop:
		la $s4, rSet
		searchsets($s4, $t0)
		beq $v0, 1, nextcandidateloop
		
		la $s4, cSet
		searchsets($s4, $t0)
		beq $v0, 1, nextcandidateloop
		
		la $s4, gSet
		searchsets($s4, $t0)
		beq $v0, 1, nextcandidateloop
		
		addtocount:
		sb $t0, ($a3)
		addi $s0, $s0, 1
		addi $a3, $a3, 1
		
		nextcandidateloop:
		addi $t0, $t0, 1
		ble $t0, 9, candidateloop
	
		
	move $v0, $s0
	move $ra, $s5
	move $a3, $s6
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra

#
# sudoku solver function
# public (byte [], int) colSet (byte[][] board, int x, int y)
#
.macro loadfromstacksud
lw $s3, 44($sp)
lw $s1, 16($sp)
lw $s2, 20($sp)
lw $t0, 56($sp)
lw $t1, 60($sp)
la $fp, 40($sp)
.end_macro

.macro storetostacksud
addi $sp, $sp, -32
li $t9, 0
sw $t9, 0($sp)
sw $t9, 4($sp)
sw $t9, 8($sp)
sw $ra, 12($sp)
sw $a1, 16($sp)
sw $a2, 20($sp)
sw $t9, 24($sp)
sw $t9, 28($sp)
.end_macro

.macro printbeginningsud(%row, %col)
li $v0, 4
la $a0, sudoku1
syscall 

li $v0, 1
move $a0, %row
syscall 

li $v0, 4
la $a0, sudoku2
syscall

li $v0, 1
move $a0, %col
syscall

li $v0, 4
la $a0, sudoku3
syscall

print_line
.end_macro
sudoku:
	
	storetostacksud
	move $s0, $a0		#board address
	move $s1, $a1		#board x
	move $s2, $a2		#board y
	move $s3, $ra 
	
	printbeginningsud($s1, $s2)
	
	move $a0, $s1
	move $a1, $s2
	jal isSolution
	beq $v0, 1, endsudoku	#if it is a solution end the method
	
	addi $s2, $s2, 1
	bgt $s2, 8, firstcolnextrow
	j nextcolsamerow
	
		firstcolnextrow:
		addi $s1, $s1, 1
		li $s2, 0
	
	nextcolsamerow:
	board_value($s0, $s1, $s2)
	beqz $v0, checkcandidate
	j keepsolving
	
		keepsolving:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		jal sudoku
		loadfromstacksud
		j return
		
		checkcandidate:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		la $fp, 8($sp)
		move $a3, $fp
		jal constructCandidates
		
		li $t0, 0	#c
		move $t1, $v0	#candidate length
		sw $t0, 24($sp)
		sw $t1, 28($sp)
		
		checker:
		beqz $t1, nocandidates
		blt $t0, $t1, candidateloopsud
		bge $t0, $t1, return
		
		candidateloopsud:
			getcandidatearrayvalue($fp, $t0)
			setboardvalue($s0, $s1, $s2, $v0)
	
			move $a0, $s0
			move $a1, $s1
			move $a2, $s2
			jal sudoku
			loadfromstacksud
			
			setboardvalue($s0, $s1, $s2, $0)
			
			
			lb $t5, FINISHED
			beq $t5, 1, return
			j nextcandidateloopsud
			
			returnzero:
			jr $s3
			
			nocandidates:
			beq $t0, 0, returnzero
			j return
			
			return:
			addi $sp, $sp, 32
			jr $s3
			
			
				
			nextcandidateloopsud:
			addi $t0, $t0, 1
			sw $t0, 56($sp)
			j checker
			
			
	
	
	endsudoku:		#print out board
	move $a0, $s0
	jal printSolution
	li $t0, 1
	sb $t0, FINISHED
	addi $sp, $sp, 32
	lw $s3, 44($sp)
	jr $s3


.data
solution: .asciiz "Solution:"
space: .asciiz " "
sudoku1: .asciiz "Sudoku [ "
sudoku2: .asciiz " ] [ "
sudoku3: .asciiz " ] "
nextline: .asciiz "\n"
fprint: .asciiz "F: "
mprint: .asciiz "M: "

.align 2
test: 	.byte 	0,0,6,8,0,0,5,0,0,	
 		0,8,0,0,6,1,0,2,0,	
		5,0,0,0,3,0,0,0,7,	 
		0,4,0,3,1,7,0,0,5,	
		0,9,8,4,0,6,3,7,0,	 
		7,0,0,2,9,8,0,4,0,	
		8,0,0,0,4,0,0,0,9,	
		0,3,0,6,2,0,0,1,0,	
		0,0,5,0,0,9,6,0,0
.align 2
test2: .byte 	9, 0, 6, 0, 7, 0, 4, 0, 3,
		0, 0, 0, 4, 0, 0, 2, 0, 0,
		0, 7, 0, 0, 2, 3, 0, 1, 0,
		5, 0, 0, 0, 0, 0, 1, 0, 4,
		0, 4, 0, 2, 0, 8, 0, 6, 7,
		0, 0, 3, 0, 0, 0, 0, 0, 5,
		0, 3, 0, 7, 0, 0, 0, 5, 1,
		0, 0, 7, 0, 0, 5, 0, 0, 2,
		4, 0, 5, 0, 1, 0, 7, 0, 8
.align 2
rSet: 		.byte 0:9
.align 2
cSet: 		.byte 0:9
.align 2
gSet: 		.byte 0:9
.align 2
FINISHED: 	.byte 0
