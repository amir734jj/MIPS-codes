###########################################################
#       sqrt implementation in MIPS
#  
#   Name:   
#   Date:
#
#   Description:
#       This code will find a sqrt of integers in double-precision floating point     
#
###########################################################
#       Register Usage
#   $t0         Holds the number that we want to find it's square root
#   $f12|$f13   Holds the square root value in double-precision floating point
###########################################################
        .data
###########################################################
    .text
main:
    li $t0, 16          # load $t0 with the number that we want to find it's square root
    
    addi $sp, $sp, -12  # allocate space on the stack for arguments IN and OUT
    
    sw $t0, 0($sp)      # load argument IN on the stack
    
    jal sqrt_of_integer # call subprogram sqrt_of_integer
    
    l.d $f12, 4($sp)    # load argument out from stack into register $f12
    li $v0, 3           # print the square root
    syscall
    
    addi $sp, $sp, -12  # deallocate space on the stack for arguments IN and OUT
    
mainEnd:
    li $v0, 10
    syscall             # Halt
###########################################################
#       sqrt_of_integer subprogram
#
#   Subprogram description:
#       this subprogram will get as argument IN an integer and it will find
#       the sqrt of the number in double precision floating point number
#       call read_row_matrix to fill the matrix
#
#   High level design:
#       function sqrt_of_integer (n) {
#           var x = n;
#       
#           for (var i = 0; i < (n/2); i++)
#               x = (x + n / x) / 2;
#
#           return x;
#       }
#
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0  Holds the number (n) that we want to find it's square root (IN)
#   $sp+4  Holds the square root of the number (n) in double precision floating point (OUT)
###########################################################
#       Register Usage
#   $t0         Holds the number (n)
#   $t1         Holds counter initialized to zero
#   $t2         Holds constant value 2
#   $f4|$f5     Holds the number (n) converted into double precision floating point initially | variable x
#   $f6|$f7     Holds the copy of register $f4 | variable n
#   $f8|$f9     Holds temporarily value (n /x)
#   $f10|$f11   Holds constant value 2.0
###########################################################
        .data
        
        .text
sqrt_of_integer:
# load argument IN from stack
    lw $t0, 0($sp)      # load integer that we want to find sqrt    
    
# convert number (n) to double precision floating point 
    mtc1 $t0, $f4
    cvt.d.w $f4, $f4
    
# backup the number into $f6. value of $f6 will not be modified through the code
    mov.d $f6, $f4
    
# initialization
    li $t1, 0           # initialize counter to zero
    li $t2, 2           # initialize $t2 to constant value 2
    li.d $f10, 2.0      # initialize $f10 to constant value 2.0

sqrt_of_integer_loop:
    div $t9, $t0, $t2   # $t9 <-- (n / 2)
    bge $t1, $t9, sqrt_of_integer_end   # if counter >= (n / 2) then branch to sqrt_of_integer_end
    
    div.d $f8, $f6, $f4 # $f8 <-- (n / x)
    add.d $f4, $f4, $f8 # x <-- x + (n / x)
    div.d $f4, $f4, $f10    # x <-- (x + (n / x)) / 2
    
    addi $t1, $t1, 1    # increment counter by 1
    
    b sqrt_of_integer_loop  # branch unconditionally to the beginning of the loop

sqrt_of_integer_end:
    s.d $f4, 4($sp)     # return x (sqrt of the number n)
    
    jr $ra              # jump back to the main
###########################################################