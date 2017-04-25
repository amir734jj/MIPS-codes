###########################################################
#       Program Description
#   factorial!
#
#   Description:
#       call a subprogram prompt_for_positive_number which returns a
#       positive number, then pass the returned positive number as
#       a argument for factorial subprogram.
#       Then, print the returned value of factorial subprogram in the main
#
#   High level design:
#       print factorials( prompt_for_positive_number() )
#
###########################################################
#       Register Usage
#   $t0 number
#   $t1 result of factorials
###########################################################
        .data
factorial_of_p: .asciiz "Factorial of "
factorial_is_p: .asciiz " is: "
###########################################################
    .text
main:
# calling subprogram prompt_for_positive_number
    addi $sp, $sp, -4               # allocate one word for $ra
    sw $ra, 0($sp)                  # store $ra on stack

                                    # no register to backup in the stack

    addi $sp, $sp, -4               # allocate words for the arguments (1 argument OUT)

    jal prompt_for_positive_number  # call subprogram prompt_for_positive_number

    lw $t0, 0($sp)                  # load positive number from stack
    addi $sp, $sp, 4                # deallocate words for the arguments

                                    # we did not backup a register, so there is no register restoring

    lw $ra, 0($sp)                  # load $ra from stack
    addi $sp, $sp, 4                # deallocate word for $ra



# calling subprogram factorials
    addi $sp, $sp, -4               # allocate one word for $ra
    sw $ra, 0($sp)                  # store $ra on stack

    addi $sp, $sp, -4               # allocate space for backups
    sw $t0, 0($sp)                  # backup $t0 on the stack

    addi $sp, $sp, -8               # allocate words for the arguments (1 argument IN, 1 argument OUT)

    sw $t0, 0($sp)                  # store argument in stack
    jal factorials                  # call subprogram factorials

    lw $t1, 4($sp)                  # load factorial result from stack
    addi $sp, $sp, 8                # deallocate words for the arguments

    lw $t0, 0($sp)                  # restore the backup from stack
    addi $sp, $sp, 4                # deallocate space for backups

    lw $ra, 0($sp)                  # load $ra from stack
    addi $sp, $sp, 4                # deallocate word for $ra



# printing original number and factorial result
    li $v0, 4                       # print factorial of:
    la $a0, factorial_of_p
    syscall

    li $v0, 1                       # print value of factorial
    move $a0, $t0                   # move the original number into register $ao
    syscall

    li $v0, 4                       # print factorial of:
    la $a0, factorial_is_p
    syscall

    li $v0, 1                       # print value of factorial
    move $a0, $t1                   # move the factorial value form $t1 into register $a0
    syscall

mainEnd:
    li $v0, 10
    syscall                         # halt
###########################################################
#       Prompt for positive number Subprogram
#
#   prompts for a positive number, and validate the number is positive
#
#   High level design:
#       int prompt_for_positive_number() {
#           while (true) {
#               number <-- prompt and read a number
#
#               if(number > 0)
#                   return number;
#           }
#       }
#
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0  Positive number (OUT)
###########################################################
#       Register Usage
#   $t0 Holds the recursive argument (number, or number -1, or number - 2 and etc.)
#   $t1 Holds the the return value of the recursive subprogram
#   $t2 Hols the return value of number * (number - 1)!
###########################################################
        .data
prompt_for_positive_number_number_p:           .asciiz "Please enter a positive number (number > 0): "
prompt_for_positive_number_invalid_number_p:   .asciiz "Please enter a valid number! \n"
###########################################################
        .text
prompt_for_positive_number:

prompt_for_positive_number_loop:
    la $a0, prompt_for_positive_number_number_p # prompt for positive number
    li $v0, 4
    syscall

    li $v0, 5                                   # read number
    syscall

    bgtz $v0, prompt_for_positive_number_end    # if number is greater than or equal to zero,
                                                # then branch to prompt_for_positive_number_end

    la $a0, prompt_for_positive_number_invalid_number_p # print error message when number <= 0
    li $v0, 4
    syscall

    b prompt_for_positive_number                # branch unconditionally back to the beginning of the loop

prompt_for_positive_number_end:
    sw $v0, 0($sp)                              # store the number in allocated stack

    jr $ra                                      # jump back to the main
###########################################################
#       Factorials Subprogram
#
#   calculates the factorial of the given number
#
#   High level design:
#       int factorials(int number) {
#           if (number == 0)
#               return 1;
#           else
#               return number * factorial(number - 1);
#       }
#
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0  Positive number (IN)
#   $sp+4  Result of factorial (OUT)
###########################################################
#       Register Usage
#   $t0 Holds the recursive argument (number, or number -1, or number - 2 and etc.)
#   $t1 Holds the the return value of the recursive subprogram
#   $t2 Holds the return value of number * (number - 1)!
###########################################################
        .data
###########################################################
        .text
factorials:
    lw $t0, 0($sp)              # load argument from top of stack into register $t0
    beqz $t0, factorial_return  # if $t0 is equal to 0, then branch to returnOne

factorial_recursive:
    addi $sp, $sp, -4           # allocate one word for $ra
    sw $ra, 0($sp)              # store $ra on stack

    addi $sp, $sp, -4           # allocate space for backups
    sw $t0, 0($sp)              # store the number in stack

    addi $sp, $sp, -8           # allocate word for arguments (1 argument IN, 1 argument OUT)
    addi $t0, $t0, -1           # subtract 1 from $t0
    sw $t0, 0($sp)              # store the (number - 1) on the stack

    jal factorials              # recursive call

    lw $t1, 4($sp)              # load subprogram's return value into $t1
    addi $sp, $sp, 8            # deallocate words for the arguments

    lw $t0, 0($sp)              # restore the backup from stack
    addi $sp, $sp, 4            # deallocate space for backups

    lw $ra, 0($sp)              # load $ra from stack
    addi $sp, $sp, 4            # deallocate word for $ra


    mul $t2, $t0, $t1           # multiply number with (number - 1)!
    sw $t2, 4($sp)              # store factorial result for return

    jr $ra                      # jump to parent subprogram call

factorial_return:
    li $t0, 1                   # load 1 into register $t0
    sw $t0, 4($sp)              # store 1 into the return value stack

    jr $ra                                              # jump to parent call
###########################################################
