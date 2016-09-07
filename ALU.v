`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:01:48 09/02/2016 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] op,
    output [31:0] c,
    output overflow
    );

    //op:
    //0:    add
    //1:    sub
    //2:    slt
    //3:    sltu
    //4:    and
    //5:    lui
    //6:    nor
    //7:    or
    //8:    xor
    //9:    sll
    //10:   sra
    //11:   srl

    wire [31:0] aluadd, alusub, aluslt, alusltu;
    wire [31:0] aluand, alului, alunor, aluor, aluxor;
    wire [31:0] alusll, alusra, alusrl;
    wire [4:0] sa = a[4:0];

    assign aluadd = a + b;
    assign alusub = a - b;
    assign aluslt = $signed(a) < $signed(b);
    assign alusltu= $unsigned(a) < $unsigned(b);
    assign aluand = a & b;
    assign alului = {b[15:0], 16'b0};
    assign alunor = ~aluor;
    assign aluor  = a | b;
    assign aluxor = a ^ b;
    assign alusll = b << sa;
    assign alusra = $signed(b) >>> sa;
    assign alusrl = b >> sa;

    function [31:0] result;
        input [3:0] op;
        input [31:0] aluadd;
        input [31:0] alusub;
        input [31:0] aluslt;
        input [31:0] alusltu;
        input [31:0] aluand;
        input [31:0] alului;
        input [31:0] alunor;
        input [31:0] aluor;
        input [31:0] aluxor;
        input [31:0] alusll;
        input [31:0] alusra;
        input [31:0] alusrl;
        case (op)
            4'd0:  result = aluadd;
            4'd1:  result = alusub;
            4'd2:  result = aluslt;
            4'd3:  result = alusltu;
            4'd4:  result = aluand;
            4'd5:  result = alului;
            4'd6:  result = alunor;
            4'd7:  result = aluor;
            4'd8:  result = aluxor;
            4'd9:  result = alusll;
            4'd10: result = alusra;
            4'd11: result = alusrl;
            default: result = 32'b0;
        endcase
    endfunction

    assign c = result(op,
                      aluadd, alusub, aluslt, alusltu,
                      aluand, alului, alunor, aluor, aluxor,
                      alusll, alusra, alusrl);

    assign overflow = checkof(op, a, b, c);

    function checkof;
        input [3:0] op;
        input [31:0] a;
        input [31:0] b;
        input [31:0] c;
        case (op)
            4'd0: checkof = ~(a[31] ^ b[31]) &  (b[31] ^ c[31]);
            4'd1: checkof =  (a[31] ^ b[31]) & ~(b[31] ^ c[31]);
            default: checkof = 1'b0;
        endcase
    endfunction

endmodule
