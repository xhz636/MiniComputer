.text 0x00000000
j       initialize
nop
exception:
    mfc0    $k0,    $13
    andi    $k1,    $k0,    0x007C  #��ȡExcCode
    ori     $k0,    $zero,  0xFE00
    add     $k0,    $k0,    $k1     #�����쳣������ַ
    lw      $k1,    0x0($k0)        #��ȡ�쳣������ڵ�ַ
    jr      $k1
    nop
exception_interrupt:
    mfc0    $k0,    $13
    andi    $k1,    $k0,    0x0800  #ʱ���жϱ�־λ
    bgtz    $k1,    exception_interrupt_timer
    andi    $k1,    $k0,    0x0400  #�����жϱ�־λ(������ʱ��)
    bgtz    $k1,    exception_interrupt_keyboard
    nop
    eret
exception_interrupt_timer:
    mfc0    $k0,    $11
    li      $k1,    0x017D7840
    addu    $k0,    $k0,    $k1
    mtc0    $k0,    $11
    addi    $sp,    $sp,    -4
    sw      $s0,    0x0($sp)        #s0��ջ
    ori     $s0,    $zero,  0xC000  #vram��ʼ��ַ
    lbu     $k0,    0xF8($s0)       #x
    lbu     $k1,    0xF9($s0)       #y
    sll     $k1,    $k1,    8
    add     $s0,    $s0,    $k1
    add     $s0,    $s0,    $k0     #���������ڵ�ַ
    ori     $k0,    $zero,  0xC000
    lbu     $k1,    0xFC($k0)       #��ȡ�����˸״̬
    beq     $k1,    $zero,  exception_interrupt_timer_lighten
    nop
    lbu     $k1,    0xFB($k0)       #��ȡ������ַ�
    sb      $k1,    0x1($s0)        #�����ʧ
    add     $k1,    $zero,  $zero
    j       exception_interrupt_timer_end
    sb      $k1,    0xFC($k0)       #�ı�����˸״̬(������ʱ��)
exception_interrupt_timer_lighten:
    lbu     $k1,    0xFA($k0)       #��ȡ������
    sb      $k1,    0x1($s0)        #������
    addi    $k1,    $zero,  1
    sb      $k1,    0xFC($k0)       #�ı�����˸״̬
exception_interrupt_timer_end:
    lw      $s0,    0x0($sp)        #s0��ջ
    addi    $sp,    $sp,    4
    eret
exception_interrupt_keyboard:
    addi    $sp,    $sp,    -4
    sw      $s0,    0x0($sp)        #s0��ջ
    ori     $k1,    $zero,  0xC000
    lb      $s0,    0xF0($k1)       #��ȡ����ɨ����
    lw      $k0,    0xE0($k1)       #��ȡɨ���뻺����ͷָ��
    lw      $k1,    0xE4($k1)       #��ȡɨ���뻺����βָ��
    sb      $s0,    0x0($k1)        #Ԥ����ɨ����
    addi    $k1,    $k1,    1
    ori     $s0,    $zero,  0xC0E0
    bne     $k1,    $s0,    exception_interrupt_keyboard_save
    nop
    ori     $k1,    $zero,  0xC0A0
exception_interrupt_keyboard_save:
    beq     $k0,    $k1,    exception_interrupt_keyboard_end
    ori     $k0,    $zero,  0xC000
    sw      $k1,    0xE4($k0)       #����βָ��, ��ɱ���ɨ����
    addi    $gp,    $zero,  1
exception_interrupt_keyboard_end:
    lw      $s0,    0x0($sp)        #s0��ջ
    addi    $sp,    $sp,    4
    eret
exception_syscall:
    addi    $sp,    $sp,    -4
    sw      $ra,    0x0($sp)
    ori     $k0,    $zero,  0xFF00
    sll     $k1,    $v0,    2
    add     $k0,    $k0,    $k1     #����ϵͳ����������ַ
    lw      $k1,    0x0($k0)        #��ȡϵͳ������ڵ�ַ
    jalr    $ra,    $k1
    nop
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4
    mtc0    $k0,    $14
    lw      $ra,    0x0($sp)
    addi    $sp,    $sp,    4
    eret
