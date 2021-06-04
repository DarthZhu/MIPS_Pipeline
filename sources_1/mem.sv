`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 10:19:59
// Design Name: 
// Module Name: mem
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


module imem(
    input logic [5:0] a,
    output logic [31:0] rd
    );
    logic [31:0] RAM[63:0];
    initial begin
        $readmemh("memfile.dat", RAM);
    end
    assign rd = RAM[a];
endmodule

module dmem(
    input logic clk, we,
    input logic [31:0] a, wd,
    output logic [31:0] rd
    );
    logic [31:0] RAM[255:0];
    assign rd = RAM[a[31:2]];
    always_ff @(posedge clk)
        if (we)
            RAM[a[31:2]] <= wd;
endmodule
