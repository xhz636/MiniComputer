#函数名: notfound
#功能描述: 未找到命令, 输出"There is no such command.\n"
#关键寄存器含义:
#   无
notfound:
    la      $a0,    unknowncmd
    addi    $v0,    $zero,  4
    syscall
    jr      $ra
    nop
.data
unknowncmd:
.asciiz "There is no such command.\n"
