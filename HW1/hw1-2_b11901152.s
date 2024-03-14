.globl __start

.rodata
    msg0: .string "This is HW1-2: \n"
    msg1: .string "Enter shift: "
    msg2: .string "Plaintext: "
    msg3: .string "Ciphertext: "
.text

################################################################################
  # print_char function
  # Usage: 
  #     1. Store the beginning address in x20
  #     2. Use "j print_char"
  #     The function will print the string stored from x20 
  #     When finish, the whole program with return value 0

print_char:
    addi a0, x0, 4
    la a1, msg3
    ecall
  
    add a1,x0,x20
    ecall

  # Ends the program with status code 0
    addi a0,x0,10
    ecall
    
################################################################################

__start:
  # Prints msg
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
    add a6, a0, x0
    
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    addi a0,x0,8
    li a1, 0x10150
    addi a2,x0,2047
    ecall
  # Load address of the input string into a0
    add a0,x0,a1
    
    addi x9,x0,10 #change line ascii
    addi x5,x0,0 #i=0
    addi x28,x0,48 #count space including ascii
    addi x29,x0,32 #space ascii
    li x20, 0x10200
    addi x30,x0,97 #a's ascii code
    addi x31,x0,123 #z's ascii code
  
################################################################################ 
  # Write your main function here. 
  # a0 stores the begining Plaintext
  # x16 stores the shift
  # Do store 66048(0x10200) into x20 
  # ex. j print_char
recure:
    add x6, a0,x5       # a0(base address) + i (how many index)
    add x19,x20,x5      # stored place address
    lbu x7, 0(x6)       # load the character
    beq x9, x7, print_char #check if character is \n then print it
    beq x29, x7, space #check if the character is space
    add x7, x7, x16   #else add the shift
    blt x7, x30, lower #check if <a
    bge x7, x31, bigger#check if >z
    sb x7,0(x19)#else store it in the memory
    addi x5,x5,1 #index=index+1
    j recure #jump back recure to check
space: #
    sb x28, 0(x19) #store 0,1,2,... for the counts of space
    addi x28, x28,1 #add the space count
    addi x5, x5,1 #index+=1
    j recure #jump back to recure
bigger:
    addi x7,x7,-26   #-=26
    sb x7,0(x19)     #store the value
    addi x5,x5,1     #index+=1
    j recure         #jump back to recure
lower:
    addi x7,x7,26    #+=26
    sb x7,0(x19)     #store the value
    addi x5,x5,1     #index+=1
    j recure         # jump back to recure
################################################################################

