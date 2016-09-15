#函数名: delay
#功能描述: 软件延时
#系统调用编号: 16
#关键寄存器含义:
#   a0:延时时间(ms)
delay:
    beq     $a0,    $zero,  delay_end
    jal     multiply
    ori     $a1,    $zero,  0xC350  #50000个时钟(处于延时槽)
    addiu   $k0,    $v1,    -410    #减去乘法消耗时间
    sltu    $k1,    $k0,    $v1
    bne     $k1,    $zero,  delay_count
    add     $v1,    $k0,    $zero   #保存减去后的结果(处于延时槽)
    addiu   $v0,    $v0,    -1      #低位不够减, 高位借一
delay_count:
    addiu   $k0,    $v1,    -6
    sltu    $k1,    $k0,    $v1
    beq     $k1,    $zero,  delay_compare
    add     $v1,    $k0,    $zero   #保存减去后的结果(处于延时槽)
    j       delay_count
    nop
delay_compare:
    beq     $v0,    $zero,  delay_end
    addiu   $v0,    $v0,    -1      #高位减一(处于延时槽)
    j       delay_count
    nop
delay_end:
    jr      $ra
    nop
