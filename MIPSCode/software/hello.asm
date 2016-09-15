#函数名: hello
#功能描述: 实例程序, 输出"Hello World!\n"
#关键寄存器含义:
#   无
hello:
    la      $a0,    helloworld      #字符串首地址
    addi    $v0,    $zero,  4       #系统调用服务号
    syscall                         #输出字符串
    jr      $ra
    nop
.data
helloworld:
.asciiz "Hello World!\n"