exception_break:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #�����ϵ�ָ��
    mtc0    $k0,    $14
    eret
exception_reserved:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #��������ָ��
    mfc0    $k1,    $13
    srl     $k1,    $k1,    29
    add     $k0,    $k0,    $k1     #������ʱ��
    mtc0    $k0,    $14
    eret
exception_overflow:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #�������������ָ��
    mfc0    $k1,    $13
    srl     $k1,    $k1,    29
    add     $k0,    $k0,    $k1     #������ʱ��
    mtc0    $k0,    $14
    eret
exception_trap:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #��������ָ��
    mtc0    $k0,    $14
    eret
initialize:
    mtc0    $zero,  $9              #��ʼ��ʱ��
    ori     $sp,    $zero,  0xC000  #��ʼ��ջ��
    ori     $t0,    $zero,  0xC0A0
    sw      $t0,    0x00E0($sp)     #ɨ���뻺����ͷָ��
    sw      $t0,    0x00E4($sp)     #ɨ���뻺����βָ��
    ori     $t0,    $zero,  0xFD00
    sw      $t0,    0x00E8($sp)     #���̻�����ͷָ��
    sw      $t0,    0x00EC($sp)     #���̻�����βָ��
    sb      $zero,  0x00F1($sp)     #{Caps Lock, Num Lock,Scroll Lock}
    sb      $zero,  0x00F2($sp)     #��չ��, �����־
    sb      $zero,  0x00F3($sp)     #�ı�ģʽ���뷽ʽ
    sb      $zero,  0x00F8($sp)     #��ʼ�����xλ��
    sb      $zero,  0x00F9($sp)     #��ʼ�����yλ��
    ori     $t0,    $zero,  0xDB
    sb      $t0,    0x00FA($sp)     #��ʼ��������
    sb      $zero,  0x00FB($sp)     #��ʼ��������ַ�
    sb      $zero,  0x00FC($sp)     #��ʼ�������˸״̬
    ori     $t0,    $zero,  0x70
    jal     clearscreen
    sb      $t0,    0x00FD($sp)     #��ʼ���ı�ģʽ��ɫ(������ʱ��)
    li      $t0,    0x017D7840
    mtc0    $t0,    $11             #����ʱ���ж�Ƶ��Ϊ2Hz
    ori     $t0,    $zero,  0x0C01
    j       system
    mtc0    $t0,    $12             #����ʱ���жϺͼ����ж�(������ʱ��)
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
program:
    addi    $sp,    $sp,    -0x24   #����Ĵ���
    sw      $ra,    0x0($sp)
    sw      $s0,    0x4($sp)
    sw      $s1,    0x8($sp)
    sw      $s2,    0xC($sp)
    sw      $s3,    0x10($sp)
    sw      $s4,    0x14($sp)
    sw      $s5,    0x18($sp)
    sw      $s6,    0x1C($sp)
    sw      $s7,    0x20($sp)
    ori     $s0,    $zero,  0xC000  #vram��ʼ��ַ
    lw      $s1,    0xE8($s0)       #���̻�����ͷָ��
    lw      $s2,    0xEC($s0)       #���̻�����βָ��
    beq     $s1,    $s2,    program_end
    ori     $s0,    $zero,  0xD000  #�����б���ʼ��ַ(������ʱ��)
program_nextstring:
    addi    $s3,    $s0,    0xA0    #��������ʼ��ַ
    add     $s4,    $s1,    $zero
program_comparestring:
    beq     $s4,    $s2,    program_keybufferend
    lbu     $s5,    0x0($s3)        #����������ַ�(������ʱ��)
    lbu     $s6,    0x0($s4)        #������̻������ַ�
    ori     $s7,    $zero,  0x20    #�ո�
    beq     $s7,    $s6,    program_keybufferend
    nop
    beq     $s5,    $zero,  program_stringend
    ori     $s6,    $s6,    0x20    #��д�ַ�תСд�ַ�
    beq     $s5,    $s6,    program_asciiequal
    nop
program_keybufferend:
    beq     $s5,    $zero,  program_loadaddress
    nop
