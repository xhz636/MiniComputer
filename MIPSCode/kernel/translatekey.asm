#������: translatekey
#��������: ������ɨ����ת��Ϊ��ӦASCII�룬������ת��Ϊ0
#�ؼ��Ĵ�������:
#   a0:����ɨ����
#   a1:�Ƿ�Ϊ�ڶ���
#   v0:ASCII��
translatekey:
    ori     $t0,    $zero,  0xFC00
    beq     $a1,    $zero,  translatekey_noshift
    add     $t0,    $t0,    $a0     #����ɨ����ƫ����(������ʱ��)
    addi    $t0,    $t0,    0x0080  #���ӵڶ���ƫ����
translatekey_noshift:
    jr      $ra
    lbu     $v0,    0x0($t0)        #����ASCII��(������ʱ��)
