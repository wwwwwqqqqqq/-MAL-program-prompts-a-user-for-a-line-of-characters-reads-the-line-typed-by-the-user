#CSI 333. Programming at the Hardware-Software Interface
#Spring 2019
#Li Lin
#ZR1702
#2017215126
#Qin Weiwei

	.data
line1: .asciiz "Enter the line? "
line2: .asciiz "No. of integers: "
line3: .asciiz "Line contains only white space characters."
line4: .asciiz "Maximum number of 1’s in the binary representation: "
line5: .asciiz "Integers of maximum number of 1’s in the binary representation: "
newline: .asciiz "\n"

input: .space 80  #array of bytes of size 80
integers: .word 0:40  #array of words of size 40
array: .word 0:40
max: .word 0:40
stack: .byte 0:80

	.text
main:
		#output to input
    		la $a0,line1 	
    		li $v0,4  #use $v0 in value of 4
    		syscall

    		#read the input store the value in input
    		la $a0,input
    		li $a1,80
    		li $v0,8  #use $v0 in value of 8
    		syscall
   
    		#put the array in to the stack
    		la $s0,input
    		addi $t0,$0,1		
    		addi $t1,$0,'0'
    		addi $t2,$0,'\n'	
   		addi $t3,$0,'\t'
    		addi $t4,$0,' '
    		addi $t5,$0,9	

#subroutine 1: check empty line,check if input is all white-spaces, if so, the program terminates
checkempty:
		lb $s1,0($s0)  #load the byte from input as C
		addi $s0,$s0,1
    		beq $s1,$t2,checkempty	#if '\n'   branch
    		beq $s1,$t3,checkempty	#if '\t'  branch
    		beq $s1,$t4,checkempty	#if ' '  branch
    		beq $s1,$0,empty
    		
    		#blt $s1,$t0,step1
    		#bge $s1,$t5,step1
    
#subroutine 2: construct integers
construct:
    		la $s0,input
    		la $t7,stack
    		la $t8,integers
    
    		move $a2,$0
    		sw $ra,0($sp)
    		addi $sp,$sp,-4  #into the stack
    		
    	step1:
    		lb $s1,0($s0)  #load the first/next byte from input as C 
    		addi $s0,$s0,1
         	beq $s1,$0,step19  #if C is the end of the line, goto step 19
    
    		#if C is not a digit goto step 1
          	sub $s4,$s1,$t1
          	slt $t6,$s4,$0
          	beq $t6,$t0,step1  
          	slt $t6,$t5,$s4
          	beq $t6,$t0,step1
    
          	li $s2,0  #E = 0 to count number of digits of an integer number
    
   	step5:
          	sub $s1,$s1,48  #C = C - 48 48 is the ASCII code for '0', the subtraction is to get the actual value
          	addi $s2,$s2,1  #E = E + 1
          	sb $s1,0($t7)  #push C
          	addi $t7,$t7,1
    
          	lb $s1,0($s0)  #load the next byte from input as C
          	addi $s0,$s0,1
    
          	sub $s4,$s1,$t1
          	slt $t6,$s4,$0
          	beq $t6,$t0,step10
          	slt $a3,$t5,$s4
          	beq $a3,$t0,step10
    
    		#if C is a digit then goto step 5
          	j step5
    
    	step10:
    		#sum = 0, P = 1, R = 10  P is to control digit's placement, ones, tens, ...
          	sub $s0,$s0,1  
          	li $s3,0  #sum = 0
          	li $s5,1  #P = 1
          	li $s6,10  #R = 10
    
    	step11:
          	beq $s2,$0,step17  #if E == 0, goto step 17
    
    		#E = E - 1 
          	addi $s2,$s2,-1
          	
          	#pop D get the digit from stack
          	addi $t7,$t7,-1
          	lbu $v1,0($t7)
          	mul $a0,$v1,$s5
    
          	addu $s3,$s3,$a0  #sum = sum + D * P
          	mul $s5,$s5,$s6  #P = P * R
          	j step11  #goto step 11
    
    	step17:
          	sw $s3,0($t8)  #save sum in integer
          	addi $t8,$t8,4
          	j count
          	j step1  #goto step 1  get ready for the digits of the next integer
          
    	step19:
          	li $t9,-1  #save -1 in integers  indicating the end of numbers, will be useful in the coming subroutines
          	sw $t9,0($t8)
    
          	lw $ra,4($sp)
          	addi $sp,$sp,4  #pop the stack
    
          	jal printnum
          	jal printmaxnum
          	jal printmax
          	j end
    
    	count:
          	addi $a2,$a2,1
          	j step1

