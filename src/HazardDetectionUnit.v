module HazardDetectionUnit (
    input [4:0] idex_rs1,
    input [4:0] idex_rs2,
    input [4:0] exmem_rd,

    input [6:0] idex_op,
    input [6:0] exmem_op,

    output reg stall
);

    localparam LW    = 7'b000_0011;
    localparam SW    = 7'b010_0011;
    localparam BEQ   = 7'b110_0011;
    localparam ALUop = 7'b001_0011;

    initial begin
        stall = 1'b0;
    end

    always @(*) begin
        stall = 1'b0;

        // Load-use hazard:
        // If the instruction in EX/MEM is a load and the instruction in ID/EX
        // uses its destination register, the pipeline must stall one cycle.

        // Quais instruções leem rs1: LW, SW, BEQ, ALUop (ADDI)
        // Quais instruções leem rs2: apenas SW e BEQ (ALUop usa imediato, não rs2)
        if ((exmem_op == LW) && (exmem_rd != 5'd0)) begin
            if ((idex_op == LW  || idex_op == SW || idex_op == BEQ || idex_op == ALUop)
                && (exmem_rd == idex_rs1)) begin
                stall = 1'b1;
            end
            if ((idex_op == SW || idex_op == BEQ)
                && (exmem_rd == idex_rs2)) begin
                stall = 1'b1;
            end
        end

    end

endmodule
