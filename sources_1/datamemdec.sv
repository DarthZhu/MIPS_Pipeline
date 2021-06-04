`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/08 10:52:40
// Design Name: 
// Module Name: DataMemoryDecoder
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


module DataMemoryDecoder(
    input  logic        clk, writeEN,
    input  logic [31:0] addr, writeData,
    output logic [31:0] readData,

    input  logic        IOclock,
    input  logic        reset,
    input  logic        btnL, btnR,
    input  logic [15:0] switch,
    output logic [7:0]  AN,
    output logic        DP,
    output logic [6:0]  A2G
    );
    
    logic pRead, pWrite, mWrite;
    logic [11:0] led;
    logic [31:0] preadData, mreadData;

    assign pRead = (addr[7] == 1'b1) ? 1 : 0;
    assign pWrite = (addr[7] == 1'b1) ? 1 : 0;
    assign mWrite = writeEN & (addr[7] == 1'b0);

    IO io(IOclock, reset, pRead, pWrite, addr[3:2], writeData, preadData,
          btnL, btnR, switch, led);
    dmem dmem(clk, mWrite, addr, writeData, mreadData);
    assign readData = (addr[7] == 1'b1) ? preadData : mreadData;    
    mux7seg sg(IOclock, reset, {switch, 4'b0000, led}, AN, DP, A2G);
    
endmodule
