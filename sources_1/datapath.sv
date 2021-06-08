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
    input  logic        clk, reset, 
    input  logic        memtoregE, memtoregM, memtoregW,
    input  logic        pcsrcD,
    input  logic [1:0]  branchD,
    input  logic        alusrcE, regdstE,
    input  logic        regwriteE, regwriteM, regwriteW,
    input  logic [2:0]  jumpD,
    input  logic [2:0]  alucontrolE,
    output logic        equalD,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic [31:0] aluoutM, writedataM,
    input  logic [31:0] readdataM,
    output logic [5:0]  opD, functD,
    output logic        flushE
    );

    logic           forwardaD, forwardbD;
    logic [1:0]     forwardaE, forwardbE;
    logic           stallF, stallD;
    logic [4:0]     rsD, rtD, rdD, rsE, rtE, rdE;
    logic [4:0]     writeregE, writeregM, writeregW;
    logic           flushD;
    logic [31:0]    pcnextFD, pcnextbrFD, pcplus4F, pcbranchD, pcplus4E;
    logic [31:0]    signimmD, signimmE, signimmshD;
    logic [31:0]    srcaD, srca2D, srcaE, srca2E;
    logic [31:0]    srcbD, srcb2D, srcbE, srcb2E, srcb3E;
    logic [31:0]    pcplus4D, instrD;
    logic [31:0]    aluoutE, aluoutW;
    logic [31:0]    readdataW, resultW;
    logic [31:0]    writedataE;
    logic [2:0]     jumpE;

    // hazard
    hazard  h(
        rsD, rtD, rsE, rtE, writeregE, writeregM, writeregW,
        regwriteE, regwriteM, regwriteW,
        memtoregE, memtoregM,
        branchD, jumpD,
        forwardaD, forwardbD, forwardaE, forwardbE,
        stallF, stallD,
        flushE
    );

    // next PC logic
    mux2 #(32)  pcbrmux(
        pcplus4F,
        pcbranchD,
        pcsrcD,
        pcnextbrFD
    );
    
    mux4 #(32)  pcmux(
        pcnextbrFD,
        {pcplus4D[31:28], instrD[25:0], 2'b00},
        srca2D,
        'x,
        jumpD[1:0],
        pcnextFD
    );

    // register file (decode and writeback)
    regfile     rf(
        clk,
        regwriteW,
        rsD,
        rtD,
        writeregW,
        resultW,
        srcaD,
        srcbD
    );

    // Fetch stage
    flopenr #(32)   pcreg(
        clk,
        reset,
        ~stallF,
        pcnextFD,
        pcF
    );

    adder   pcadd1(
        pcF,
        32'b100,
        pcplus4F
    );

    // Decode Stage
    flopenr #(32)   r1D(
        clk,
        reset,
        ~stallD,
        pcplus4F,
        pcplus4D
    );

    flopenrc #(32)  r2D(
        clk,
        reset,
        ~stallD,
        flushD,
        instrF,
        instrD
    );

    signext     se(
        instrD[15:0],
        signimmD
    );

    sl2         immsh(
        signimmD,
        signimmshD
    );

    adder       pcadd2(
        pcplus4D,
        signimmshD,
        pcbranchD
    );

    mux2 #(32)  forwardadmux(
        srcaD,
        aluoutM,
        forwardaD,
        srca2D
    );

    mux2 #(32)  forwardbdmux(
        srcbD,
        aluoutM,
        forwardbD,
        srcb2D
    );

    eqcmp       comp(
        srca2D,
        srcb2D,
        equalD
    );

    assign opD = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD = instrD[25:21];
    assign rtD = instrD[20:16];
    assign rdD = instrD[15:11];

    assign flushD = pcsrcD | (jumpD[0] | jumpD[1] | jumpD[2]);

    floprc #(3)     jumpReg(
        clk,
        reset,
        flushE,
        jumpD,
        jumpE
    );

    floprc #(32)    pcplus4Reg(
        clk,
        reset,
        flushE,
        pcplus4D,
        pcplus4E
    );

    // Execute stage
    floprc #(32)    r1E(
        clk,
        reset,
        flushE,
        srcaD,
        srcaE
    );

    floprc #(32)    r2E(
        clk,
        reset,
        flushE,
        srcbD,
        srcbE
    );

    floprc #(32)    r3E(
        clk,
        reset,
        flushE,
        signimmD,
        signimmE
    );

    floprc #(5)     r4E(
        clk,
        reset,
        flushE,
        rsD,
        rsE
    );

    floprc #(5)     r5E(
        clk,
        reset,
        flushE,
        rtD,
        rtE
    );

    floprc #(5)     r6E(
        clk,
        reset,
        flushE,
        rdD,
        rdE
    );

    mux4 #(32)      forwardaemux(
        srcaE,
        resultW,
        aluoutM,
        'x,
        forwardaE,
        srca2E
    );

    mux4 #(32)      forwardbemux(
        srcbE,
        resultW,
        aluoutM,
        'x,
        forwardbE,
        srcb2E
    );

    mux2 #(32)      writedatamux(
        srcb2E,
        pcplus4E,
        jumpE[2],
        writedataE
    );

    mux2 #(32)      srcbmux(
        writedataE,
        signimmE,
        alusrcE,
        srcb3E
    );

    alu             alu(
        srca2E,
        srcb3E,
        alucontrolE,
        aluoutE
    );

    mux4 #(32)      wrmux(
        rtE,
        rdE,
        5'b11111,           // $ra
        'x,
        {jumpE[2], regdstE},
        writeregE
    );

    // Memory stage
    flopr #(32)     r1M(
        clk,
        reset,
        writedataE,
        writedataM
    );

    flopr #(32)     r2M(
        clk,
        reset,
        aluoutE,
        aluoutM
    );

    flopr #(5)      r3M(
        clk,
        reset,
        writeregE,
        writeregM
    );

    // Writeback stage
    flopr #(32) r1W(
        clk,
        reset,
        aluoutM,
        aluoutW
    );

    flopr #(32) r2W(
        clk,
        reset,
        readdataM,
        readdataW
    );

    flopr #(32) r3W(
        clk,
        reset,
        writeregM,
        writeregW
    );

    mux2 #(32)      resmux(
        aluoutW,
        readdataW,
        memtoregW,
        resultW
    );
endmodule
