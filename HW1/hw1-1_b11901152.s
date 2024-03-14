.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n) = 5T(n/2) + 6n + 4, T(1) = 2\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text


__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads an int
    addi a0, x0, 5
    ecall
    addi x19,x0,5 #set the constant 5
    addi x20,x0,6 #set the constant 6
    addi x21,x0,2 #set the constant 2
    jal x1, recure  ##jump to recurence
    j result   #jump to result print
    
    
################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n) = 5T(n/2) + 6n + 4, T(1) = 2, round down the result of division
  # ex. addi t0, a0, 1
recure:
    addi sp,sp -8 ##move sp to store something
    sw x1, 4(sp)  #store jump back address
    sw a0, 0(sp)  #store the n
    addi x5, a0,-1 
    blt x0,x5,L1  #check if larger than 1
    addi t0,x0,2   #if n==1 compute it directly
    addi sp,sp,8
    jalr x0,0(x1)
L1:
    srai a0,a0,1 #divide nwith 2
    jal x1,recure #take the T(2/n)
    addi x6,t0,0  #add T(2/n)
    lw a0,0(sp)  #take the n out
    lw x1,4(sp)  #take the jump back location out
    addi sp,sp,8 #move back sp
    mul t0,t0,x19 #calculate 5T(2/n)
    addi t0,t0,4  #add 4
    mul x21,a0,x20  #caculate 6n
    add t0,t0,x21  #add 6n 
    jalr x0,0(x1) #jump back

################################################################################

result:
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall

  # Prints the result in t0
    addi a0, x0, 1
    add a1, x0, t0
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall