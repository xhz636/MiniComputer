#������: asciitobyte
#��������: ��2��ʮ�������ַ�ת��Ϊbyte����, ������-1
#�ؼ��Ĵ�������:
#   a0:��λ�ַ�
#   a1:��λ�ַ�
#   v0:byte����
asciitobyte:
    ori     $a0,    $a0,    0x20    #��д�ַ�תСд�ַ�
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
    addi    $a0,    $a0,    -0x30   #�����ַ�
    sll     $v0,    $a0,    4       #������λ
    j       asciitobyte_lowascii
    nop
asciitobyte_highhexdigit:
    addi    $a0,    $a0,    -0x57   #Ӣ���ַ�
    sll     $v0,    $a0,    4       #������λ
    j       asciitobyte_lowascii
    nop
asciitobyte_lowascii:
    ori     $a1,    $a1,    0x20    #����ڶ����ַ�
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
    or      $v0,    $v0,    $a1     #������λ
    j       asciitobyte_end
    nop
asciitobyte_lowhexdigit:
    addi    $a1,    $a1,    -0x57
    or      $v0,    $v0,    $a1     #������λ
    j       asciitobyte_end
    nop
asciitobyte_nohex:
    addi    $v0,    $zero,  -1      #���󷵻�-1
asciitobyte_end:
    jr      $ra
    nop
