#函数名: printcharacter
#功能描述: 输出一个字符
#系统调用编号: 11
#关键寄存器含义:
#   a0:输出的字符
printcharacter:
    addi    $sp,    $sp,    -12
    sw      $s0,    0x0($sp)
    sw      $s1,    0x4($sp)
    sw      $ra,    0x8($sp)
    ori     $s0,    $zero,  0xC000  #vram起始地址
    lbu     $k0,    0xF8($s0)       #x
    lbu     $k1,    0xF9($s0)       #y
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $a0,    0x1($s1)
    beq     $a0,    $zero,  printcharacter_end
    ori     $s1,    $zero,  0x08
    beq     $a0,    $s1,    printcharacter_backspace
    ori     $s1,    $zero,  0x0A
    beq     $a0,    $s1,    printcharacter_enter
    addi    $k0,    $k0,    2
    slti    $s1,    $k0,    160
    bne     $s1,    $zero,  printcharacter_end
    nop
    add     $k0,    $zero,  $zero
    addi    $k1,    $k1,    1
    slti    $s1,    $k1,    60
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen
    addi    $k1,    $k1,    -1
    j       printcharacter_end
    nop
printcharacter_backspace:
    addi    $k0,    $k0,    -2
    bgez    $k0,    printcharacter_backspace_remove
    nop
    beq     $k1,    $zero,  printcharacter_end
    add     $k0,    $zero,  $zero
    addi    $k0,    $zero,  158
    addi    $k1,    $k1,    -1
printcharacter_backspace_remove:
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $zero,  0x1($s1)
    j       printcharacter_end
    nop
printcharacter_enter:
    add     $k0,    $zero,  $zero
    addi    $k1,    $k1,    1
    slti    $s1,    $k1,    60
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen
    addi    $k1,    $k1,    -1
    j       printcharacter_end
    nop
printcharacter_end:
    sb      $k0,    0xF8($s0)       #x
    sb      $k1,    0xF9($s0)       #y
    lw      $s0,    0x0($sp)
    lw      $s1,    0x4($sp)
    lw      $ra,    0x8($sp)
    addi    $sp,    $sp,    12
    jr      $ra
    nop
