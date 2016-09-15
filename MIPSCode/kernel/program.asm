#函数名: program
#功能描述: 执行程序
#关键寄存器含义:
#   无
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
