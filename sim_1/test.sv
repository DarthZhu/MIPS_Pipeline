`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/25 08:05:05
// Design Name: 
// Module Name: test
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


// module test();
//     logic clk;
//     logic reset;

//     logic [31:0] writedata, dataadr;
//     logic memwrite;

//     top dut(clk, reset, writedata, dataadr, memwrite);

//     initial
//         begin
//             reset <= 1; #22;
//             reset <= 0;
//         end

//     always
//         begin
//             clk <= 1; #5;
//             clk <= 0; #5;
//         end
    
//     always @(negedge clk)
//         begin
//             if(memwrite) begin
//                 if (dataadr === 84 & writedata === 7) begin
//                     $display("Simulation succeeded");
//                     $stop;
//                 end
//                 else if (dataadr !== 80) begin
//                     $display("Simulation failed");
//                     $stop;
//                 end
//             end
//         end
// endmodule

module test(
    );
    logic           clk;
    logic           reset,L,R;
    logic [15:0]    SW;
    logic [7:0]     AN;
    logic           DP;
    logic [6:0]     A2G;

    top dut(clk, reset, L, R, SW, AN, DP, A2G);
    initial
        begin
            SW <= 16'h1234;
            reset <=1;
            #10;
            reset <=0;
            #10;
            R <= 1;
            #10;
            R <= 0;
            #10;
            L <= 1;
            #10;
            L <= 0;
        end            
        always
            begin
                clk = 1;
                #1;
                clk = 0;
                #1;
            end
endmodule