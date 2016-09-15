#函数名: clear
#功能描述: 清屏
#关键寄存器含义:
#   无
clear:
    addi    $sp,    $sp,    -4
    sw      $ra,    0x0($sp)
    ori     $t0,    $zero,  0xC000
    sb      $zero,  0x00F8($t0)
    sb      $zero,  0x00F9($t0)
    jal     clearscreen
    nop
    lw      $ra,    0x0($sp)
    addi    $sp,    $sp,    4
    jr      $ra
    nop
