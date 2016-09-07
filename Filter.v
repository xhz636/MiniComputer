`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:09:04 09/07/2016 
// Design Name: 
// Module Name:    Filter 
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
module Filter(
    input clk,
    input [7:0] sw,
    input [4:0] btn,
    output [7:0] swsignal,
    output [4:0] btnsignal,
    output [4:0] btnpulse
    );

    reg [15:0] cnt;
    reg [1:0] swreg [7:0];
    reg [1:0] btnreg [4:0];

    integer i;
    always @ (posedge clk) begin
        cnt <= cnt + 16'd1;
        if (cnt == 16'd0) begin
            for (i = 0; i < 8; i = i + 1) begin
                swreg[i] <= {swreg[i][0], sw[i]};
            end
            for (i = 0; i < 5; i = i + 1) begin
                btnreg[i] <= {btnreg[i][0], btn[i]};
            end
        end
    end

    assign swsignal[0] = swreg[0][1] & swreg[0][0];
    assign swsignal[1] = swreg[1][1] & swreg[1][0];
    assign swsignal[2] = swreg[2][1] & swreg[2][0];
    assign swsignal[3] = swreg[3][1] & swreg[3][0];
    assign swsignal[4] = swreg[4][1] & swreg[4][0];
    assign swsignal[5] = swreg[5][1] & swreg[5][0];
    assign swsignal[6] = swreg[6][1] & swreg[6][0];
    assign swsignal[7] = swreg[7][1] & swreg[7][0];
    assign btnsignal[0] = btnreg[0][1] & btnreg[0][0];
    assign btnsignal[1] = btnreg[1][1] & btnreg[1][0];
    assign btnsignal[2] = btnreg[2][1] & btnreg[2][0];
    assign btnsignal[3] = btnreg[3][1] & btnreg[3][0];
    assign btnsignal[4] = btnreg[4][1] & btnreg[4][0];
    assign btnpulse[0] = (~btnreg[0][1] & btnreg[0][0]) && cnt == 16'd1;
    assign btnpulse[1] = (~btnreg[1][1] & btnreg[1][0]) && cnt == 16'd1;
    assign btnpulse[2] = (~btnreg[2][1] & btnreg[2][0]) && cnt == 16'd1;
    assign btnpulse[3] = (~btnreg[3][1] & btnreg[3][0]) && cnt == 16'd1;
    assign btnpulse[4] = (~btnreg[4][1] & btnreg[4][0]) && cnt == 16'd1;

endmodule
