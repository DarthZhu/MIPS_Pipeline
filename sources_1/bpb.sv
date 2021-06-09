module bpb #(
    parameter ENTIRES = 10,
    parameter INDEX_WIDTH = 10
) (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic [31:0] pcF,
    input  logic [31:0] instrF,
    input  logic        miss,
    input  logic        is_branchD,
    output logic        last_taken,
    output logic [31:0] predict_pc
);

    // Parse instr
    logic [5:0]     op;
    logic [31:0]    pc_jump, pc_branch, pcplus4, pc_next;
    logic [31:0]    imm;
    logic           is_branch, is_jump;


    assign op = instrF[31:26];
    signext se_bpb(
        instrF[15:0],
        imm
    );
    assign pcplus4 = pcF + 32'd4;
    assign pc_jump = {pcplus4[31:28], instrF[25:0], 2'b00};
    assign pc_branch = pcplus4 + (imm << 2);

    always_comb begin
        case (op)
            6'b000010, 6'b000011: begin
                {pc_next, is_branch, is_jump} = {pc_jump, 2'b01};      // J, JAL
            end
            6'b000100, 6'b000101: begin
                {pc_next, is_branch, is_jump} = {pc_branch, 2'b10};    // BEQ, BNE
            end
            default: begin
                {pc_next, is_branch, is_jump} = {pcplus4, 2'b00};      // JR and others
            end
        endcase
    end

    // BHT
    logic [INDEX_WIDTH-1:0] index;
    logic [1:0]             state;
    logic                   real_taken;

    assign real_taken = last_taken ^ miss;
    assign index = pcF[INDEX_WIDTH+1 : 2];   

    bht bht(
        clk,
        reset,
        en,
        is_branchD,
        real_taken,
        index,
        state
    );

    // Predict
    always_comb begin
        if (reset) begin
            last_taken <= 0;
        end
        else if (en) begin
            last_taken = state[1] | is_jump;
            predict_pc = is_jump | (last_taken & is_branch) ? pc_next : pcplus4;
        end
    end
endmodule

module bht #(
    parameter SIZE_WIDTH = 10,
    parameter INDEX_WIDTH = 10
) (
    input  logic                    clk,
    input  logic                    reset,
    input  logic                    en,
    input  logic                    update_en,
    input  logic                    last_taken,
    input  logic [INDEX_WIDTH-1: 0] index,
    output logic [1:0]              state
);
    localparam                  SIZE = 2 ** SIZE_WIDTH;
    logic [1:0]                 entries[SIZE-1 : 0];
    logic [1:0]                 entry;
    logic [INDEX_WIDTH-1 : 0]   last_index;

    state_switch sw(
        last_taken,
        entries[last_index],
        entry
    );

    always_ff @(posedge clk) begin
        if (reset) begin
            entries <= '{default: '0};
            last_index <= 0;
        end
        else if (en) begin
            if (update_en)
                entries[last_index] <= entry;
            last_index <= index;
        end
    end

    assign state = entries[index];
endmodule

module state_switch (
  input              last_taken,
  input        [1:0] prev_state,
  output logic [1:0] next_state
);
  always_comb begin
    unique case (prev_state)
      2'b00:   next_state = last_taken ? 2'b01 : 2'b00;
      2'b11:   next_state = last_taken ? 2'b11 : 2'b10;
      default: next_state = last_taken ? prev_state + 1 : prev_state - 1;
    endcase
  end
endmodule