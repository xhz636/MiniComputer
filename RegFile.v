`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:40:25 09/03/2016 
// Design Name: 
// Module Name:    RegFile 
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
module RegFile(
    input clk,
    input rst,
    input [4:0] raindex,
    input [4:0] rbindex,
    input [4:0] windex,
    input [31:0] data,
    input we,
    output [31:0] outa,
    output [31:0] outb
    );

    reg [31:0] register [1:31];

    assign outa = (raindex == 5'd0) ? 32'b0 : register[raindex];
    assign outb = (rbindex == 5'd0) ? 32'b0 : register[rbindex];

    integer i;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 1; i < 32; i = i + 1) begin
                register[i] <= 32'b0;
            end
        end
        else if (windex != 5'd0 && we) begin
            register[windex] <= data;
        end
    end

endmodule
