#������: delay
#��������: �����ʱ
#ϵͳ���ñ��: 16
#�ؼ��Ĵ�������:
#   a0:��ʱʱ��(ms)
delay:
    beq     $a0,    $zero,  delay_end
    jal     multiply
    ori     $a1,    $zero,  0xC350  #50000��ʱ��(������ʱ��)
    addiu   $k0,    $v1,    -410    #��ȥ�˷�����ʱ��
    sltu    $k1,    $k0,    $v1
    bne     $k1,    $zero,  delay_count
    add     $v1,    $k0,    $zero   #�����ȥ��Ľ��(������ʱ��)
    addiu   $v0,    $v0,    -1      #��λ������, ��λ��һ
delay_count:
    addiu   $k0,    $v1,    -6
    sltu    $k1,    $k0,    $v1
    beq     $k1,    $zero,  delay_compare
    add     $v1,    $k0,    $zero   #�����ȥ��Ľ��(������ʱ��)
    j       delay_count
    nop
delay_compare:
    beq     $v0,    $zero,  delay_end
    addiu   $v0,    $v0,    -1      #��λ��һ(������ʱ��)
    j       delay_count
    nop
delay_end:
    jr      $ra
    nop
