#函数名: clearscreen
#功能描述: 清除屏幕所有文本, 但不改变文本模式的颜色
#关键寄存器含义:
#   t0:vram起始地址
#   t1:y
#   t4:x
#   t9:文本模式颜色
clearscreen:
    ori     $t8,    $zero,  0xC0FD  #文本模式颜色地址
    lb      $t9,    0x0($t8)
    sll     $t9,    $t9,    8
    ori     $t0,    $zero,  0xC000  #vram起始地址
    add     $t1,    $zero,  $zero
clearscreen_loop_y:
    slti    $t2,    $t1,    60      #文本模式有60行
    beq     $t2,    $zero,  clearscreen_loop_y_end
    nop
    sll     $t3,    $t1,    8
    add     $t3,    $t0,    $t3
    add     $t4,    $zero,  $zero
clearscreen_loop_x:
    slti    $t5,    $t4,    160     #文本模式每行80个字符
                                    #每个字符占2bytes:(color,ascii)
    beq     $t5,    $zero,  clearscreen_loop_x_end
    nop
    add     $t6,    $t3,    $t4
    sh      $t9,    0x0($t6)        #填入颜色和0字符
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