#subroutine 3, to count and print number of integers, here is 5 
printnum:
    		#output how many numbers of input
    		la $a0,line2
    		li $v0,4  #use $v0 in value of 4
   		syscall
    
    		move $a0,$a2
  	  	li $v0,1
   	 	syscall
  	 
    		la $a0,newline
   	 	li $v0,4
    		syscall
    
    		jr $ra
   		 
#subroutine 4: print the maximum number of '1' bits
printmaxnum:
   	 	li $t0,1
    		move $a3,$0
   	 	move $s4,$0
   	 	li $s3,-1
   	 	la $s0,integers
    		la $s5,array
   	 
	get:
    		lw $s1,0($s0)
    		beq $s1,$s3,printline4
    		addi $s0,$s0,4
   
	change:
    		beq $s1,$0,save
    		and $s2,$s1,1
    		beq $s2,$t0,count2
    
	shift:
    		srl $s1,$s1,1
    		j change
    
	save:
    		sw $a3,0($s5)
    		addi $s5,$s5,4
    		slt $t6,$s4,$a3
    		beq $t6,$t0,end2
    		beq $s4,$a3,end2
    		li $a3,0
    		beq $t6,$0,get
    
	end2:
    		move $s4,$a3
    		li $a3,0
    		j get
    
	printline4:
    		la $a0,line4
    		li $v0,4
    		syscall
    
    		move $a0,$s4
    		li $v0,1
    		syscall
    
    		la $a0,newline
    		li $v0,4
    		syscall
    
    		jr $ra
    
	count2:
    		addi $a3,$a3,1
    		j shift
    
#subroutine 5: print integers with max. number of '1' bits
printmax:
    		la $s0,integers
    		la $s1,array
    		la $s2,max
    		move $t0,$0	
    		move $t3,$0	
    		li $t5,-1
		
	load2:
    		lw $s3,0($s0)	
    		lw $s4,0($s1)	
    		beq $s3,$t5,print 
    
    		addi $s0,$s0,4
    		addi $s1,$s1,4		
    											
    		slt $t1,$t0,$s4
    		li $t2,1
    
    		beq $t2,$t1,change2
    		beq $t0,$s4,getmax	
    
   		j load2
		
	change2:
    		move $t0,$s4	
    		beq $t3,$0,getmax
    		mul $t4,$t3,4
    		sub $s2,$s2,$t4	
    		li $t3,0
	
	getmax:
    		sw $s3,0($s2)	
    		addi $s2,$s2,4
    		addi $t3,$t3,1
    		j load2

	print:
    		la $a0,line5		
    		li $v0,4
    		syscall
    
    		la $a0,newline
    		li $v0,4
    		syscall
    		
    		move $t6,$s2
    		la $s2,max
    
	print2:
    		lw $t7,0($s2)
    		beq $s2,$t6,ends5
    		addi $s2,$s2,4
    
    		move $a0,$t7
    		li $v0,1
    		syscall
    
    		la $a0,newline
    		li $v0,4
    		syscall
    
    		j print2

	ends5:	
    		jr $ra
    		
#print out it is empty
empty:
    		la $a0,line3
    		li $v0,4
    		syscall
    
    		la $a0,newline
    		li $v0,4
    		syscall
    		
    		j main  #return to main
    		
#end the program    
end:
    		li $v0,10
    		syscall
