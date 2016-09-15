#������: multiply
#��������: �˷�����
#�ؼ��Ĵ�������:
#   a0:������
#   a1:����
#   v0:�����λ
#   v1:�����λ
#ʱ������:
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
    andi    $t0,    $v1,    0x0001  #�ж����λ�Ƿ�Ϊ1(������ʱ��)
                                    #ͬʱ��ǰ�����λ����t0
    beq     $t0,    $zero,  multiply_plus_a1
    nop
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #��λ��������һ(������ʱ��)
multiply_shiftout_is_zero:
    bne     $t0,    $zero,  multiply_minus_a1
    nop
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #��λ��������һ(������ʱ��)
multiply_plus_a1:
    add     $v0,    $v0,    $a1
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #��λ��������һ(������ʱ��)
multiply_minus_a1:
    sub     $v0,    $v0,    $a1
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #��λ��������һ(������ʱ��)
multiply_shiftright:
    srl     $v1,    $v1,    1       #��λ����
    andi    $t2,    $v0,    0x0001  #��ȡ��λ���λ
    sll     $t2,    $t2,    31
    or      $v1,    $v1,    $t2     #��λ���λ�����λ���λ
    bgtz    $t1,    multiply_booth
    sra     $v0,    $v0,    1       #��λ����(������ʱ��)
multiply_end:
    jr      $ra
    nop
