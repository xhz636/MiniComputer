#函数名: multiply
#功能描述: 乘法运算
#关键寄存器含义:
#   a0:被乘数
#   a1:乘数
#   v0:结果高位
#   v1:结果低位
#时钟消耗:
#   00:12
#   01:13
#   10:13
#   11:12
#   other:6
#   total:406
multiply:
    add     $v0,    $zero,  $zero
    add     $v1,    $zero,  $a0
    add     $t0,    $zero,  $zero
    addi    $t1,    $zero,  32
multiply_booth:
    beq     $t0,    $zero,  multiply_shiftout_is_zero
    andi    $t0,    $v1,    0x0001  #判断最低位是否为1(处于延时槽)
                                    #同时提前将最低位放入t0
    beq     $t0,    $zero,  multiply_plus_a1
    nop
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_shiftout_is_zero:
    bne     $t0,    $zero,  multiply_minus_a1
    nop
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_plus_a1:
    add     $v0,    $v0,    $a1
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_minus_a1:
    sub     $v0,    $v0,    $a1
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_shiftright:
    srl     $v1,    $v1,    1       #低位右移
    andi    $t2,    $v0,    0x0001  #获取高位最低位
    sll     $t2,    $t2,    31
    or      $v1,    $v1,    $t2     #高位最低位放入低位最高位
    bgtz    $t1,    multiply_booth
    sra     $v0,    $v0,    1       #高位右移(处于延时槽)
multiply_end:
    jr      $ra
    nop
