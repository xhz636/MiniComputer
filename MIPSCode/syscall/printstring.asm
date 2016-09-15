#函数名: printstring
#功能描述: 输出以结束符0结尾的字符串
#系统调用编号: 4
#关键寄存器含义:
#   a0:字符串首字符地址
printstring:
    addi    $sp,    $sp,    -8
    sw      $s0,    0x0($sp)
    sw      $ra,    0x4($sp)
    add     $s0,    $a0,    $zero
printstring_continue:
    lbu     $a0,    0x0($s0)
    jal     printcharacter
    nop
    beq     $a0,    $zero,  printstring_end
    nop
    addi    $s0,    $s0,    1
    j       printstring_continue
    nop
printstring_end:
    lw      $s0,    0x0($sp)
    lw      $ra,    0x4($sp)
    addi    $sp,    $sp,    8
    jr      $ra
    nop
