`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:02:21 09/02/2016 
// Design Name: 
// Module Name:    VGAColor 
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
module VGAColor(
    input [7:0] color,
    output [7:0] bgcolor,
    output [7:0] fgcolor
    );

    parameter black   = 8'h00;
    parameter navy    = 8'h02;
    parameter green   = 8'h10;
    parameter teal    = 8'h12;
    parameter maroon  = 8'h80;
    parameter purple  = 8'h82;
    parameter olive   = 8'h90;
    parameter silver  = 8'hdb;
    parameter gray    = 8'h92;
    parameter blue    = 8'h03;
    parameter lime    = 8'h1c;
    parameter cyan    = 8'h1f;
    parameter red     = 8'he0;
    parameter megenta = 8'he3;
    parameter yellow  = 8'hfc;
    parameter white   = 8'hff;

    function [7:0] colordecode;
        input [3:0] num;
        input [7:0] color0;
        input [7:0] color1;
        input [7:0] color2;
        input [7:0] color3;
        input [7:0] color4;
        input [7:0] color5;
        input [7:0] color6;
        input [7:0] color7;
        input [7:0] color8;
        input [7:0] color9;
        input [7:0] colorA;
        input [7:0] colorB;
        input [7:0] colorC;
        input [7:0] colorD;
        input [7:0] colorE;
        input [7:0] colorF;
        case (num)
            4'h0: colordecode = color0;
            4'h1: colordecode = color1;
            4'h2: colordecode = color2;
            4'h3: colordecode = color3;
            4'h4: colordecode = color4;
            4'h5: colordecode = color5;
            4'h6: colordecode = color6;
            4'h7: colordecode = color7;
            4'h8: colordecode = color8;
            4'h9: colordecode = color9;
            4'hA: colordecode = colorA;
            4'hB: colordecode = colorB;
            4'hC: colordecode = colorC;
            4'hD: colordecode = colorD;
            4'hE: colordecode = colorE;
            4'hF: colordecode = colorF;
        endcase
    endfunction

    assign bgcolor = colordecode(color[7:4],
                                 black, navy, green, teal, maroon, purple, olive, silver,
                                 gray, blue, lime, cyan, red, megenta, yellow, white);

    assign fgcolor = colordecode(color[3:0],
                                 black, navy, green, teal, maroon, purple, olive, silver,
                                 gray, blue, lime, cyan, red, megenta, yellow, white);

endmodule
