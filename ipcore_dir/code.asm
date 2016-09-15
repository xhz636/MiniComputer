.text 0x00000000
j       initialize
nop
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
initialize:
    mtc0    $zero,  $9              #初始化时钟
    ori     $sp,    $zero,  0xC000  #初始化栈顶
    ori     $t0,    $zero,  0xC0A0
    sw      $t0,    0x00E0($sp)     #扫描码缓冲区头指针
    sw      $t0,    0x00E4($sp)     #扫描码缓冲区尾指针
    ori     $t0,    $zero,  0xFD00
    sw      $t0,    0x00E8($sp)     #键盘缓冲区头指针
    sw      $t0,    0x00EC($sp)     #键盘缓冲区尾指针
    sb      $zero,  0x00F1($sp)     #{Caps Lock, Num Lock,Scroll Lock}
    sb      $zero,  0x00F2($sp)     #扩展码, 断码标志
    sb      $zero,  0x00F3($sp)     #文本模式输入方式
    sb      $zero,  0x00F8($sp)     #初始化光标x位置
    sb      $zero,  0x00F9($sp)     #初始化光标y位置
    ori     $t0,    $zero,  0xDB
    sb      $t0,    0x00FA($sp)     #初始化光标符号
    sb      $zero,  0x00FB($sp)     #初始化光标下字符
    sb      $zero,  0x00FC($sp)     #初始化光标闪烁状态
    ori     $t0,    $zero,  0x70
    jal     clearscreen
    sb      $t0,    0x00FD($sp)     #初始化文本模式颜色(处于延时槽)
    li      $t0,    0x017D7840
    mtc0    $t0,    $11             #设置时钟中断频率为2Hz
    ori     $t0,    $zero,  0x0C01
    j       system
    mtc0    $t0,    $12             #开启时钟中断和键盘中断(处于延时槽)
system:
    ori     $s0,    $zero,  0x0000C000
system_rolling_scancode:
    beq     $gp,    $zero,  system_rolling_scancode
    nop
system_getscancode:
    add     $gp,    $zero,  $zero
    lw      $s1,    0xE0($s0)       #扫描码缓冲区头指针
    lw      $s2,    0xE4($s0)       #扫描码缓冲区尾指针
    lbu     $s3,    0x0($s1)        #扫描码缓冲区首字符
    addi    $s1,    $s1,    1       #扫描码缓冲区头指针加一
    ori     $s4,    $zero,  0xC0E0
    bne     $s1,    $s4,    system_refreshscanhead
    nop
    ori     $s1,    $zero,  0xC0A0  #扫描码缓冲区头指针循环
system_refreshscanhead:
    sw      $s1,    0xE0($s0)       #更新扫描码缓冲区头指针
    lw      $s4,    0xE8($s0)       #键盘缓冲区头指针
    lw      $s5,    0xEC($s0)       #键盘缓冲区尾指针
    ori     $s6,    $zero,  0xF0    #断码
    beq     $s3,    $s6,    system_keyrelease
    ori     $s6,    $zero,  0xE0    #扩展码
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
    ori     $s6,    $s6,    0x1     #释放按键标志记为1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_keyextend:
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x2     #扩展按键标志记为1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_shift:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #释放按键
    bne     $s6,    $zero,  system_shift_release
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x10    #Shift按键标志记为1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_shift_release:
    andi    $s6,    $s6,    0xEC    #清空释放、扩展及Shift标志
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_ctrl:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #释放按键
    bne     $s6,    $zero,  system_ctrl_release
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x8     #Ctrl按键标志记为1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_ctrl_release:
    andi    $s6,    $s6,    0xF4    #清空释放、扩展及Ctrl标志
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_alt:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #释放按键
    bne     $s6,    $zero,  system_alt_release
    lbu     $s6,    0xF2($s0)
    ori     $s6,    $s6,    0x4     #Alt按键标志记为1
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_alt_release:
    andi    $s6,    $s6,    0xF8    #清空释放、扩展及Alt标志
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_print:
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0x1     #释放按键
    beq     $s6,    $zero,  system_input
    nop
    lbu     $s6,    0xF2($s0)
    andi    $s6,    $s6,    0xFC    #清空释放及扩展标志
    sb      $s6,    0xF2($s0)
    j       system_input_end
    nop
