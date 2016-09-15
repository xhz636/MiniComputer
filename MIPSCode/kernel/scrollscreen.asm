#������: scrollscreen
#��������: ���Ϲ���һ���ı�
#�ؼ��Ĵ�������:
#   t0:vram��ʼ��ַ
#   t1:y
#   t2:x
scrollscreen:
    ori     $t0,    $zero,  0xC000  #vram��ʼ��ַ
    add     $t1,    $zero,  $zero
scrollscreen_loop_y:
    slti    $t3,    $t1,    59
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
    lhu     $t7,    0x0($t6)
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
    slti    $t5,    $t2,    160
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
