#函数名: initialize
#功能描述: 系统初始化
#关键寄存器含义:
#   无
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
