#������: notfound
#��������: δ�ҵ�����, ���"There is no such command.\n"
#�ؼ��Ĵ�������:
#   ��
notfound:
    la      $a0,    unknowncmd
    addi    $v0,    $zero,  4
    syscall
    jr      $ra
    nop
.data
unknowncmd:
.asciiz "There is no such command.\n"
