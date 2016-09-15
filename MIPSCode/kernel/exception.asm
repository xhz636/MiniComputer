#������: exception
#��������: Ĭ���쳣�������
#�ؼ��Ĵ�������:
#   ��
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
