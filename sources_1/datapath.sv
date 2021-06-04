`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 09:19:15
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datapath(
    input  logic        clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite,
    input  logic [2:0]  jump,
    input  logic [2:0]  alucontrol,
    output logic        zero,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic [31:0] aluout, writedata,
    input  logic [31:0] readdata,
    input  logic        immext
    );

    logic [4:0] writereg;
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch, signimm, signimmsh, srca, srcb, result, unsignimm, writeregdata;

    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnext, pc);
    adder       pcadd1(pc, 32'b100, pcplus4);
    sl2         immsh(signimm, signimmsh);
    adder       pcadd2(pcplus4, signimmsh, pcbranch);
    mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    mux4 #(32)  pcjumpmux(
        pcnextbr, 
        {pcplus4[31:28], instr[25:0], 2'b00},
        srca,
        'x,    // not used
        jump[1:0],
        pcnext);

    // register file logic
    regfile     rf(clk, regwrite, instr[25:21], instr[20:16], writereg, writeregdata, srca, writedata);
    mux4 #(5) wrmux(
        instr[20:16],
        instr[15:11],
        5'b11111,   // $ra
        'x,
        {jump[2], regdst},
        writereg
    );
    mux2 #(32)  resmux(aluout, readdata, memtoreg, result);
    mux2 #(32)  writeregdata_mux(
        result,
        pcplus4,
        jump[2],
        writeregdata
    );
    signext     se(instr[15:0], signimm);
    
    // ALU logic
    mux2 #(32)  srcbmux(writedata, signimm, alusrc, srcb);
    alu         alu(srca, srcb, alucontrol, aluout, zero);
endmodule