program_stringend:
    addi    $s0,    $s0,    0x100   #��һ��������
    ori     $s7,    $zero,  0xE000  #�����б����
    beq     $s0,    $s7,    program_notfound
    nop
    j       program_nextstring
    nop
program_asciiequal:
    addi    $s3,    $s3,    1       #��������һ���ַ�
    addi    $s4,    $s4,    1       #���̻�������һ���ַ�
    j       program_comparestring
    nop
program_loadaddress:
    ori     $s1,    $zero,  0xC000
    sw      $s4,    0xE8($s1)       #���¼��̻�����ͷָ��
    lw      $s0,    0xFC($s0)       #���������ڵ�ַ
    jalr    $ra,    $s0             #ִ�г���
    nop
    j       program_end
    nop
program_notfound:
    jal     notfound                #δ�ҵ�����
    nop
program_end:
    lw      $ra,    0x0($sp)
    lw      $s0,    0x4($sp)
    lw      $s1,    0x8($sp)
    lw      $s2,    0xC($sp)
    lw      $s3,    0x10($sp)
    lw      $s4,    0x14($sp)
    lw      $s5,    0x18($sp)
    lw      $s6,    0x1C($sp)
    lw      $s7,    0x20($sp)
    addi    $sp,    $sp,    0x24    #�ָ��Ĵ���
    jr      $ra
    nop
notfound:
    la      $a0,    unknowncmd
    addi    $v0,    $zero,  4
    syscall
    jr      $ra
    nop
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
clearscreen:
    ori     $t8,    $zero,  0xC0FD  #�ı�ģʽ��ɫ��ַ
    lb      $t9,    0x0($t8)
    sll     $t9,    $t9,    8
    ori     $t0,    $zero,  0xC000  #vram��ʼ��ַ
    add     $t1,    $zero,  $zero
clearscreen_loop_y:
    slti    $t2,    $t1,    60      #�ı�ģʽ��60��
    beq     $t2,    $zero,  clearscreen_loop_y_end
    nop
    sll     $t3,    $t1,    8
    add     $t3,    $t0,    $t3
    add     $t4,    $zero,  $zero
clearscreen_loop_x:
    slti    $t5,    $t4,    160     #�ı�ģʽÿ��80���ַ�
                                    #ÿ���ַ�ռ2bytes:(color,ascii)
    beq     $t5,    $zero,  clearscreen_loop_x_end
    nop
    add     $t6,    $t3,    $t4
    sh      $t9,    0x0($t6)        #������ɫ��0�ַ�
    addi    $t4,    $t4,    2
    j       clearscreen_loop_x
    nop
clearscreen_loop_x_end:
    addi    $t1,    $t1,    1
    j       clearscreen_loop_y
    nop
clearscreen_loop_y_end:
    jr      $ra
    nop
scrollscreen:
    ori     $t0,    $zero,  0xC000  #vram��ʼ��ַ
    add     $t1,    $zero,  $zero
scrollscreen_loop_y:
    slti    $t3,    $t1,    59      #59����Ҫ���Ϲ���
    beq     $t3,    $zero,  scrollscreen_loop_y_end
    nop
    sll     $t3,    $t1,    8
    add     $t3,    $t0,    $t3
    addi    $t4,    $t3,    0x0100
    add     $t2,    $zero,  $zero
scrollscreen_loop_x:
    slti    $t5,    $t2,    160
    beq     $t5,    $zero,  scrollscreen_loop_x_end
    nop
    add     $t5,    $t3,    $t2
    add     $t6,    $t4,    $t2
    lhu     $t7,    0x0($t6)        #����һ�����ݸ��Ƶ���һ����
    sh      $t7,    0x0($t5)
    addi    $t2,    $t2,    2
    j       scrollscreen_loop_x
    nop
scrollscreen_loop_x_end:
    addi    $t1,    $t1,    1
    j       scrollscreen_loop_y
    nop
scrollscreen_loop_y_end:
    sll     $t3,    $t1,    8
    add     $t3,    $t0,    $t3
    addi    $t2,    $zero,  1
