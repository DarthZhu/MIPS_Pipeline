`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 09:31:35
// Design Name: 
// Module Name: mipspart
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


module flopr #(parameter WIDTH = 8)(
    input logic clk, reset,
    input logic [WIDTH-1 : 0] d,
    output logic [WIDTH-1 : 0] q
);
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset) q <= 0;
        else q <= d;    
    end
endmodule

module adder(
    input logic [31:0] a, b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module sl2(
    input logic [31:0] a,
    output logic [31:0] y
);
    assign y = {a[29:0], 2'b00};
endmodule

module mux2 #(parameter WIDTH = 8)(
    input logic [WIDTH-1:0] d0, d1,
    input logic s,
    output logic [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;    
endmodule

module mux4 #(parameter Width = 32)(
  input        [Width-1:0] d0, d1, d2, d3,
  input        [1:0]       s,
  output logic [Width-1:0] y
);
    always_comb begin
        unique case(s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d3;
        endcase
    end
endmodule

module regfile(
    input logic clk, we3,
    input logic [4:0] ra1, ra2, wa3,
    input logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);
    logic [31:0] rf[31:0];

    always_ff @(posedge clk)
        if (we3) rf[wa3] <= wd3;
    
    assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module signext(
    input logic [15:0] a,
    output logic [31:0] y
);
    assign y = {{16{a[15]}}, a};
endmodule

module alu(
    input logic signed [31:0] a, b,
    input logic [2:0] alucont,
    output logic signed [31:0] result,
    output logic zero
    );
    assign zero = (result == 0);
    always_comb 
        case (alucont)
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b010: result = a + b;
            // 3'b011: not used
            3'b100: result = a & ~b;
            3'b101: result = a | ~b;
            3'b110: result = a - b;
            3'b111: result = a < b;
            default: result = 'x;
        endcase
endmodule
