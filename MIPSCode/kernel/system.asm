#������: system
#��������: ϵͳ����
#�ؼ��Ĵ�������:
#   s0:vram��ʼ��ַ
#   s1:ɨ���뻺����ͷָ��
#   s2:ɨ���뻺����βָ��
#   s3:ɨ���뻺��������
#   s4:���̻�����ͷָ��
#   s5:���̻�����βָ��
system:
    ori     $s0,    $zero,  0x0000C000
system_rolling_scancode:
    beq     $gp,    $zero,  system_rolling_scancode
    nop
system_getscancode:
    add     $gp,    $zero,  $zero
    lw      $s1,    0xE0($s0)       #ɨ���뻺����ͷָ��
    lw      $s2,    0xE4($s0)       #ɨ���뻺����βָ��
    lbu     $s3,    0x0($s1)        #ɨ���뻺�������ַ�
    addi    $s1,    $s1,    1       #ɨ���뻺����ͷָ���һ
    ori     $s4,    $zero,  0xC0E0
    bne     $s1,    $s4,    system_refreshscanhead
    nop
    ori     $s1,    $zero,  0xC0A0  #ɨ���뻺����ͷָ��ѭ��
system_refreshscanhead:
    sw      $s1,    0xE0($s0)       #����ɨ���뻺����ͷָ��
    lw      $s4,    0xE8($s0)       #���̻�����ͷָ��
    lw      $s5,    0xEC($s0)       #���̻�����βָ��
    ori     $s6,    $zero,  0xF0    #����
    beq     $s3,    $s6,    system_keyrelease
    ori     $s6,    $zero,  0xE0    #��չ��
    beq     $s3,    $s6,    system_keyextend
    ori     $s6,    $zero,  0x12    #Shift
    beq     $s3,    $s6,    system_shift
    ori     $s6,    $zero,  0x14    #Ctrl
    beq     $s3,    $s6,    system_ctrl
    ori     $s6,    $zero,  0x11    #Alt
    beq     $s3,    $s6,    system_alt
    nop
    j       system_print
    nop
system_keyrelease:
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x1     #�ͷŰ�����־��Ϊ1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_keyextend:
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x2     #��չ������־��Ϊ1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_shift:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #�ͷŰ���
    bne     $s6,    $zero,  system_shift_release
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x10    #Shift������־��Ϊ1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_shift_release:
    andi    $s6,    $s6,    0xEC    #����ͷš���չ��Shift��־
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_ctrl:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #�ͷŰ���
    bne     $s6,    $zero,  system_ctrl_release
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x8     #Ctrl������־��Ϊ1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_ctrl_release:
    andi    $s6,    $s6,    0xF4    #����ͷš���չ��Ctrl��־
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_alt:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #�ͷŰ���
    bne     $s6,    $zero,  system_alt_release
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x4     #Alt������־��Ϊ1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_alt_release:
    andi    $s6,    $s6,    0xF8    #����ͷš���չ��Alt��־
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_print:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #�ͷŰ���
    beq     $s6,    $zero,  system_input
    nop
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0xFC    #����ͷż���չ��־
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_input:
    add     $a0,    $s3,    $zero   #ɨ����
    lbu     $a1,    0xF2($s0)
    andi    $a1,    $a1,    0x10    #Shift��־
    jal     translatekey
    srl     $a1,    $a1,    4
    add     $s3,    $v0,    $zero   #ASCII��
    addi    $v0,    $zero,  11
    add     $a0,    $s3,    $zero
    syscall                         #��ʾ�ַ�
    beq     $s3,    $zero,  system_input_end
    ori     $s6,    $zero,  0x08    #�˸�
    beq     $s6,    $s3,    system_input_backspace
    ori     $s6,    $zero,  0x0A    #�س�
    beq     $s6,    $s3,    system_input_enter
    nop
    sb      $s3,    0x0($s5)
    addi    $s7,    $s5,    1       #���̻�����βָ���һ
    ori     $s6,    $zero,  0xFE00
    bne     $s6,    $s7,    system_input_save
    nop
    addi    $s7,    $zero,  0xFD00  #���̻�����βָ��ѭ��
system_input_save:
    beq     $s7,    $s4,    system_input_end
    nop
    add     $s5,    $s7,    $zero   #���¼��̻�����βָ��
    j       system_input_end
    nop
system_input_backspace:
    beq     $s4,    $s5,    system_input_end
    nop
    addi    $s5,    $s5,    -1      #���̻�����βָ���һ
    ori     $s6,    $zero,  0xFCFF
    bne     $s6,    $s5,    system_input_end
    nop
    addi    $s5,    $s5,    0xFDFF  #���̻�����βָ��ѭ��
    j       system_input_end
    nop
system_input_enter:
    jal     program
    nop
    ori     $s4,    $zero,  0xFD00  #��ռ��̻�����
    ori     $s5,    $zero,  0xFD00  #��ռ��̻�����
    j       system_input_end
    nop
system_input_end:
    sw      $s4,    0xE8($s0)       #���¼��̻�����ͷָ��
    sw      $s5,    0xEC($s0)       #���¼��̻�����βָ��
    j       system_rolling_scancode
    nop
