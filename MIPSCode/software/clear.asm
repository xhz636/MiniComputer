#函数名: clear
#功能描述: 清屏
#关键寄存器含义:
#   无
clear:
    addi    $sp,    $sp,    -4      #保存寄存器
    sw      $ra,    0x0($sp)
    ori     $t0,    $zero,  0xC000
    sb      $zero,  0x00F8($t0)     #光标x坐标置0
    sb      $zero,  0x00F9($t0)     #光标y坐标置0
    jal     clearscreen             #清屏
    nop
    lw      $ra,    0x0($sp)
    addi    $sp,    $sp,    4       #恢复寄存器
    jr      $ra
    nop