scrollscreen_lastline:
    slti    $t5,    $t2,    160     #���һ�����
    beq     $t5,    $zero,  scrollscreen_end
    nop
    add     $t5,    $t3,    $t2
    sb      $zero,  0x0($t5)
    addi    $t2,    $t2,    2
    j       scrollscreen_lastline
    nop
scrollscreen_end:
    jr      $ra
    nop
translatekey:
    ori     $t0,    $zero,  0xFC00
    beq     $a1,    $zero,  translatekey_noshift
    add     $t0,    $t0,    $a0     #����ɨ����ƫ����(������ʱ��)
    addi    $t0,    $t0,    0x0080  #���ӵڶ���ƫ����
translatekey_noshift:
    jr      $ra
    lbu     $v0,    0x0($t0)        #����ASCII��(������ʱ��)
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
color:
    addi    $sp,    $sp,    -0x1C   #����Ĵ���
    sw      $ra,    0x0($sp)
    sw      $s0,    0x4($sp)
    sw      $s1,    0x8($sp)
    sw      $s2,    0xC($sp)
    sw      $s3,    0x10($sp)
    sw      $s4,    0x14($sp)
    sw      $s5,    0x18($sp)
    ori     $s0,    $zero,  0xC000
    lw      $s1,    0xE8($s0)       #���̻�����ͷָ��
    lw      $s2,    0xEC($s0)       #���̻�����βָ��
    ori     $s3,    $zero,  0x20    #�ո�
    beq     $s1,    $s2,    color_error
    nop
color_removespace:
    lbu     $a0,    0x0($s1)        #���̻������׸��ǿ��ַ�
    addi    $s1,    $s1,    1       #���̻�����ͷָ���һ
    beq     $s1,    $s2,    color_error
    nop
    beq     $a0,    $s3,    color_removespace
    nop
    lbu     $a1,    0x0($s1)        #���̻������ڶ����ǿ��ַ�
    addi    $s1,    $s1,    1
    bne     $s1,    $s2,    color_error
    nop
    jal     asciitobyte             #ʮ�������ַ���ת��Ϊbyte
    nop
    andi    $s1,    $v0,    0xF0
    srl     $s1,    $s1,    4       #��λ(����ɫ)
    andi    $s2,    $v0,    0x0F    #��λ(ǰ��ɫ)
    beq     $s1,    $s2,    color_error
    nop
    sb      $v0,    0xFD($s0)       #�����ı�ģʽ��ɫ
    add     $s1,    $zero,  $zero
color_loop_y:
    slti    $s2,    $s1,    60      #�ı�ģʽ��60��
    beq     $s2,    $zero,  color_end
    nop
    sll     $s3,    $s1,    8
    add     $s3,    $s0,    $s3
    add     $s4,    $zero,  $zero
color_loop_x:
    slti    $s5,    $s4,    160     #�ı�ģʽÿ��80�ַ�
    beq     $s5,    $zero,  color_loop_x_end
    nop
    add     $s5,    $s3,    $s4
    sb      $v0,    0x0($s5)        #������ɫ
    addi    $s4,    $s4,    2
    j       color_loop_x
    nop
color_loop_x_end:
    addi    $s1,    $s1,    1
    j       color_loop_y
    nop
color_error:
    la      $a0,    colorargerr
    addi    $v0,    $zero,  4
    syscall                         #���������Ϣ
color_end:
    lw      $ra,    0x0($sp)
    lw      $s0,    0x4($sp)
    lw      $s1,    0x8($sp)
    lw      $s2,    0xC($sp)
    lw      $s3,    0x10($sp)
    lw      $s4,    0x14($sp)
    lw      $s5,    0x18($sp)
    addi    $sp,    $sp,    0x1C    #�ָ��Ĵ���
    jr      $ra
    nop
hello:
    la      $a0,    helloworld      #�ַ����׵�ַ
    addi    $v0,    $zero,  4       #ϵͳ���÷����
    syscall                         #����ַ���
    jr      $ra
    nop

.data 0x00008000
unknowncmd:
.asciiz "There is no such command.\n"
colorargerr:
.asciiz "Arguments Error!\n"
helloworld:
.asciiz "Hello World!\n"
