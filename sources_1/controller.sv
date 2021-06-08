`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 08:53:07
// Design Name: 
// Module Name: controller
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


module controller(
    input  logic        clk, reset,
    input  logic [5:0]  opD, functD,
    input  logic        flushE, equalD,
    output logic        memtoregE, memtoregM, memtoregW, memwriteM,
    output logic        pcsrcD, 
    output logic [1:0]  branchD,
    output logic        alusrcE,
    output logic        regdstE, regwriteE, regwriteM, regwriteW,
    output logic [2:0]  jumpD,
    output logic [2:0]  alucontrolE,
    output logic        immextD
    );

    logic [2:0] aluopD;
    logic       memtoregD, memwriteD, alusrcD, regdstD, regwriteD;
    logic [2:0] alucontrolD;
    logic       memwriteE;

    maindec md(opD, functD, memtoregD, memwriteD, branchD, alusrcD, regdstD, regwriteD, jumpD, aluopD, immextD);
    aludec  ad(functD, aluopD, alucontrolD);

    assign pcsrcD = (branchD[1] & equalD) | (branchD[0] & ~equalD);

    floprc #(8) regE(
        clk, reset, flushE,
        {memtoregD, memwriteD, alusrcD, regdstD, regwriteD, alucontrolD},
        {memtoregE, memwriteE, alusrcE, regdstE, regwriteE, alucontrolE}
    );

    flopr #(3) regM(
        clk, reset, 
        {memtoregE, memwriteE, regwriteE},
        {memtoregM, memwriteM, regwriteM}
    );

    flopr #(2) regW(
        clk, reset,
        {memtoregM, regwriteM},
        {memtoregW, regwriteW}
    );
endmodule

module maindec(
    input  logic [5:0]  op,
    input  logic [5:0]  funct,
    output logic        memtoreg, memwrite,
    output logic [1:0]  branch, //{branch, nbranch}
    output logic        alusrc,
    output logic        regdst, regwrite,
    output logic [2:0]  jump, //{jal, jr, j}
    output logic [2:0]  aluop,
    output logic        immext
    );
    logic [13:0] controls;
    assign {regwrite, regdst, alusrc, branch, memwrite,
            memtoreg, jump, aluop, immext} = controls;
    always_comb
        case(op)                   //  rr_a_bn_mm_jjj_aaa_i
            6'b000000: begin
                case(funct)
                    6'b001000: controls <= 14'b00_0_00_00_010_000_0;  // JR
                    default:   controls <= 14'b11_0_00_00_000_010_0;  // RTYPE
                endcase
            end
            6'b000010: controls <= 14'b00_0_00_00_001_000_0;  // J
            6'b000011: controls <= 14'b10_0_00_00_101_000_0;  // JAL
            6'b100011: controls <= 14'b10_1_00_01_000_000_0;  // LW
            6'b101011: controls <= 14'b00_1_00_10_000_000_0;  // SW
            6'b000100: controls <= 14'b00_0_10_00_000_001_0;  // BEQ
            6'b000101: controls <= 14'b00_0_01_00_000_001_0;  // BNE
            6'b001000: controls <= 14'b10_1_00_00_000_000_0;  // ADDI
            6'b001100: controls <= 14'b10_1_00_00_000_100_1;  // ANDI
            6'b001101: controls <= 14'b10_1_00_00_000_011_1;  // ORI
            6'b001010: controls <= 14'b10_1_00_00_000_101_0;  // SLTI         
            default:   controls <= 14'bxx_x_xx_xx_xxx_xxx_x;  // illegal op
        endcase
endmodule

module aludec(
    input  logic [5:0] funct,
    input  logic [2:0] aluop,
    output logic [2:0] alucontrol
);
    always_comb begin
        case (aluop)
            3'b000: alucontrol <= 3'b010; // ADD
            3'b001: alucontrol <= 3'b110; // SUB
            // 3'b010;  occupied by RTYPE
            3'b011: alucontrol <= 3'b001; // OR
            3'b100: alucontrol <= 3'b000; // AND
            3'b101: alucontrol <= 3'b111; // SLT
            default: case (funct)
                6'b100000: alucontrol <= 3'b010;    // ADD
                6'b100010: alucontrol <= 3'b110;    // SUB
                6'b100100: alucontrol <= 3'b000;    // AND
                6'b100101: alucontrol <= 3'b001;    // OR
                6'b101010: alucontrol <= 3'b111;    // SLT
                default:   alucontrol <= 3'bxxx;
            endcase
        endcase
    end
endmodule
