#������: printcharacter
#��������: ���һ���ַ�
#ϵͳ���ñ��: 11
#�ؼ��Ĵ�������:
#   a0:������ַ�
printcharacter:
    addi    $sp,    $sp,    -12     #����Ĵ���
    sw      $s0,    0x0($sp)
    sw      $s1,    0x4($sp)
    sw      $ra,    0x8($sp)
    ori     $s0,    $zero,  0xC000  #vram��ʼ��ַ
    lbu     $k0,    0xF8($s0)       #���x����
    lbu     $k1,    0xF9($s0)       #���y����
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $a0,    0x1($s1)        #��ʾ�ַ�
    beq     $a0,    $zero,  printcharacter_end
    ori     $s1,    $zero,  0x08    #�˸�
    beq     $a0,    $s1,    printcharacter_backspace
    ori     $s1,    $zero,  0x0A    #�س�
    beq     $a0,    $s1,    printcharacter_enter
    addi    $k0,    $k0,    2       #���x����Ӷ�
    slti    $s1,    $k0,    160     #�ı�ģʽһ�����80���ַ�
    bne     $s1,    $zero,  printcharacter_end
    nop
    add     $k0,    $zero,  $zero
    addi    $k1,    $k1,    1       #���y�����һ
    slti    $s1,    $k1,    60      #�ı�ģʽ���60��
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen            #���Ϲ���һ��
    addi    $k1,    $k1,    -1      #���y����ָ�
    j       printcharacter_end
    nop
printcharacter_backspace:
    addi    $k0,    $k0,    -2      #���x�������
    bgez    $k0,    printcharacter_backspace_remove
    nop
    beq     $k1,    $zero,  printcharacter_end
    add     $k0,    $zero,  $zero
    addi    $k0,    $zero,  158     #���x����ѭ�������
    addi    $k1,    $k1,    -1      #�ر�y�����һ
printcharacter_backspace_remove:
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $zero,  0x1($s1)        #����ַ�
    j       printcharacter_end
    nop
printcharacter_enter:
    add     $k0,    $zero,  $zero   #���x������0
    addi    $k1,    $k1,    1       #���y�����һ
    slti    $s1,    $k1,    60
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen            #���Ϲ���һ��
    addi    $k1,    $k1,    -1      #���y����ָ�
    j       printcharacter_end
    nop
printcharacter_end:
    sb      $k0,    0xF8($s0)       #���¹��x����
    sb      $k1,    0xF9($s0)       #���¹��y����
    lw      $s0,    0x0($sp)
    lw      $s1,    0x4($sp)
    lw      $ra,    0x8($sp)
    addi    $sp,    $sp,    12      #�ָ��Ĵ���
    jr      $ra
    nop
