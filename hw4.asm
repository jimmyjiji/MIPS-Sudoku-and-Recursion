.text
.globl main

########################################
### MACROS USED ########################
.macro print_int(%string)
move $a0, %string
li $v0, 1
syscall 
.end_macro

.macro end
li $v0, 10
syscall
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
li $v0, 4
la $a0, %string
syscall
.end_macro

.macro print_space
li $v0, 4
la $a0,space
syscall
.end_macro

.macro print_line
li $v0, 4
la $a0, nextline
syscall
.end_macro

.macro board_value(%board, %row, %col)
li $t9, 9
mul $t9, $t9, %row
mflo $t9
add $t9, $t9, %col
add %board, %board, $t9
lb $t9, (%board)
move $v0, $t9
.end_macro

.macro mulby4(%reg)
li $t9, 4
mul %reg, %reg, $t9
mflo %reg
.end_macro

.macro divby4(%reg)
li $t9, 4
div %reg, $t9
mflo %reg
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
	
	
	la $a0, test
	la $a1, 1
	la $a2, 0
	la $a3, candidates
	jal constructCandidates
	#print_int($v0) 
	end
	
#
# Computes the Nth number of the Hofsadter Female Sequence
# public int F (int n)
#
F:
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
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
	la $s0, ($a0)
	print_string(solution)
	print_line
	li $t0, 0	# counter for i
	outerlooppSol:
	li $t1, 0	#counter for j
		innerlooppSol:
		lw $t2, ($s0)
		print_int($t2)
		print_space
		addi $t1, $t1, 1
		addi $s0, $s0, 4
		blt $t1, 9, innerlooppSol
	print_line
	addi $t0, $t0, 1	
	blt $t0, 9, outerlooppSol
	
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) gridSet (byte[][] board, int row, int col)
#
gridSet:
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
	move $v0, $t0
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int col)
#	
colSet:
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	li $t0, 0	#counter
	li $t1, 0	#loop
	la $s1, cSet
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
	move $v0, $t0
	
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) rowSet (byte[][] board, int row)
#		
rowSet:
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	li $t0, 0	#count 
	li $t1, 0	#loopcounter
	la $s1, rSet
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
	
	move $v0, $t0
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int row, int col)
#			
constructCandidates:
	
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	
	li $s0, 0 	#count 
	la $s5, ($ra)
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
	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	
	jr $ra

#
# sudoku solver function
# public (byte [], int) colSet (byte[][] board, int x, int y)
#	
sudoku:
	jr $ra


.data
solution: .asciiz "Solution:"
space: .asciiz " "
nextline: .asciiz "\n"
.align 2
test: 		.byte 1,2,0,4,5,6,7,8,9,
		      0,0,7,6,5,4,3,2,1,
		      0,4,6,8,4,2,2,3,1,
		      0,2,1,4,5,2,3,4,7,
		      0,0,4,2,4,3,1,4,3,
		      5,6,2,3,2,1,3,3,2,
		      4,2,0,6,2,3,4,1,6,
		      7,3,5,4,7,3,5,7,8,
		      0,3,2,4,5,3,6,3,3
		      
rSet: 		.byte 0:9
cSet: 		.byte 0:9
gSet: 		.byte 0:9
.align 2
candidates:	.byte 0:9
FINISHED: 	.byte 0
