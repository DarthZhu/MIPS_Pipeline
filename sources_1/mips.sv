`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 08:38:52
// Design Name: 
// Module Name: mips
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


module mips(
    input  logic        clk, reset,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic        memwriteM,
    output logic [31:0] aluoutM, writedataM,
    input  logic [31:0] readdataM
    );

    logic [5:0] opD, functD;
    logic       regdstE, alusrcE, pcsrcD;
    logic       memtoregE, memtoregM, memtoregW, regwriteE, regwriteM, regwriteW;
    logic [2:0] alucontrolE;
    logic       flushE, equalD;
    logic [1:0] branchD;
    logic [2:0] jumpD;
    logic       immextD;

    controller  c(
        clk,
        reset,
        opD,
        functD,
        flushE,
        equalD,
        memtoregE,
        memtoregM,
        memtoregW,
        memwriteM,
        pcsrcD,
        branchD,
        alusrcE,
        regdstE,
        regwriteE,
        regwriteM,
        regwriteW,
        jumpD,
        alucontrolE,
        immextD
        );
    
    datapath    dp(
        clk,
        reset,
        memtoregE,
        memtoregM,
        memtoregW,
        pcsrcD,
        branchD,
        alusrcE,
        regdstE,
        regwriteE,
        regwriteM,
        regwriteW,
        jumpD,
        alucontrolE,
        equalD,
        pcF,
        instrF,
        aluoutM,
        writedataM,
        readdataM,
        opD,
        functD,
        flushE
    );
    
endmodule
