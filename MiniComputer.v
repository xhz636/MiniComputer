`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:13:44 08/28/2016 
// Design Name: 
// Module Name:    MiniComputer 
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
module MiniComputer(
    input clk,
    input [7:0] sw,
    input [4:0] btn,
    output [7:0] seg,
    output [3:0] an,
    output [7:0] Led,
    output [2:0] vgaRed,
    output [2:0] vgaGreen,
    output [2:1] vgaBlue,
    output Hsync,
    output Vsync,
    inout PS2KeyboardData,
    inout PS2KeyboardClk
    );

    wire [7:0] swsignal;
    wire [4:0] btnsignal, btnpulse;
    wire rst = btnsignal[0];
    wire [7:0] vgacolor;
    wire [9:0] x;
    wire [8:0] y;
    wire display;
    wire [7:0] fontout, bgcolor, fgcolor;
    wire [31:0] pc, inst, readdata, writedata, memdataout, dataaddr, memaddr;
    wire [7:0] ps2dataout;
    wire read;
    wire [3:0] write;
    wire ioread, iowrite, iointr, ps2ready, ps2of;

    reg clk_50mhz, clk_25mhz;
    always @ (posedge clk) begin
        clk_50mhz <= ~clk_50mhz;
    end
    always @ (posedge clk_50mhz) begin
        clk_25mhz <= ~clk_25mhz;
    end

    Filter filter(clk_50mhz, sw, btn, swsignal, btnsignal, btnpulse);

    assign memaddr  = read ? dataaddr : {16'b0, 2'b11, y[8:3], x[9:2]};
    assign iointr   = ps2ready;
    assign readdata = ioread ? {24'd0, ps2dataout} : memdataout;

    PipelinedCPU pcpu(clk_50mhz, rst,
                      pc, inst,
                      readdata, writedata, read, write, dataaddr,
                      ioread, iowrite, iointr);

    ROM_32kx32 instmem(~clk_50mhz, pc, inst);

    RAM_32kx32 datamem(~clk_50mhz, write, memaddr, writedata, memdataout);

    PS2KeyboardController keyboardctrl(clk_50mhz, rst,
                                       PS2KeyboardData, PS2KeyboardClk,
                                       ioread, ps2dataout, ps2ready,
                                       iowrite, writedata[7:0],
                                       ps2of);

    VGAController vgactrl(clk_25mhz, rst,
                          vgacolor, x, y, disp,
                          vgaRed, vgaGreen, vgaBlue, Hsync, Vsync);
    reg [7:0] ascii, color, dot;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            ascii <= 8'b0;
            color <= 8'b0;
            dot   <= 8'b0;
        end
        else if (!read && display) begin
            ascii <= x[3] ? memdataout[7:0]  : memdataout[23:16];
            color <= x[3] ? memdataout[15:8] : memdataout[31:24];
            dot   <= fontout;
        end
    end
    FontTable_8x8 font(~clk, {ascii, y[2:0]}, fontout);
    VGAColor colordecode(color, bgcolor, fgcolor);
    assign vgacolor = dot[x[2:0]] ? fgcolor : bgcolor;

    reg [15:0] scancnt;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            scancnt <= 16'b0;
        end
        else begin
            scancnt <= scancnt + 16'd1;
        end
    end
    SevenSegmentLED seg7(pc[17:2], 4'b0, 4'b1111, scancnt[15:14], seg, an);
    assign Led = 8'b0;

endmodule
