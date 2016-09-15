#函数名: color
#功能描述: 改变命令行颜色
#关键寄存器含义:
#   无
color:
    addi    $sp,    $sp,    -0x1C
    sw      $ra,    0x0($sp)
    sw      $s0,    0x4($sp)
    sw      $s1,    0x8($sp)
    sw      $s2,    0xC($sp)
    sw      $s3,    0x10($sp)
    sw      $s4,    0x14($sp)
    sw      $s5,    0x18($sp)
    ori     $s0,    $zero,  0xC000
    lw      $s1,    0xE8($s0)
    lw      $s2,    0xEC($s0)
    ori     $s3,    $zero,  0x20
    beq     $s1,    $s2,    color_error
    nop
color_removespace:
    lbu     $a0,    0x0($s1)
    addi    $s1,    $s1,    1
    beq     $s1,    $s2,    color_error
    nop
    beq     $a0,    $s3,    color_removespace
    nop
    lbu     $a1,    0x0($s1)
    addi    $s1,    $s1,    1
    bne     $s1,    $s2,    color_error
    nop
    jal     asciitobyte
    nop
    andi    $s1,    $v0,    0xF0
    srl     $s1,    $s1,    4
    andi    $s2,    $v0,    0x0F
    beq     $s1,    $s2,    color_error
    nop
    sb      $v0,    0xFD($s0)
    add     $s1,    $zero,  $zero
color_loop_y:
    slti    $s2,    $s1,    60
    beq     $s2,    $zero,  color_end
    nop
    sll     $s3,    $s1,    8
    add     $s3,    $s0,    $s3
    add     $s4,    $zero,  $zero
color_loop_x:
    slti    $s5,    $s4,    160
    beq     $s5,    $zero,  color_loop_x_end
    nop
    add     $s5,    $s3,    $s4
    sb      $v0,    0x0($s5)
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
    syscall
color_end:
    lw      $ra,    0x0($sp)
    lw      $s0,    0x4($sp)
    lw      $s1,    0x8($sp)
    lw      $s2,    0xC($sp)
    lw      $s3,    0x10($sp)
    lw      $s4,    0x14($sp)
    lw      $s5,    0x18($sp)
    addi    $sp,    $sp,    0x1C
    jr      $ra
    nop
.data
colorargerr:
.asciiz "Arguments Error!\n"
