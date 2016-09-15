#������: clearscreen
#��������: �����Ļ�����ı�, �����ı��ı�ģʽ����ɫ
#�ؼ��Ĵ�������:
#   t0:vram��ʼ��ַ
#   t1:y
#   t4:x
#   t9:�ı�ģʽ��ɫ
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
