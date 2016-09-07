`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:23:38 08/28/2016 
// Design Name: 
// Module Name:    PS2KeyboardController 
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
module PS2KeyboardController(
    input clk,
    input rst,
    inout ps2data,
    inout ps2clk,
    input read,
    output [7:0] data,
    output ready,
    input send,
    input [7:0] senddata,
    output overflow
    );

    wire ps2clknegedge;
    reg [9:0] buffer;
    reg [7:0] fifo [15:0];
    reg [3:0] counter, sendcnt;
    reg [3:0] writeptr, readptr;
    reg [1:0] ps2clkcheck;
    reg sending;
    reg [9:0] senddatareg;
    reg dataout, clkout;
    reg databit;
    reg [13:0] timecnt;
    reg ofreg;

    assign ps2data  = dataout ? databit : 1'bz;
    assign ps2clk   = clkout  ? 1'b0    : 1'bz;
    assign data     = fifo[readptr];
    assign ready    = (writeptr != readptr);
    assign overflow = ofreg;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            ps2clkcheck <= 2'b0;
        end
        else begin
            ps2clkcheck <= {ps2clkcheck[0], ps2clk};
        end
    end
    assign ps2clknegedge = ps2clkcheck[1] & ~ps2clkcheck[0];

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            counter  <= 4'b0;
            writeptr <= 4'b0;
            readptr  <= 4'b0;
            ofreg    <= 1'b0;
        end
        else if (ps2clknegedge && (!sending)) begin
            if (counter == 4'd10) begin
                counter <= 4'd0;
                if ((buffer[0] == 1'b0) && (ps2data) && (^buffer[9:1])) begin
                    if ((writeptr + 4'b1) != readptr) begin
                        fifo[writeptr] <= buffer[8:1];
                        writeptr <= writeptr + 4'b1;
                    end
                    else begin
                        ofreg <= 1'b1;
                    end
                end
            end
            else begin
                buffer[counter] <= ps2data;
                counter <= counter + 4'd1;
            end
        end
        else if (read && ready) begin
            readptr <= readptr + 4'b1;
            ofreg <= 1'b0;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            sending <= 1'b0;
            sendcnt <= 4'd0;
            senddatareg <= 8'b0;
            dataout <= 1'b0;
            clkout  <= 1'b0;
            databit <= 1'b1;
            timecnt <= 14'd0;
        end
        else if (send) begin
            sending <= 1'b1;
            sendcnt <= 4'd0;
            senddatareg <= {~(^senddata), senddata, 1'b0};
            dataout <= 1'b0;
            clkout  <= 1'b1;
            databit <= 1'b1;
            timecnt <= 14'd1;
        end
        else if (sending) begin
            if (clkout) begin
                timecnt <= timecnt + 14'd1;
                if (timecnt == 14'd0) begin
                    clkout  <= 1'b0;
                    dataout <= 1'b1;
                    databit <= 1'b0;
                end
            end
            else begin
                if (ps2clknegedge) begin
                    if (sendcnt < 4'd10) begin
                        sendcnt <= sendcnt + 4'd1;
                        timecnt <= 14'd0;
                    end
                    else if (!ps2data) begin
                        sending <= 1'b0;
                    end
                end
                else if ((timecnt == 14'd1500) && (sendcnt != 4'd0)) begin
                    if (sendcnt != 4'd10) begin
                        databit <= senddatareg[sendcnt];
                        timecnt <= 14'd0;
                    end
                    else begin
                        dataout <= 1'b0;
                        databit <= 1'b1;
                    end
                end
                else begin
                    timecnt <= timecnt + 14'd1;
                end
            end
        end
    end

endmodule
