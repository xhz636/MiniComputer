#函数名: exception
#功能描述: 默认异常处理程序
#关键寄存器含义:
#   无
exception:
    mfc0    $k0,    $13
    andi    $k1,    $k0,    0x007C  #获取ExcCode
    ori     $k0,    $zero,  0xFE00
    add     $k0,    $k0,    $k1     #计算异常向量地址
    lw      $k1,    0x0($k0)        #获取异常处理入口地址
    jr      $k1
    nop
exception_interrupt:
    mfc0    $k0,    $13
    andi    $k1,    $k0,    0x0800  #时间中断标志位
    bgtz    $k1,    exception_interrupt_timer
    andi    $k1,    $k0,    0x0400  #键盘中断标志位(处于延时槽)
    bgtz    $k1,    exception_interrupt_keyboard
    nop
    eret
exception_interrupt_timer:
    mfc0    $k0,    $11
    li      $k1,    0x017D7840
    addu    $k0,    $k0,    $k1
    mtc0    $k0,    $11
    addi    $sp,    $sp,    -4
    sw      $s0,    0x0($sp)        #s0进栈
    ori     $s0,    $zero,  0xC000  #vram起始地址
    lbu     $k0,    0xF8($s0)       #x
    lbu     $k1,    0xF9($s0)       #y
    sll     $k1,    $k1,    8
    add     $s0,    $s0,    $k1
    add     $s0,    $s0,    $k0     #计算光标所在地址
    ori     $k0,    $zero,  0xC000
    lbu     $k1,    0xFC($k0)       #获取光标闪烁状态
    beq     $k1,    $zero,  exception_interrupt_timer_lighten
    nop
    lbu     $k1,    0xFB($k0)       #获取光标下字符
    sb      $k1,    0x1($s0)        #光标消失
    add     $k1,    $zero,  $zero
    j       exception_interrupt_timer_end
    sb      $k1,    0xFC($k0)       #改变光标闪烁状态(处于延时槽)
exception_interrupt_timer_lighten:
    lbu     $k1,    0xFA($k0)       #获取光标符号
    sb      $k1,    0x1($s0)        #光标出现
    addi    $k1,    $zero,  1
    sb      $k1,    0xFC($k0)       #改变光标闪烁状态
exception_interrupt_timer_end:
    lw      $s0,    0x0($sp)        #s0出栈
    addi    $sp,    $sp,    4
    eret
exception_interrupt_keyboard:
    addi    $sp,    $sp,    -4
    sw      $s0,    0x0($sp)        #s0进栈
    ori     $k1,    $zero,  0xC000
    lb      $s0,    0xF0($k1)       #获取按键扫描码
    lw      $k0,    0xE0($k1)       #获取扫描码缓冲区头指针
    lw      $k1,    0xE4($k1)       #获取扫描码缓冲区尾指针
    sb      $s0,    0x0($k1)        #预保存扫描码
    addi    $k1,    $k1,    1
    ori     $s0,    $zero,  0xC0E0
    bne     $k1,    $s0,    exception_interrupt_keyboard_save
    nop
    ori     $k1,    $zero,  0xC0A0
exception_interrupt_keyboard_save:
    beq     $k0,    $k1,    exception_interrupt_keyboard_end
    ori     $k0,    $zero,  0xC000
    sw      $k1,    0xE4($k0)       #更新尾指针, 完成保存扫描码
    addi    $gp,    $zero,  1
exception_interrupt_keyboard_end:
    lw      $s0,    0x0($sp)        #s0出栈
    addi    $sp,    $sp,    4
    eret
exception_syscall:
    addi    $sp,    $sp,    -4
    sw      $ra,    0x0($sp)
    ori     $k0,    $zero,  0xFF00
    sll     $k1,    $v0,    2
    add     $k0,    $k0,    $k1     #计算系统调用向量地址
    lw      $k1,    0x0($k0)        #获取系统调用入口地址
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
    addi    $k0,    $k0,    4       #跳过断点指令
    mtc0    $k0,    $14
    eret
exception_reserved:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #跳过保留指令
    mfc0    $k1,    $13
    srl     $k1,    $k1,    29
    add     $k0,    $k0,    $k1     #跳过延时槽
    mtc0    $k0,    $14
    eret
exception_overflow:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #跳过产生溢出的指令
    mfc0    $k1,    $13
    srl     $k1,    $k1,    29
    add     $k0,    $k0,    $k1     #跳过延时槽
    mtc0    $k0,    $14
    eret
exception_trap:
    mfc0    $k0,    $14
    addi    $k0,    $k0,    4       #跳过陷阱指令
    mtc0    $k0,    $14
    eret
