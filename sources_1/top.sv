`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 08:31:53
// Design Name: 
// Module Name: top
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


module top (
    // IO input
    input  logic        CLK100MHZ, BTNC, // BTNC FOR RESET
    input  logic        BTNL, BTNR,
    input  logic [15:0] SW,

    // IO output
    output logic [7:0]  AN,
    output logic        DP,
    output logic [6:0]  A2G
    );

    logic [31:0] pc, instr, readdata;
    logic [31:0] writedata,dataadr;
    logic IOclock, Write;

    assign IOclock = ~CLK100MHZ;
    imem imem(pc[7:2], instr);
    mips mips(CLK100MHZ, BTNC, pc, instr, Write, dataadr, writedata, readdata);
    DataMemoryDecoder dmem(CLK100MHZ, Write, dataadr, writedata, readdata,
                           IOclock, BTNC, BTNL, BTNR, SW, AN, DP, A2G);
endmodule