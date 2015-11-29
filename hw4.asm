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
li $t8, 4
mul $t9, $t9, %row
mflo $t9
add $t9, $t9, %col
mul $t9, $t9, $t8
mflo $t9
add %board, %board, $t9
lw $t9, (%board)
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
#########################################
main: 
	la $a0, testprintsol
	la $a1, 1
	jal colSet
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
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int col)
#	
colSet:
	li $t0, 0	#counter
	li $t1, 0	#loop
	la $s1, cSet
	colSetLoop:
		move $s0, $a0
		board_value($s0, $t0, $a1)
		beqz $v0, nextcolsetloop
		
		la $s2, ($s1)
		mulby4($t0)
		add $s2, $s2, $t0
		sw $v0, ($s2)
		divby4($t0)
		addi $t0, $t0, 1
		
		nextcolsetloop:
		addi $t1, $t1, 1
		blt $t1, 9, colSetLoop
	
	move $v0, $t0
	
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) rowSet (byte[][] board, int row)
#		
rowSet:
	li $t0, 0	#count 
	li $t1, 0	#loopcounter
	la $s1, rSet
	rowSetLoop:
		move $s0, $a0
		board_value($s0, $a1, $t0)
		beqz $v0, nextrowsetloop
		
		la $s2, ($s1)
		mulby4($t0)
		add $s2, $s2, $t0
		sw $v0, ($s2)
		divby4($t0)
		addi $t0, $t0, 1
		
		nextrowsetloop:
		addi $t1, $t1, 1
		blt $t1, 9, rowSetLoop
	
	move $v0, $t0
	jr $ra

#
# Helper function for solving sudoku
# public (byte [], int) colSet (byte[][] board, int row, int col)
#			
constructCandidates:
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
testprintsol: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 1
.align 2
rSet: 		.byte 0:9
.align 2
cSet: 		.byte 0:9
.align 2
gSet: 		.byte 0:9
FINISHED: 	.byte 0
