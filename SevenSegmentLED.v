`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:00:02 09/01/2016 
// Design Name: 
// Module Name:    SevenSegmentLED 
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
module SevenSegmentLED(
    input [15:0] hexnum,
    input [3:0] point,
    input [3:0] enable,
    input [1:0] scan,
    output [7:0] seg,
    output [3:0] an
    );

    function [6:0] segment;
        input [3:0] num;
        case (num)
            4'h0: segment = 7'b1000000;
            4'h1: segment = 7'b1111001;
            4'h2: segment = 7'b0100100;
            4'h3: segment = 7'b0110000;
            4'h4: segment = 7'b0011001;
            4'h5: segment = 7'b0010010;
            4'h6: segment = 7'b0000010;
            4'h7: segment = 7'b1111000;
            4'h8: segment = 7'b0000000;
            4'h9: segment = 7'b0010000;
            4'hA: segment = 7'b0001000;
            4'hB: segment = 7'b0000011;
            4'hC: segment = 7'b1000110;
            4'hD: segment = 7'b0100001;
            4'hE: segment = 7'b0000110;
            4'hF: segment = 7'b0001110;
            default: segment = 7'b1111111;
        endcase
    endfunction

    function [7:0] select;
        input [1:0] scan;
        input [15:0] hexnum;
        input [3:0] point;
        case (scan)
            2'd0: select = {~point[0],   segment(hexnum[3:0])};
            2'd1: select = {~point[1],   segment(hexnum[7:4])};
            2'd2: select = {~point[2],  segment(hexnum[11:8])};
            2'd3: select = {~point[3], segment(hexnum[15:12])};
        endcase
    endfunction

    assign seg = select(scan, hexnum, point);

    function [3:0] decoder;
        input [1:0] scan;
        case (scan)
            2'd0: decoder = 4'b0001;
            2'd1: decoder = 4'b0010;
            2'd2: decoder = 4'b0100;
            2'd3: decoder = 4'b1000;
        endcase
    endfunction

    assign an = ~(enable & decoder(scan));

endmodule
