`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/08 09:23:27
// Design Name: 
// Module Name: 7seg
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


`timescale 1ns / 1ps

module mux7seg
(   input logic CLK100MHZ,
    input logic reset,
    input logic [31:0] digit,
    output logic [7:0] AN,
    output logic DP,
    output logic [6:0] A2G
);
    
    logic [2:0] s;
    logic [3:0]  display;
    logic [19:0] clkdiv;
    
    assign s = clkdiv[19:17];
//    assign s = clkdiv[2:0]; // 仿真用
    assign DP = 1;  //关闭小数点
    
    always_comb
    begin
        AN    = 8'b11111111; // 先关闭8个七段数码管
        AN[s] = 0;           // 0-7个轮流点亮
    end
    
    always @(s, digit)
        case (s)
            0 : display = digit[3:0];
            1 : display = digit[7:4];
            2 : display = digit[11:8];
            3 : display = digit[15:12];
            4 : display = digit[19:16];
            5 : display = digit[23:20];
            6 : display = digit[27:24];
            7 : display = digit[31:28];
            default : display = digit[3:0];
        endcase
        
    always_ff @(posedge CLK100MHZ or posedge reset)
    if (reset)
        clkdiv <= 0;
    else
    begin
        clkdiv <= clkdiv + 1;
    end
    
    always_comb
        if (s == 3)
            A2G = 7'b0110111;  // =
        else
        begin
            case (display) 
                'h0 : A2G = 7'b1000000;  // 0
                'h1 : A2G = 7'b1111001;
                'h2 : A2G = 7'b0100100;
                'h3 : A2G = 7'b0110000;
                'h4 : A2G = 7'b0011001;
                'h5 : A2G = 7'b0010010;
                'h6 : A2G = 7'b0000010;
                'h7 : A2G = 7'b1111000;
                'h8 : A2G = 7'b0000000;
                'h9 : A2G = 7'b0010000;
                'hA : A2G = 7'b0001000;
                'hB : A2G = 7'b0000011;
                'hC : A2G = 7'b1000110;
                'hD : A2G = 7'b0100001;
                'hE : A2G = 7'b0000110;   // E
                'hF : A2G = 7'b0001110;   // F
                default: A2G = 7'b1000000;// 0
            endcase
        end 
endmodule