system_input:
    add     $a0,    $s3,    $zero   #扫描码
    lbu     $a1,    0xF2($s0)
    andi    $a1,    $a1,    0x10    #Shift标志
    jal     translatekey
    srl     $a1,    $a1,    4
    add     $s3,    $v0,    $zero   #ASCII码
    addi    $v0,    $zero,  11
    add     $a0,    $s3,    $zero
    syscall                         #显示字符
    beq     $s3,    $zero,  system_input_end
    ori     $s6,    $zero,  0x08    #退格
    beq     $s6,    $s3,    system_input_backspace
    ori     $s6,    $zero,  0x0A    #回车
    beq     $s6,    $s3,    system_input_enter
    nop
    sb      $s3,    0x0($s5)
    addi    $s7,    $s5,    1       #键盘缓冲区尾指针加一
    ori     $s6,    $zero,  0xFE00
    bne     $s6,    $s7,    system_input_save
    nop
    addi    $s7,    $zero,  0xFD00  #键盘缓冲区尾指针循环
system_input_save:
    beq     $s7,    $s4,    system_input_end
    nop
    add     $s5,    $s7,    $zero   #更新键盘缓冲区尾指针
    j       system_input_end
    nop
system_input_backspace:
    beq     $s4,    $s5,    system_input_end
    nop
    addi    $s5,    $s5,    -1      #键盘缓冲区尾指针减一
    ori     $s6,    $zero,  0xFCFF
    bne     $s6,    $s5,    system_input_end
    nop
    addi    $s5,    $s5,    0xFDFF  #键盘缓冲区尾指针循环
    j       system_input_end
    nop
system_input_enter:
    jal     program
    nop
    ori     $s4,    $zero,  0xFD00  #清空键盘缓冲区
    ori     $s5,    $zero,  0xFD00  #清空键盘缓冲区
    j       system_input_end
    nop
system_input_end:
    sw      $s4,    0xE8($s0)       #更新键盘缓冲区头指针
    sw      $s5,    0xEC($s0)       #更新键盘缓冲区尾指针
    j       system_rolling_scancode
    nop
program:
    addi    $sp,    $sp,    -0x24   #保存寄存器
    sw      $ra,    0x0($sp)
    sw      $s0,    0x4($sp)
    sw      $s1,    0x8($sp)
    sw      $s2,    0xC($sp)
    sw      $s3,    0x10($sp)
    sw      $s4,    0x14($sp)
    sw      $s5,    0x18($sp)
    sw      $s6,    0x1C($sp)
    sw      $s7,    0x20($sp)
    ori     $s0,    $zero,  0xC000  #vram起始地址
    lw      $s1,    0xE8($s0)       #键盘缓冲区头指针
    lw      $s2,    0xEC($s0)       #键盘缓冲区尾指针
    beq     $s1,    $s2,    program_end
    ori     $s0,    $zero,  0xD000  #程序列表起始地址(处于延时槽)
program_nextstring:
    addi    $s3,    $s0,    0xA0    #程序名起始地址
    add     $s4,    $s1,    $zero
program_comparestring:
    beq     $s4,    $s2,    program_keybufferend
    lbu     $s5,    0x0($s3)        #载入程序名字符(处于延时槽)
    lbu     $s6,    0x0($s4)        #载入键盘缓冲区字符
    ori     $s7,    $zero,  0x20    #空格
    beq     $s7,    $s6,    program_keybufferend
    nop
    beq     $s5,    $zero,  program_stringend
    ori     $s6,    $s6,    0x20    #大写字符转小写字符
    beq     $s5,    $s6,    program_asciiequal
    nop
program_keybufferend:
    beq     $s5,    $zero,  program_loadaddress
    nop
program_stringend:
    addi    $s0,    $s0,    0x100   #下一个程序名
    ori     $s7,    $zero,  0xE000  #程序列表结束
    beq     $s0,    $s7,    program_notfound
    nop
    j       program_nextstring
    nop
program_asciiequal:
    addi    $s3,    $s3,    1       #程序名下一个字符
    addi    $s4,    $s4,    1       #键盘缓冲区下一个字符
    j       program_comparestring
    nop
program_loadaddress:
    ori     $s1,    $zero,  0xC000
    sw      $s4,    0xE8($s1)       #更新键盘缓冲区头指针
    lw      $s0,    0xFC($s0)       #载入程序入口地址
    jalr    $ra,    $s0             #执行程序
    nop
    j       program_end
    nop
