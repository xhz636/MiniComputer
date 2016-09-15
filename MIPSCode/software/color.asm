#函数名: color
#功能描述: 改变命令行颜色
#关键寄存器含义:
#   无
color:
    addi    $sp,    $sp,    -0x1C   #保存寄存器
    sw      $ra,    0x0($sp)
    sw      $s0,    0x4($sp)
    sw      $s1,    0x8($sp)
    sw      $s2,    0xC($sp)
    sw      $s3,    0x10($sp)
    sw      $s4,    0x14($sp)
    sw      $s5,    0x18($sp)
    ori     $s0,    $zero,  0xC000
    lw      $s1,    0xE8($s0)       #键盘缓冲区头指针
    lw      $s2,    0xEC($s0)       #键盘缓冲区尾指针
    ori     $s3,    $zero,  0x20    #空格
    beq     $s1,    $s2,    color_error
    nop
color_removespace:
    lbu     $a0,    0x0($s1)        #键盘缓冲区首个非空字符
    addi    $s1,    $s1,    1       #键盘缓冲区头指针加一
    beq     $s1,    $s2,    color_error
    nop
    beq     $a0,    $s3,    color_removespace
    nop
    lbu     $a1,    0x0($s1)        #键盘缓冲区第二个非空字符
    addi    $s1,    $s1,    1
    bne     $s1,    $s2,    color_error
    nop
    jal     asciitobyte             #十六进制字符串转换为byte
    nop
    andi    $s1,    $v0,    0xF0
    srl     $s1,    $s1,    4       #高位(背景色)
    andi    $s2,    $v0,    0x0F    #低位(前景色)
    beq     $s1,    $s2,    color_error
    nop
    sb      $v0,    0xFD($s0)       #更新文本模式颜色
    add     $s1,    $zero,  $zero
color_loop_y:
    slti    $s2,    $s1,    60      #文本模式有60行
    beq     $s2,    $zero,  color_end
    nop
    sll     $s3,    $s1,    8
    add     $s3,    $s0,    $s3
    add     $s4,    $zero,  $zero
color_loop_x:
    slti    $s5,    $s4,    160     #文本模式每行80字符
    beq     $s5,    $zero,  color_loop_x_end
    nop
    add     $s5,    $s3,    $s4
    sb      $v0,    0x0($s5)        #填入颜色
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
    syscall                         #输出出错信息
color_end:
    lw      $ra,    0x0($sp)
    lw      $s0,    0x4($sp)
    lw      $s1,    0x8($sp)
    lw      $s2,    0xC($sp)
    lw      $s3,    0x10($sp)
    lw      $s4,    0x14($sp)
    lw      $s5,    0x18($sp)
    addi    $sp,    $sp,    0x1C    #恢复寄存器
    jr      $ra
    nop
.data
colorargerr:
.asciiz "Arguments Error!\n"
