#函数名: translatekey
#功能描述: 将键盘扫描码转换为相应ASCII码，若无则转换为0
#关键寄存器含义:
#   a0:键盘扫描码
#   a1:是否为第二区
#   v0:ASCII码
translatekey:
    ori     $t0,    $zero,  0xFC00
    beq     $a1,    $zero,  translatekey_noshift
    add     $t0,    $t0,    $a0     #计算扫描码偏移量(处于延时槽)
    addi    $t0,    $t0,    0x0080  #增加第二区偏移量
translatekey_noshift:
    jr      $ra
    lbu     $v0,    0x0($t0)        #查找ASCII码(处于延时槽)
