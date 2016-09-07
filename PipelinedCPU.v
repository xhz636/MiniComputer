`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:54:20 09/02/2016 
// Design Name: 
// Module Name:    PipelinedCPU 
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
module PipelinedCPU(
    input clk,
    input rst,
    output [31:0] pcaddr,
    input [31:0] inst,
    input [31:0] datain,
    output [31:0] dataout,
    output memread,
    output [3:0] memwrite,
    output [31:0] dataaddr,
    output ioread,
    output iowrite,
    input iointr
    );

/*==============================================================================*/
    reg [31:0] pc;
    wire pcirwrite;
    wire [31:0] nextpc, pcplus4, jumppc, branchpc, pcplus8;
    wire [1:0] pcsrc;
    reg [31:0] pcplus4id, instid;
    wire [5:0] op, func;
    wire [4:0] rs, rt, rd, sa;
    wire [15:0] imm;
    wire [25:0] addr;
    wire [4:0] windex;
    wire [31:0] regfiledatain;
    wire regfilewrite;
    wire [31:0] regfiledataouta, regfiledataoutb;
    wire [31:0] dataa, datab, eimm;
    wire [4:0] regdest;
    wire selrt;
    wire [1:0] datasrca, datasrcb;
    wire signext;
    wire rsrtequ, rsgtz, rsltz;
    wire aluselsa, aluselimm;
    wire [3:0] aluop;
    wire withof, withtrap, trapequ, trapneq, trapge, traplt;
    wire selpc8, linkra, writemem, readmem;
    wire alignbyte, alignhalf, memext;
    wire selmem, writereg;
    reg [31:0] pcplus4exe, dataexea, dataexeb, eimmexe;
    reg [4:0] regdestexe;
    reg alusaexe, aluimmexe;
    reg [3:0] aluopexe;
    reg withofexe, withtrapexe, trapequexe, trapneqexe, trapgeexe, trapltexe;
    reg selpc8exe, linkraexe, writememexe, readmemexe;
    reg alignbyteexe, alignhalfexe, memextexe;
    reg selmemexe, writeregexe;
    wire [31:0] aludataa, aludatab, aluresult, caldata;
    wire [4:0] rdfinal;
    wire overflow, ofexcp, aluzero, trapexcp;
    reg [31:0] caldatamem, memdatamem;
    reg [4:0] rdfinalmem;
    reg writememmem, readmemmem;
    reg alignbytemem, alignhalfmem, memextmem;
    reg selmemmem, writeregmem;
    wire [31:0] savebyte, savehalf;
    wire [31:0] loadbyte0, loadbyte1, loadbyte2, loadbyte3, loadhalf0, loadhalf1;
    wire [31:0] loaddata;
    reg [31:0] memdatawb, caldatawb;
    reg [4:0] rdfinalwb;
    reg selmemwb, writeregwb;

    parameter baseaddr = 32'h00000008;
    reg [31:0] cp0 [12:14];
    wire [31:0] status, cause, epc;
    wire intr, inta;
    wire [7:0] imip;
    wire [1:0] selnpc;
    reg [31:0] pcid, pcexe, pcmem;
    wire exl, ie;
    wire [1:0] selepc;
    wire db;
    wire [7:0] ip;
    wire [4:0] exccode;
    wire writestatus, writecause, writeepc;
    wire [31:0] statusdata, causedata, epcdata;
    wire mfc0, mtc0;
    reg mfc0exe;
    wire cancel, delayslot;
    reg cancelexe, delayslotexe, delayslotmem;
    wire writeregwithof;
/*==============================================================================*/

/*==============================================================================*/
    function [31:0] mux32_4x1;
        input [1:0] sel;
        input [31:0] i0;
        input [31:0] i1;
        input [31:0] i2;
        input [31:0] i3;
        case (sel)
            2'd0: mux32_4x1 = i0;
            2'd1: mux32_4x1 = i1;
            2'd2: mux32_4x1 = i2;
            2'd3: mux32_4x1 = i3;
        endcase
    endfunction

    function [31:0] mux32_2x1;
        input sel;
        input [31:0] i0;
        input [31:0] i1;
        case (sel)
            1'b0: mux32_2x1 = i0;
            1'b1: mux32_2x1 = i1;
        endcase
    endfunction

    function [4:0] mux5_2x1;
        input sel;
        input [4:0] i0;
        input [4:0] i1;
        case (sel)
            1'b0: mux5_2x1 = i0;
            1'b1: mux5_2x1 = i1;
        endcase
    endfunction

    function [3:0] bytedecode;
        input [1:0] byteaddr;
        case (byteaddr)
            2'b00: bytedecode = 4'b1000;
            2'b01: bytedecode = 4'b0100;
            2'b10: bytedecode = 4'b0010;
            2'b11: bytedecode = 4'b0001;
        endcase
    endfunction

    function [3:0] halfdecode;
        input halfaddr;
        case (halfaddr)
            1'b0: halfdecode = 4'b1100;
            1'b1: halfdecode = 4'b0011;
        endcase
    endfunction
/*==============================================================================*/

/*==============================================================================*/
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end
        else if (pcirwrite) begin
            pc <= nextpc;
        end
    end
/*==============================================================================*/

/*==============================================================================*/
    assign pcplus4 = pc + 32'd4;
    assign nextpc = mux32_4x1(selnpc,
                              mux32_4x1(pcsrc, pcplus4, branchpc, dataa, jumppc),
                              baseaddr,
                              epc,
                              32'b0);
    assign pcaddr = pc;
/*==============================================================================*/

/*==============================================================================*/
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            pcplus4id <= 32'b0;
            instid    <= 32'b0;
            pcid      <= 32'b0;
        end
        else if (pcirwrite) begin
            pcplus4id <= pcplus4;
            instid    <= inst;
            pcid      <= pc;
        end
    end
/*==============================================================================*/

/*==============================================================================*/
    assign op   = instid[31:26];
    assign rs   = instid[25:21];
    assign rt   = instid[20:16];
    assign rd   = instid[15:11];
    assign func = instid[5:0];
    assign imm  = instid[15:0];
    assign addr = instid[25:0];

    assign jumppc   = {pcplus4id[31:28], addr, 2'b00};
    assign branchpc = pcplus4id + {{14{imm[15]}}, imm, 2'b00};

    ControlUnit ctrl(op, func, rs, rt,
                     pcirwrite, pcsrc,
                     selrt, datasrca, datasrcb, signext,
                     rsrtequ, rsgtz, rsltz,
                     aluselsa, aluselimm, aluop,
                     withof, withtrap, trapequ, trapneq, trapge, traplt,
                     selpc8, linkra, writemem, readmem,
                     alignbyte, alignhalf, memext,
                     selmem, writereg,
                     ofexcp, trapexcp, rdfinal, selmemexe, writeregexe,
                     rdfinalmem, selmemmem, writeregmem,
                     intr, imip, inta, selnpc, exl, ie, selepc, db, exccode,
                     writestatus, writecause, writeepc, mfc0, mtc0,
                     cancel, delayslot, cancelexe, delayslotexe, delayslotmem);

    RegFile regfile(~clk, rst, rs, rt, windex, regfiledatain, regfilewrite,
                    regfiledataouta, regfiledataoutb);

    assign dataa   = mux32_4x1(datasrca, regfiledataouta, loaddata, caldatamem, caldata);
    assign datab   = mux32_4x1(datasrcb, regfiledataoutb, loaddata, caldatamem, caldata);
    assign eimm    = {{16{signext & imm[15]}}, imm};
    assign regdest = mux5_2x1(selrt, rd, rt);
    assign rsrtequ = dataa == datab;
    assign rsgtz   = ~dataa[31] & (|dataa);
    assign rsltz   =  dataa[31];

    assign ip   = {5'b00000, iointr, 2'b00};
    assign imip = status[15:8] & ip;
    assign intr = iointr & ~status[1] & status[0];
    assign statusdata = mux32_2x1(mtc0, {status[31:2], exl, ie}, datab);
    assign causedata  = mux32_2x1(mtc0, {db, cause[30:16], ip, 1'b0, exccode, 2'b00}, datab);
    assign epcdata    = mux32_2x1(mtc0, mux32_4x1(selepc, pc, pcid, pcexe, pcmem), datab);
    assign status = cp0[12];
    assign cause  = cp0[13];
    assign epc    = cp0[14];
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            cp0[12] <= 32'b0;
            cp0[13] <= 32'b0;
            cp0[14] <= 32'b0;
        end
        else begin
            if (writestatus || (mtc0 && rd == 5'd12)) begin
                cp0[12] <= statusdata;
            end
            if (writecause  || (mtc0 && rd == 5'd13)) begin
                cp0[13] <= causedata;
            end
            if (writeepc    || (mtc0 && rd == 5'd14)) begin
                cp0[14] <= epcdata;
            end
        end
    end
/*==============================================================================*/

/*==============================================================================*/
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            pcplus4exe  <= 32'b0;
            dataexea    <= 32'b0;
            dataexeb    <= 32'b0;
            eimmexe     <= 32'b0;
            regdestexe  <= 5'b0;
            alusaexe    <= 1'b0;
            aluimmexe   <= 1'b0;
            aluopexe    <= 4'b0;
            withofexe   <= 1'b0;
            withtrapexe <= 1'b0;
            trapequexe  <= 1'b0;
            trapneqexe  <= 1'b0;
            trapgeexe   <= 1'b0;
            trapltexe   <= 1'b0;
            selpc8exe   <= 1'b0;
            linkraexe   <= 1'b0;
            writememexe <= 1'b0;
            readmemexe  <= 1'b0;
            alignbyteexe<= 1'b0;
            alignhalfexe<= 1'b0;
            memextexe   <= 1'b0;
            selmemexe   <= 1'b0;
            writeregexe <= 1'b0;
            pcexe       <= 32'b0;
            mfc0exe     <= 1'b0;
            cancelexe   <= 1'b0;
            delayslotexe<= 1'b0;
        end
        else begin
            pcplus4exe  <= pcplus4id;
            dataexea    <= dataa;
            dataexeb    <= datab;
            eimmexe     <= eimm;
            regdestexe  <= regdest;
            alusaexe    <= aluselsa;
            aluimmexe   <= aluselimm;
            aluopexe    <= aluop;
            withofexe   <= withof;
            withtrapexe <= withtrap;
            trapequexe  <= trapequ;
            trapneqexe  <= trapneq;
            trapgeexe   <= trapge;
            trapltexe   <= traplt;
            selpc8exe   <= selpc8;
            linkraexe   <= linkra;
            writememexe <= writemem;
            readmemexe  <= readmem;
            alignbyteexe<= alignbyte;
            alignhalfexe<= alignhalf;
            memextexe   <= memext;
            selmemexe   <= selmem;
            writeregexe <= writereg;
            pcexe       <= pcid;
            mfc0exe     <= mfc0;
            cancelexe   <= cancel;
            delayslotexe<= delayslot;
        end
    end
/*==============================================================================*/

/*==============================================================================*/
    assign sa = eimmexe[10:6];
    assign aludataa = mux32_2x1(alusaexe, dataexea, {27'b0, sa});
    assign aludatab = mux32_2x1(aluimmexe, dataexeb, eimmexe);

    ALU alu(aludataa, aludatab, aluopexe, aluresult, overflow);

    assign pcplus8 = pcplus4exe + 32'd4;
    assign caldata = mux32_4x1({mfc0exe, selpc8exe},
                               aluresult, pcplus8, cp0[eimmexe[15:11]], 32'b0);
    assign rdfinal = {5{linkraexe}} | regdestexe;
    assign ofexcp  = withofexe & overflow;
    assign aluzero = ~|aluresult;
    assign trapexcp= withtrapexe &
                   ( (trapequexe & aluzero)
                   | (trapneqexe & ~aluzero)
                   | (trapgeexe & ~aluresult[0])
                   | (trapltexe & aluresult[0]) );
    assign writeregwithof = writeregexe & ~ofexcp;
/*==============================================================================*/

/*==============================================================================*/
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            caldatamem  <= 32'b0;
            memdatamem  <= 32'b0;
            rdfinalmem  <= 5'b0;
            writememmem <= 1'b0;
            readmemmem  <= 1'b0;
            alignbytemem<= 1'b0;
            alignhalfmem<= 1'b0;
            memextmem   <= 1'b0;
            selmemmem   <= 1'b0;
            writeregmem <= 1'b0;
            pcmem       <= 32'b0;
            delayslotmem<= 1'b0;
        end
        else begin
            caldatamem  <= caldata;
            memdatamem  <= dataexeb;
            rdfinalmem  <= rdfinal;
            writememmem <= writememexe;
            readmemmem  <= readmemexe;
            alignbytemem<= alignbyteexe;
            alignhalfmem<= alignhalfexe;
            memextmem   <= memextexe;
            selmemmem   <= selmemexe;
            writeregmem <= writeregwithof;
            pcmem       <= pcexe;
            delayslotmem<= delayslotexe;
        end
    end
/*==============================================================================*/

/*==============================================================================*/
    assign dataaddr = caldatamem;
    assign savebyte = {4{memdatamem[ 7:0]}};
    assign savehalf = {2{memdatamem[15:0]}};
    assign dataout  = alignbytemem ? savebyte : (alignhalfmem ? savehalf : memdatamem);
    assign memwrite = writememmem ?
                      (
                          alignbytemem ?
                              bytedecode(dataaddr[1:0])
                          :
                          (
                              alignhalfmem ?
                                  halfdecode(dataaddr[1])
                              :
                                  4'b1111
                          )
                      )
                      :
                          4'b0000;
    
    assign memread   = readmemmem;
    assign loadbyte0 = {{24{memextmem & datain[31]}}, datain[31:24]};
    assign loadbyte1 = {{24{memextmem & datain[23]}}, datain[23:16]};
    assign loadbyte2 = {{24{memextmem & datain[15]}}, datain[15: 8]};
    assign loadbyte3 = {{24{memextmem & datain[ 7]}}, datain[ 7: 0]};
    assign loadhalf0 = {{16{memextmem & datain[31]}}, datain[31:16]};
    assign loadhalf1 = {{16{memextmem & datain[15]}}, datain[15: 0]};
    assign loaddata  = alignbytemem ?
                           mux32_4x1(dataaddr[1:0],
                                     loadbyte0, loadbyte1, loadbyte2, loadbyte3)
                       :
                       (
                           alignhalfmem ?
                               mux32_2x1(dataaddr[1], loadhalf0, loadhalf1)
                           :
                               datain
                       );
/*==============================================================================*/

/*==============================================================================*/
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            memdatawb <= 32'b0;
            caldatawb <= 32'b0;
            rdfinalwb <= 5'b0;
            selmemwb  <= 1'b0;
            writeregwb<= 1'b0;
        end
        else begin
            memdatawb <= loaddata;
            caldatawb <= caldatamem;
            rdfinalwb <= rdfinalmem;
            selmemwb  <= selmemmem;
            writeregwb<= writeregmem;
        end
    end
/*==============================================================================*/

/*==============================================================================*/
    assign windex        = rdfinalwb;
    assign regfiledatain = mux32_2x1(selmemwb, caldatawb, memdatawb);
    assign regfilewrite  = writeregwb;
/*==============================================================================*/

endmodule