program_notfound:
    jal     notfound                #未找到程序
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
    addi    $sp,    $sp,    0x24    #恢复寄存器
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
    andi    $t0,    $v1,    0x0001  #判断最低位是否为1(处于延时槽)
                                    #同时提前将最低位放入t0
    beq     $t0,    $zero,  multiply_plus_a1
    nop
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_shiftout_is_zero:
    bne     $t0,    $zero,  multiply_minus_a1
    nop
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_plus_a1:
    add     $v0,    $v0,    $a1
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_minus_a1:
    sub     $v0,    $v0,    $a1
    j       multiply_shiftright
    addi    $t1,    $t1,    -1      #移位计数器减一(处于延时槽)
multiply_shiftright:
    srl     $v1,    $v1,    1       #低位右移
    andi    $t2,    $v0,    0x0001  #获取高位最低位
    sll     $t2,    $t2,    31
    or      $v1,    $v1,    $t2     #高位最低位放入低位最高位
    bgtz    $t1,    multiply_booth
    sra     $v0,    $v0,    1       #高位右移(处于延时槽)
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
    sll     $v0,    $v0,    1       #高位左移
    slt     $t1,    $v1,    $zero   #获取低位最高位
    or      $v0,    $v0,    $t1     #低位最高位放入高位最低位
    sll     $v1,    $v1,    1       #低位左移
    sub     $t1,    $v0,    $a1     #试商
    bltz    $t1,    divide_shiftleft
    addi    $t0,    $t0,    -1      #移位计数器减一(处于延时槽)
    add     $v0,    $t1,    $zero   #置余数
    ori     $v1,    $v1,    0x0001  #置商
    j       divide_shiftleft
    nop
divide_end:
    jr      $ra
    nop
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
scrollscreen:
    ori     $t0,    $zero,  0xC000  #vram起始地址
    add     $t1,    $zero,  $zero
scrollscreen_loop_y:
    slti    $t3,    $t1,    59      #59行需要向上滚动
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
    lhu     $t7,    0x0($t6)        #将下一行内容复制到上一行中
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
    slti    $t5,    $t2,    160     #最后一行清空
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
    add     $t0,    $t0,    $a0     #计算扫描码偏移量(处于延时槽)
    addi    $t0,    $t0,    0x0080  #增加第二区偏移量
translatekey_noshift:
    jr      $ra
    lbu     $v0,    0x0($t0)        #查找ASCII码(处于延时槽)
asciitobyte:
    ori     $a0,    $a0,    0x20    #大写字符转小写字符
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
    addi    $a0,    $a0,    -0x30   #数字字符
    sll     $v0,    $a0,    4       #结果存高位
    j       asciitobyte_lowascii
    nop
asciitobyte_highhexdigit:
    addi    $a0,    $a0,    -0x57   #英文字符
    sll     $v0,    $a0,    4       #结果存高位
    j       asciitobyte_lowascii
    nop
asciitobyte_lowascii:
    ori     $a1,    $a1,    0x20    #处理第二个字符
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
    or      $v0,    $v0,    $a1     #结果存低位
    j       asciitobyte_end
    nop
asciitobyte_lowhexdigit:
    addi    $a1,    $a1,    -0x57
    or      $v0,    $v0,    $a1     #结果存低位
    j       asciitobyte_end
    nop
asciitobyte_nohex:
    addi    $v0,    $zero,  -1      #错误返回-1
asciitobyte_end:
    jr      $ra
    nop
printstring:
    addi    $sp,    $sp,    -8      #保存寄存器
    sw      $s0,    0x0($sp)
    sw      $ra,    0x4($sp)
    add     $s0,    $a0,    $zero
printstring_continue:
    lbu     $a0,    0x0($s0)        #载入字符串字符
    jal     printcharacter          #输出字符
    nop
    beq     $a0,    $zero,  printstring_end
    nop
    addi    $s0,    $s0,    1
    j       printstring_continue
    nop
printstring_end:
    lw      $s0,    0x0($sp)
    lw      $ra,    0x4($sp)
    addi    $sp,    $sp,    8       #恢复寄存器
    jr      $ra
    nop
