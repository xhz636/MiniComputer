#������: divide
#��������: ��������
#�ؼ��Ĵ�������:
#   a0:������
#   a1:����
#   v0:����
#   v1:��
divide:
    add     $v0,    $zero,  $zero
    add     $v1,    $zero,  $a0
    addi    $t0,    $zero,  32
divide_shiftleft:
    beq     $t0,    $zero,  divide_end
    nop
    sll     $v0,    $v0,    1       #��λ����
    slt     $t1,    $v1,    $zero   #��ȡ��λ���λ
    or      $v0,    $v0,    $t1     #��λ���λ�����λ���λ
    sll     $v1,    $v1,    1       #��λ����
    sub     $t1,    $v0,    $a1     #����
    bltz    $t1,    divide_shiftleft
    addi    $t0,    $t0,    -1      #��λ��������һ(������ʱ��)
    add     $v0,    $t1,    $zero   #������
    ori     $v1,    $v1,    0x0001  #����
    j       divide_shiftleft
    nop
divide_end:
    jr      $ra
    nop
