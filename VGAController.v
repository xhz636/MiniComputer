`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:43:26 08/28/2016 
// Design Name: 
// Module Name:    VGAController 
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
module VGAController(
    input clk,
    input rst,
    input [7:0] color,
    output reg [9:0] x,
    output reg [8:0] y,
    output reg disp,
    output reg [2:0] r,
    output reg [2:0] g,
    output reg [2:1] b,
    output reg hs,
    output reg vs
    );

    wire [9:0] col, row;
    reg [9:0] h_count, v_count;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end
        else if (h_count == 10'd799) begin
            if (v_count == 10'd520) begin
                v_count <= 10'd0;
            end
            else begin
                v_count <= v_count + 10'd1;
            end
            h_count <= 10'd0;
        end
        else begin
            h_count <= h_count + 10'd1;
        end
    end

    assign col = h_count - (10'd144 - 10'd1);
    assign row = v_count - (10'd31  - 10'd1);
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            x <= 10'd0;
            y <= 9'd0;
            r <= 3'd0;
            g <= 3'd0;
            b <= 2'd0;
            hs <= 1'd0;
            vs <= 1'd0;
            disp <= 1'd0;
        end
        else begin
            x <= col[9:0];
            y <= row[8:0];
            r <= color[7:5];
            g <= color[4:2];
            b <= color[1:0];
            hs <= (h_count >= 10'd96);
            vs <= (v_count >= 10'd2);
            disp <= (h_count >= (10'd144 - 10'd1)) && (h_count < (10'd784 - 10'd1))
                 && (v_count >= (10'd31  - 10'd1)) && (v_count < (10'd511 - 10'd1));
        end
    end

endmodule
