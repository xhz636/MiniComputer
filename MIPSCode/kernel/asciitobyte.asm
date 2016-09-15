#函数名: asciitobyte
#功能描述: 将2个十六进制字符转换为byte数据, 出错返回-1
#关键寄存器含义:
#   a0:高位字符
#   a1:低位字符
#   v0:byte数据
asciitobyte:
    ori     $a0,    $a0,    0x20    #大写字符转小写字符
    ori     $t0,    $zero,  0x30
    slt     $t1,    $a0,    $t0     #ascii<'0'
    bne     $t1,    $zero,  asciitobyte_nohex
    ori     $t0,    $zero,  0x3A
    slt     $t1,    $a0,    $t0     #ascii<'9'+1
    bne     $t1,    $zero,  asciitobyte_highdigit
    ori     $t0,    $zero,  0x61
    slt     $t1,    $a0,    $t0     #ascii<'a'
    bne     $t1,    $zero,  asciitobyte_nohex
    ori     $t0,    $zero,  0x67
    slt     $t1,    $a0,    $t0     #ascii<'f'+1
    bne     $t1,    $zero,  asciitobyte_highhexdigit
    nop
    j       asciitobyte_nohex
    nop
asciitobyte_highdigit:
    addi    $a0,    $a0,    -0x30   #数字字符
    sll     $v0,    $a0,    4       #结果存高位
    j       asciitobyte_lowascii
    nop
asciitobyte_highhexdigit:
    addi    $a0,    $a0,    -0x57   #英文字符
    sll     $v0,    $a0,    4       #结果存高位
    j       asciitobyte_lowascii
    nop
asciitobyte_lowascii:
    ori     $a1,    $a1,    0x20    #处理第二个字符
    ori     $t0,    $zero,  0x30
    slt     $t1,    $a1,    $t0
    bne     $t1,    $zero,  asciitobyte_nohex
    ori     $t0,    $zero,  0x3A
    slt     $t1,    $a1,    $t0
    bne     $t1,    $zero,  asciitobyte_lowhdigit
    ori     $t0,    $zero,  0x61
    slt     $t1,    $a1,    $t0
    bne     $t1,    $zero,  asciitobyte_nohex
    ori     $t0,    $zero,  0x67
    slt     $t1,    $a1,    $t0
    bne     $t1,    $zero,  asciitobyte_lowhexdigit
    nop
    j       asciitobyte_nohex
    nop
asciitobyte_lowhdigit:
    addi    $a1,    $a1,    -0x30
    or      $v0,    $v0,    $a1     #结果存低位
    j       asciitobyte_end
    nop
asciitobyte_lowhexdigit:
    addi    $a1,    $a1,    -0x57
    or      $v0,    $v0,    $a1     #结果存低位
    j       asciitobyte_end
    nop
asciitobyte_nohex:
    addi    $v0,    $zero,  -1      #错误返回-1
asciitobyte_end:
    jr      $ra
    nop
