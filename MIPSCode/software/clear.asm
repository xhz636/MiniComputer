#������: clear
#��������: ����
#�ؼ��Ĵ�������:
#   ��
clear:
    addi    $sp,    $sp,    -4      #����Ĵ���
    sw      $ra,    0x0($sp)
    ori     $t0,    $zero,  0xC000
    sb      $zero,  0x00F8($t0)     #���x������0
    sb      $zero,  0x00F9($t0)     #���y������0
    jal     clearscreen             #����
    nop
    lw      $ra,    0x0($sp)
    addi    $sp,    $sp,    4       #�ָ��Ĵ���
    jr      $ra
    nop
