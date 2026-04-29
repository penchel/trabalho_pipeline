module ForwardingUnit (
    input  [4:0] idex_rs1,
    input  [4:0] idex_rs2,
    input  [4:0] exmem_rd,
    input  [4:0] memwb_rd,

    input  [6:0] exmem_op,
    input  [6:0] memwb_op,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    localparam NO_FORWARD  = 2'b00;
    localparam FROM_MEM    = 2'b01;
    localparam FROM_WB_ALU = 2'b10;
    localparam FROM_WB_LD  = 2'b11;

    localparam LW    = 7'b000_0011;
    localparam ALUop = 7'b001_0011;

    initial begin
      forwardA = NO_FORWARD;
      forwardB = NO_FORWARD;
    end

    always @(*) begin
        forwardA = NO_FORWARD;
        forwardB = NO_FORWARD;

        // ===== ForwardA (rs1) =====

        // 1) MEM/WB → verificado primeiro (menor prioridade)
        if ((memwb_op == ALUop || memwb_op == LW) && (memwb_rd != 5'd0) && (memwb_rd == idex_rs1)) begin
            if (memwb_op == LW)
                forwardA = FROM_WB_LD;
            else
                forwardA = FROM_WB_ALU;
        end

        // 2) EX/MEM → verificado depois (maior prioridade, sobrescreve)
        if ((exmem_op == ALUop) && (exmem_rd != 5'd0) && (exmem_rd == idex_rs1)) begin
            forwardA = FROM_MEM;
        end

        // ===== ForwardB (rs2) =====

        // 1) MEM/WB → verificado primeiro (menor prioridade)
        if ((memwb_op == ALUop || memwb_op == LW) && (memwb_rd != 5'd0) && (memwb_rd == idex_rs2)) begin
            if (memwb_op == LW)
                forwardB = FROM_WB_LD;
            else
                forwardB = FROM_WB_ALU;
        end

        // 2) EX/MEM → verificado depois (maior prioridade, sobrescreve)
        if ((exmem_op == ALUop) && (exmem_rd != 5'd0) && (exmem_rd == idex_rs2)) begin
            forwardB = FROM_MEM;
        end
    end

endmodule
