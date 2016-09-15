#函数名: divide
#功能描述: 除法运算
#关键寄存器含义:
#   a0:被除数
#   a1:除数
#   v0:余数
#   v1:商
divide:
    add     $v0,    $zero,  $zero
    add     $v1,    $zero,  $a0
    addi    $t0,    $zero,  32
divide_shiftleft:
    beq     $t0,    $zero,  divide_end
    nop
    sll     $v0,    $v0,    1       #高位左移
    slt     $t1,    $v1,    $zero   #获取低位最高位
    or      $v0,    $v0,    $t1     #低位最高位放入高位最低位
    sll     $v1,    $v1,    1       #低位左移
    sub     $t1,    $v0,    $a1     #试商
    bltz    $t1,    divide_shiftleft
    addi    $t0,    $t0,    -1      #移位计数器减一(处于延时槽)
    add     $v0,    $t1,    $zero   #置余数
    ori     $v1,    $v1,    0x0001  #置商
    j       divide_shiftleft
    nop
divide_end:
    jr      $ra
    nop
