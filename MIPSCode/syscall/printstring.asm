#������: printstring
#��������: ����Խ�����0��β���ַ���
#ϵͳ���ñ��: 4
#�ؼ��Ĵ�������:
#   a0:�ַ������ַ���ַ
printstring:
    addi    $sp,    $sp,    -8      #����Ĵ���
    sw      $s0,    0x0($sp)
    sw      $ra,    0x4($sp)
    add     $s0,    $a0,    $zero
printstring_continue:
    lbu     $a0,    0x0($s0)        #�����ַ����ַ�
    jal     printcharacter          #����ַ�
    nop
    beq     $a0,    $zero,  printstring_end
    nop
    addi    $s0,    $s0,    1
    j       printstring_continue
    nop
printstring_end:
    lw      $s0,    0x0($sp)
    lw      $ra,    0x4($sp)
    addi    $sp,    $sp,    8       #�ָ��Ĵ���
    jr      $ra
    nop
