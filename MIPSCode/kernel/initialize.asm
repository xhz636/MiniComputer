#������: initialize
#��������: ϵͳ��ʼ��
#�ؼ��Ĵ�������:
#   ��
initialize:
    mtc0    $zero,  $9              #��ʼ��ʱ��
    ori     $sp,    $zero,  0xC000  #��ʼ��ջ��
    ori     $t0,    $zero,  0xC0A0
    sw      $t0,    0x00E0($sp)     #ɨ���뻺����ͷָ��
    sw      $t0,    0x00E4($sp)     #ɨ���뻺����βָ��
    ori     $t0,    $zero,  0xFD00
    sw      $t0,    0x00E8($sp)     #���̻�����ͷָ��
    sw      $t0,    0x00EC($sp)     #���̻�����βָ��
    sb      $zero,  0x00F1($sp)     #{Caps Lock, Num Lock,Scroll Lock}
    sb      $zero,  0x00F2($sp)     #��չ��, �����־
    sb      $zero,  0x00F3($sp)     #�ı�ģʽ���뷽ʽ
    sb      $zero,  0x00F8($sp)     #��ʼ�����xλ��
    sb      $zero,  0x00F9($sp)     #��ʼ�����yλ��
    ori     $t0,    $zero,  0xDB
    sb      $t0,    0x00FA($sp)     #��ʼ��������
    sb      $zero,  0x00FB($sp)     #��ʼ��������ַ�
    sb      $zero,  0x00FC($sp)     #��ʼ�������˸״̬
    ori     $t0,    $zero,  0x70
    jal     clearscreen
    sb      $t0,    0x00FD($sp)     #��ʼ���ı�ģʽ��ɫ(������ʱ��)
    li      $t0,    0x017D7840
    mtc0    $t0,    $11             #����ʱ���ж�Ƶ��Ϊ2Hz
    ori     $t0,    $zero,  0x0C01
    j       system
    mtc0    $t0,    $12             #����ʱ���жϺͼ����ж�(������ʱ��)
