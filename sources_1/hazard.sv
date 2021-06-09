module hazard(
    input  logic [4:0] rsD, rtD, rsE, rtE,
    input  logic [4:0] writeregE, writeregM, writeregW,
    input  logic       regwriteE, regwriteM, regwriteW,
    input  logic       memtoregE, memtoregM,
    input  logic [1:0] branchD,
    input  logic [2:0] jumpD,
    input  logic        predict_miss,
    output logic       forwardaD, forwardbD,
    output logic [1:0] forwardaE, forwardbE,
    output             stallF, stallD, flushE, flushD
);

logic lwstallD, branchstallD;

assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);

always_comb begin
    forwardaE = 2'b00;
    forwardbE = 2'b00;
    if (rsE != 0) begin
        if (rsE == writeregM & regwriteM)
            forwardaE = 2'b10;
        else if (rsE == writeregW & regwriteW)
            forwardaE = 2'b01;
        else begin
            forwardaE = 2'b00;
        end
    end
    if (rtE != 0) begin
        if (rtE == writeregM & regwriteM)
            forwardbE = 2'b10;
        else if (rtE == writeregW & regwriteW)
            forwardbE = 2'b01;
        else begin
            forwardbE = 2'b00;
        end
    end
end

assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
assign branchstallD = (branchD[0] | branchD[1] | jumpD[1]) & 
    ((regwriteE & (writeregE == rsD | writeregE == rtD)) |
     (memtoregM & (writeregM == rsD | writeregM == rtD)));

assign stallD = lwstallD | branchstallD;
assign stallF = stallD;
assign flushE = stallD | predict_miss;
assign flushD = predict_miss | jumpD[1];

endmodule