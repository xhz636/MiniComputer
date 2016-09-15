#函数名: printcharacter
#功能描述: 输出一个字符
#系统调用编号: 11
#关键寄存器含义:
#   a0:输出的字符
printcharacter:
    addi    $sp,    $sp,    -12     #保存寄存器
    sw      $s0,    0x0($sp)
    sw      $s1,    0x4($sp)
    sw      $ra,    0x8($sp)
    ori     $s0,    $zero,  0xC000  #vram起始地址
    lbu     $k0,    0xF8($s0)       #光标x坐标
    lbu     $k1,    0xF9($s0)       #光标y坐标
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $a0,    0x1($s1)        #显示字符
    beq     $a0,    $zero,  printcharacter_end
    ori     $s1,    $zero,  0x08    #退格
    beq     $a0,    $s1,    printcharacter_backspace
    ori     $s1,    $zero,  0x0A    #回车
    beq     $a0,    $s1,    printcharacter_enter
    addi    $k0,    $k0,    2       #光标x坐标加二
    slti    $s1,    $k0,    160     #文本模式一行最多80个字符
    bne     $s1,    $zero,  printcharacter_end
    nop
    add     $k0,    $zero,  $zero
    addi    $k1,    $k1,    1       #光标y坐标加一
    slti    $s1,    $k1,    60      #文本模式最多60行
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen            #向上滚动一行
    addi    $k1,    $k1,    -1      #光标y坐标恢复
    j       printcharacter_end
    nop
printcharacter_backspace:
    addi    $k0,    $k0,    -2      #光标x坐标减二
    bgez    $k0,    printcharacter_backspace_remove
    nop
    beq     $k1,    $zero,  printcharacter_end
    add     $k0,    $zero,  $zero
    addi    $k0,    $zero,  158     #光标x坐标循环至最后
    addi    $k1,    $k1,    -1      #关闭y坐标减一
printcharacter_backspace_remove:
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $zero,  0x1($s1)        #清除字符
    j       printcharacter_end
    nop
printcharacter_enter:
    add     $k0,    $zero,  $zero   #光标x坐标置0
    addi    $k1,    $k1,    1       #光标y坐标加一
    slti    $s1,    $k1,    60
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen            #向上滚动一行
    addi    $k1,    $k1,    -1      #光标y坐标恢复
    j       printcharacter_end
    nop
printcharacter_end:
    sb      $k0,    0xF8($s0)       #更新光标x坐标
    sb      $k1,    0xF9($s0)       #更新光标y坐标
    lw      $s0,    0x0($sp)
    lw      $s1,    0x4($sp)
    lw      $ra,    0x8($sp)
    addi    $sp,    $sp,    12      #恢复寄存器
    jr      $ra
    nop
