#������: hello
#��������: ʵ������, ���"Hello World!\n"
#�ؼ��Ĵ�������:
#   ��
hello:
    la      $a0,    helloworld      #�ַ����׵�ַ
    addi    $v0,    $zero,  4       #ϵͳ���÷����
    syscall                         #����ַ���
    jr      $ra
    nop
.data
helloworld:
.asciiz "Hello World!\n"
