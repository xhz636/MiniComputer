`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:06:24 09/03/2016 
// Design Name: 
// Module Name:    ControlUnit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ControlUnit(
    input [5:0] op,
    input [5:0] func,
    input [4:0] rs,
    input [4:0] rt,
    output pcirwrite,
    output [1:0] pcsrc,
    output selrt,
    output [1:0] datasrca,
    output [1:0] datasrcb,
    output signext,
    input rsrtequ,
    input rsgtz,
    input rsltz,
    output aluselsa,
    output aluselimm,
    output [3:0] aluop,
    output withof,
    output withtrap,
    output trapequ,
    output trapneq,
    output trapge,
    output traplt,
    output selpc8,
    output linkra,
    output writemem,
    output readmem,
    output alignbyte,
    output alignhalf,
    output memext,
    output selmem,
    output writereg,
    input ofexcp,
    input trapexcp,
    input [4:0] rdexe,
    input selmemexe,
    input writeregexe,
    input [4:0] rdmem,
    input selmemmem,
    input writeregmem,
    input intr,
    input [7:0] imip,
    output inta,
    output [1:0] selnpc,
    output exl,
    output ie,
    output [1:0] selepc,
    output db,
    output [4:0] exccode,
    output writestatus,
    output writecause,
    output writeepc,
    output mfc0,
    output mtc0,
    output cancel,
    output delayslot,
    input cancelexe,
    input delayslotexe,
    input delayslotmem
    );

    wire Rspecial, Iregimm, Icop0;
    wire R_add, R_addu, R_slt, R_sltu, R_sub, R_subu;
    wire R_jalr, R_jr;
    wire R_nop;
    wire R_and, R_nor, R_or, R_xor;
    wire R_sll, R_sllv, R_sra, R_srav, R_srl, R_srlv;
    wire R_break, R_syscall, R_teq, R_tge, R_tgeu, R_tlt, R_tltu, R_tne;
    wire I_addi, I_addiu, I_slti, I_sltiu;
    wire I_beq, I_bgez, I_bgezal, I_bgtz, I_blez, I_bltz, I_bltzal, I_bne;
    wire I_lb, I_lbu, I_lh, I_lhu, I_lw, I_sb, I_sh, I_sw;
    wire I_andi, I_lui, I_ori, I_xori;
    wire I_teqi, I_tgei, I_tgeiu, I_tlti, I_tltiu, I_tnei;
    wire I_eret, I_mfc0, I_mtc0;
    wire J_j, J_jal;
    wire users, usert, notstop, notcancel;
    wire selaluexe, selalumem, selloadmem;
    wire B_beq, B_bgez, B_bgezal, B_bgtz, B_blez, B_bltz, B_bltzal, B_bne;
    wire unkown, branch;

    assign Rspecial  = op == 6'b000000;
    assign R_add  = Rspecial & (func == 6'b100000);
    assign R_addu = Rspecial & (func == 6'b100001);
    assign R_slt  = Rspecial & (func == 6'b101010);
    assign R_sltu = Rspecial & (func == 6'b101011);
    assign R_sub  = Rspecial & (func == 6'b100010);
    assign R_subu = Rspecial & (func == 6'b100011);
    assign R_jalr = Rspecial & (func == 6'b001001);
    assign R_jr   = Rspecial & (func == 6'b001000);
    assign R_nop  = Rspecial & (func == 6'b000000);
    assign R_and  = Rspecial & (func == 6'b100100);
    assign R_nor  = Rspecial & (func == 6'b100111);
    assign R_or   = Rspecial & (func == 6'b100101);
    assign R_xor  = Rspecial & (func == 6'b100110);
    assign R_sll  = Rspecial & (func == 6'b000000);
    assign R_sllv = Rspecial & (func == 6'b000100);
    assign R_sra  = Rspecial & (func == 6'b000011);
    assign R_srav = Rspecial & (func == 6'b000111);
    assign R_srl  = Rspecial & (func == 6'b000010);
    assign R_srlv = Rspecial & (func == 6'b000110);
    assign R_break= Rspecial & (func == 6'b001101);
    assign R_syscall = Rspecial & (func == 6'b001100);
    assign R_teq  = Rspecial & (func == 6'b110100);
    assign R_tge  = Rspecial & (func == 6'b110000);
    assign R_tgeu = Rspecial & (func == 6'b110001);
    assign R_tlt  = Rspecial & (func == 6'b110010);
    assign R_tltu = Rspecial & (func == 6'b110011);
    assign R_tne  = Rspecial & (func == 6'b110110);

    assign Iregimm = op == 6'b000001;
    assign Icop0   = op == 6'b010000;
    assign I_addi  = op == 6'b001000;
    assign I_addiu = op == 6'b001001;
    assign I_slti  = op == 6'b001010;
    assign I_sltiu = op == 6'b001011;
    assign I_beq   = op == 6'b000100;
    assign I_bgez  = Iregimm & (rt == 5'b00001);
    assign I_bgezal= Iregimm & (rt == 5'b10001);
    assign I_bgtz  = op == 6'b000111;
    assign I_blez  = op == 6'b000110;
    assign I_bltz  = Iregimm & (rt == 5'b00000);
    assign I_bltzal= Iregimm & (rt == 5'b10000);
    assign I_bne   = op == 6'b000101;
    assign I_lb    = op == 6'b100000;
    assign I_lbu   = op == 6'b100100;
    assign I_lh    = op == 6'b100001;
    assign I_lhu   = op == 6'b100101;
    assign I_lw    = op == 6'b100011;
    assign I_sb    = op == 6'b101000;
    assign I_sh    = op == 6'b101001;
    assign I_sw    = op == 6'b101011;
    assign I_andi  = op == 6'b001100;
    assign I_lui   = op == 6'b001111;
    assign I_ori   = op == 6'b001101;
    assign I_xori  = op == 6'b001110;
    assign I_teqi  = Iregimm & (rt == 5'b01100);
    assign I_tgei  = Iregimm & (rt == 5'b01000);
    assign I_tgeiu = Iregimm & (rt == 5'b01001);
    assign I_tlti  = Iregimm & (rt == 5'b01010);
    assign I_tltiu = Iregimm & (rt == 5'b01011);
    assign I_tnei  = Iregimm & (rt == 5'b01110);
    assign I_eret  = Icop0 & (func == 6'b011000) & rs[4];
    assign I_mfc0  = Icop0 & (rs == 5'b00000);
    assign I_mtc0  = Icop0 & (rs == 5'b00100);

    assign J_j   = op == 6'b000010;
    assign J_jal = op == 6'b000011;

    assign users = R_add | R_addu | R_slt | R_sltu | R_sub | R_subu
                 | R_jalr | R_jr
                 | R_and | R_nor | R_or | R_xor
                 | R_sllv | R_srav | R_srlv
                 | R_teq | R_tge | R_tgeu | R_tlt | R_tltu | R_tne
                 | I_addi | I_addiu | I_slti | I_sltiu
                 | I_beq | I_bgez | I_bgezal | I_bgtz
                 | I_blez | I_bltz | I_bltzal | I_bne
                 | I_lb | I_lbu | I_lh | I_lhu | I_lw
                 | I_sb | I_sh | I_sw
                 | I_andi | I_ori | I_xori
                 | I_teqi | I_tgei | I_tgeiu | I_tlti | I_tltiu | I_tnei;
    assign usert = R_add | R_addu | R_slt | R_sltu | R_sub | R_subu
                 | R_and | R_nor | R_or | R_xor
                 | R_sll | R_sllv | R_sra | R_srav | R_srl | R_srlv
                 | R_teq | R_tge | R_tgeu | R_tlt | R_tltu | R_tne
                 | I_beq | I_bne
                 | I_sb | I_sh | I_sw
                 | I_mtc0;
    assign notstop = !(writeregexe && selmemexe && (rdexe != 5'd0)
                       && ((users && (rdexe == rs)) || (usert && (rdexe == rt))));
    assign notcancel = ~(cancelexe | ofexcp | trapexcp) & notstop;

    assign selaluexe = writeregexe && (rdexe != 5'd0) && !selmemexe;
    assign selalumem = writeregmem && (rdmem != 5'd0) && !selmemmem;
    assign selloadmem= writeregmem && (rdmem != 5'd0) &&  selmemmem;

    assign B_beq   = I_beq & rsrtequ;
    assign B_bgez  = I_bgez & ~rsltz;
    assign B_bgezal= I_bgezal & ~rsltz;
    assign B_bgtz  = I_bgtz & rsgtz;
    assign B_blez  = I_blez & ~rsgtz;
    assign B_bltz  = I_bltz & rsltz;
    assign B_bltzal= I_bltzal & rsltz;
    assign B_bne   = I_bne & ~rsrtequ;

    assign unkown = ~(R_add | R_addu | R_slt | R_sltu | R_sub | R_subu
                    | R_jalr | R_jr
                    | R_nop
                    | R_and | R_nor | R_or | R_xor
                    | R_sll | R_sllv | R_sra | R_srav | R_srl | R_srlv
                    | R_break | R_syscall
                    | R_teq | R_tge | R_tgeu | R_tlt | R_tltu | R_tne
                    | I_addi | I_addiu | I_slti | I_sltiu
                    | I_beq | I_bgez | I_bgezal | I_bgtz
                    | I_blez | I_bltz | I_bltzal | I_bne
                    | I_lb | I_lbu | I_lh | I_lhu | I_lw | I_sb | I_sh | I_sw
                    | I_andi | I_lui | I_ori | I_xori
                    | I_teqi | I_tgei | I_tgeiu | I_tlti | I_tltiu | I_tnei
                    | I_eret | I_mfc0 | I_mtc0
                    | J_j | J_jal);
    assign branch = | R_jalr | R_jr
                    | I_beq | I_bgez | I_bgezal | I_bgtz
                    | I_blez | I_bltz | I_bltzal | I_bne
                    | J_j | J_jal;

    assign pcirwrite = notstop;
    assign pcsrc[1] = notcancel &
                    ( R_jalr | R_jr
                    | J_j | J_jal );
    assign pcsrc[0] = notcancel &
                    ( B_beq | B_bgez | B_bgezal | B_bgtz
                    | B_blez | B_bltz | B_bltzal | B_bne
                    | J_j | J_jal );
    assign selrt = I_addi | I_addiu | I_slti | I_sltiu
                 | I_lb | I_lbu | I_lh | I_lhu | I_lw
                 | I_andi | I_lui | I_ori | I_xori
                 | I_mfc0;
    assign datasrca[1] = (selalumem  && (rdmem == rs)) || (selaluexe && (rdexe == rs));
    assign datasrca[0] = (selloadmem && (rdmem == rs)) || (selaluexe && (rdexe == rs));
    assign datasrcb[1] = (selalumem  && (rdmem == rt)) || (selaluexe && (rdexe == rt));
    assign datasrcb[0] = (selloadmem && (rdmem == rt)) || (selaluexe && (rdexe == rt));
    assign signext = I_addi | I_addiu | I_slti | I_sltiu
                   | I_lb | I_lbu | I_lh | I_lhu | I_lw
                   | I_sb | I_sh | I_sw
                   | I_teqi | I_tgei | I_tgeiu | I_tlti | I_tltiu | I_tnei;
    assign aluselsa = R_sll | R_sra | R_srl;
    assign aluselimm = I_addi | I_addiu | I_slti | I_sltiu
                     | I_lb | I_lbu | I_lh | I_lhu | I_lw
                     | I_sb | I_sh | I_sw
                     | I_andi | I_lui | I_ori | I_xori
                     | I_teqi | I_tgei | I_tgeiu | I_tlti | I_tltiu | I_tnei;
    assign aluop[3] = R_xor | R_sll | R_sllv | R_sra | R_srav | R_srl | R_srlv
                    | I_xori;
    assign aluop[2] = R_and | R_nor | R_or
                    | I_andi | I_lui | I_ori;
    assign aluop[1] = R_slt | R_sltu | R_nor | R_or | R_sra | R_srav | R_srl | R_srlv
                    | R_tge | R_tgeu | R_tlt | R_tltu
                    | I_tgei | I_tgeiu | I_tlti | I_tltiu
                    | I_slti | I_sltiu | I_ori;
    assign aluop[0] = R_sltu | R_sub | R_subu | R_or | R_sll | R_sllv | R_srl | R_srlv
                    | R_teq | R_tgeu | R_tltu | R_tne
                    | I_teqi | I_tgeiu | I_tltiu | I_tnei
                    | I_sltiu | I_lui | I_ori;
    assign withof = notcancel & (R_add | R_sub | I_addi);
    assign withtrap = notcancel &
                    ( R_teq | R_tge | R_tgeu | R_tlt | R_tltu | R_tne
                    | I_teqi | I_tgei | I_tgeiu | I_tlti | I_tltiu | I_tnei );
    assign trapequ = R_teq | I_teqi;
    assign trapneq = R_tne | I_tnei;
    assign trapge = R_tge | R_tgeu | I_tgei | I_tgeiu;
    assign traplt = R_tlt | R_tltu | I_tlti | I_tltiu;
    assign selpc8 = R_jalr | B_bgezal | B_bltzal | J_jal;
    assign linkra = B_bgezal | B_bltzal | J_jal;
    assign writemem = notcancel &
                    ( I_sb | I_sh | I_sw );
    assign readmem = notcancel &
                   ( I_lb | I_lbu | I_lh | I_lhu | I_lw );
    assign alignbyte = I_lb | I_lbu | I_sb;
    assign alignhalf = I_lh | I_lhu | I_sh;
    assign memext = I_lb | I_lh;
    assign selmem = I_lb | I_lbu | I_lh | I_lhu | I_lw;
    assign writereg = notcancel &
                    ( R_add | R_addu | R_slt | R_sltu | R_sub | R_subu
                    | R_jalr
                    | R_and | R_nor | R_or | R_xor
                    | R_sll | R_sllv | R_sra | R_srav | R_srl | R_srlv
                    | I_addi | I_addiu | I_slti | I_sltiu
                    | B_bgezal | B_bltzal
                    | I_lb | I_lbu | I_lh | I_lhu | I_lw
                    | I_andi | I_lui | I_ori | I_xori
                    | I_mfc0
                    | J_jal );

    assign inta = intr & (|imip) & ~cancelexe;
    assign selnpc[1] = ~cancelexe & I_eret;
    assign selnpc[0] = ~cancelexe &
                     ( inta | R_break | R_syscall | unkown | ofexcp | trapexcp );
    assign exl = (R_break | R_syscall | unkown | ofexcp | trapexcp) & ~I_eret;
    assign ie = ~inta | I_eret;
    assign selepc[1] = (unkown & delayslotexe) | ofexcp | trapexcp;
    assign selepc[0] = (inta & branch) | R_break | R_syscall | (unkown & ~delayslotexe)
                     | (ofexcp & delayslotmem) | (trapexcp & delayslotmem);
    assign db = (inta & delayslotexe) | (unkown & delayslotexe)
              | (ofexcp & delayslotmem) | (trapexcp & delayslotmem);
    assign exccode[4] = 1'b0;
    assign exccode[3] = R_break | R_syscall | unkown | ofexcp | trapexcp;
    assign exccode[2] = ofexcp | trapexcp;
    assign exccode[1] = unkown;
    assign exccode[0] = R_break | trapexcp;
    assign writestatus = ~cancelexe &
                       ( inta
                       | R_break | R_syscall | unkown | ofexcp | trapexcp
                       | I_eret );
    assign writecause  = ~cancelexe &
                       ( inta | R_break | R_syscall | unkown | ofexcp | trapexcp );
    assign writeepc    = ~cancelexe &
                       ( inta | R_break | R_syscall | unkown | ofexcp | trapexcp );
    assign mfc0 = ~cancelexe & I_mfc0;
    assign mtc0 = ~cancelexe & I_mtc0;
    assign cancel = ~cancelexe &
                  ( inta | R_break | R_syscall | unkown | ofexcp | trapexcp | I_eret );
    assign delayslot = ~cancelexe & branch;

endmodule