printcharacter:
    addi    $sp,    $sp,    -12     #保存寄存器
    sw      $s0,    0x0($sp)
    sw      $s1,    0x4($sp)
    sw      $ra,    0x8($sp)
    ori     $s0,    $zero,  0xC000  #vram起始地址
    lbu     $k0,    0xF8($s0)       #光标x坐标
    lbu     $k1,    0xF9($s0)       #光标y坐标
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $a0,    0x1($s1)        #显示字符
    beq     $a0,    $zero,  printcharacter_end
    ori     $s1,    $zero,  0x08    #退格
    beq     $a0,    $s1,    printcharacter_backspace
    ori     $s1,    $zero,  0x0A    #回车
    beq     $a0,    $s1,    printcharacter_enter
    addi    $k0,    $k0,    2       #光标x坐标加二
    slti    $s1,    $k0,    160     #文本模式一行最多80个字符
    bne     $s1,    $zero,  printcharacter_end
    nop
    add     $k0,    $zero,  $zero
    addi    $k1,    $k1,    1       #光标y坐标加一
    slti    $s1,    $k1,    60      #文本模式最多60行
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen            #向上滚动一行
    addi    $k1,    $k1,    -1      #光标y坐标恢复
    j       printcharacter_end
    nop
printcharacter_backspace:
    addi    $k0,    $k0,    -2      #光标x坐标减二
    bgez    $k0,    printcharacter_backspace_remove
    nop
    beq     $k1,    $zero,  printcharacter_end
    add     $k0,    $zero,  $zero
    addi    $k0,    $zero,  158     #光标x坐标循环至最后
    addi    $k1,    $k1,    -1      #关闭y坐标减一
printcharacter_backspace_remove:
    sll     $s1,    $k1,    8
    add     $s1,    $s1,    $s0
    add     $s1,    $s1,    $k0
    sb      $zero,  0x1($s1)        #清除字符
    j       printcharacter_end
    nop
printcharacter_enter:
    add     $k0,    $zero,  $zero   #光标x坐标置0
    addi    $k1,    $k1,    1       #光标y坐标加一
    slti    $s1,    $k1,    60
    bne     $s1,    $zero,  printcharacter_end
    nop
    jal     scrollscreen            #向上滚动一行
    addi    $k1,    $k1,    -1      #光标y坐标恢复
    j       printcharacter_end
    nop
printcharacter_end:
    sb      $k0,    0xF8($s0)       #更新光标x坐标
    sb      $k1,    0xF9($s0)       #更新光标y坐标
    lw      $s0,    0x0($sp)
    lw      $s1,    0x4($sp)
    lw      $ra,    0x8($sp)
    addi    $sp,    $sp,    12      #恢复寄存器
    jr      $ra
    nop
delay:
    beq     $a0,    $zero,  delay_end
    jal     multiply
    ori     $a1,    $zero,  0xC350  #50000个时钟(处于延时槽)
    addiu   $k0,    $v1,    -410    #减去乘法消耗时间
    sltu    $k1,    $k0,    $v1
    bne     $k1,    $zero,  delay_count
    add     $v1,    $k0,    $zero   #保存减去后的结果(处于延时槽)
    addiu   $v0,    $v0,    -1      #低位不够减, 高位借一
delay_count:
    addiu   $k0,    $v1,    -6
    sltu    $k1,    $k0,    $v1
    beq     $k1,    $zero,  delay_compare
    add     $v1,    $k0,    $zero   #保存减去后的结果(处于延时槽)
    j       delay_count
    nop
delay_compare:
    beq     $v0,    $zero,  delay_end
    addiu   $v0,    $v0,    -1      #高位减一(处于延时槽)
    j       delay_count
    nop
delay_end:
    jr      $ra
    nop
clear:
    addi    $sp,    $sp,    -4      #保存寄存器
    sw      $ra,    0x0($sp)
    ori     $t0,    $zero,  0xC000
    sb      $zero,  0x00F8($t0)     #光标x坐标置0
    sb      $zero,  0x00F9($t0)     #光标y坐标置0
    jal     clearscreen             #清屏
    nop
    lw      $ra,    0x0($sp)
    addi    $sp,    $sp,    4       #恢复寄存器
    jr      $ra
    nop
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
hello:
    la      $a0,    helloworld      #字符串首地址
    addi    $v0,    $zero,  4       #系统调用服务号
    syscall                         #输出字符串
    jr      $ra
    nop

.data 0x00008000
unknowncmd:
.asciiz "There is no such command.\n"
colorargerr:
.asciiz "Arguments Error!\n"
helloworld:
.asciiz "Hello World!\n"
