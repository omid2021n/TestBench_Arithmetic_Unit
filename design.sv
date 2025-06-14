`timescale 1ns / 1ps

// Instruction field macros
`define oper_type IR[31:27]
`define rdst      IR[26:22]   //  R1
`define rsrc1     IR[21:17]   //  R2
`define imm_mode  IR[16]
`define rsrc2     IR[15:11]   //R3
`define isrc      IR[15:0]

// Opcodes
`define movsgpr 5'b00000
`define mov     5'b00001
`define add     5'b00010
`define sub     5'b00011
`define mul     5'b00100
`define and     5'b00101
`define or      5'b00110
`define xor     5'b00111
`define load    5'b01000
`define store   5'b01001

/*

oper_type	31:27	Opcode (type of instruction like add, sub...)
rdst	    26:22	Destination register
rsrc1	    21:17	First source register
imm_mode	16	    Selects between register or immediate
rsrc2	    15:11	Second register (if not using immediate)
isrc	    15:0	Immediate value

*/


module cpu_core;

  reg [31:0] IR;
  reg [15:0] GPR [31:0];   ///    32  GPR      and  size is  16
  reg [15:0] SGPR;
  reg [31:0] mul_res;
  reg [15:0] memory [0:255]; // Simple memory

  always @(*) begin
    case (`oper_type)

      `movsgpr: GPR[`rdst] = SGPR;

      `mov: begin
        if (`imm_mode)
          GPR[`rdst] = `isrc;
        else
          GPR[`rdst] = GPR[`rsrc1];
      end

      `add: begin
        if (`imm_mode)
          GPR[`rdst] = GPR[`rsrc1] + `isrc;
        else
          GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2];
      end

      `sub: begin
        if (`imm_mode)
          GPR[`rdst] = GPR[`rsrc1] - `isrc;
        else
          GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
      end

      `mul: begin
        if (`imm_mode)
          mul_res = GPR[`rsrc1] * `isrc;
        else
          mul_res = GPR[`rsrc1] * GPR[`rsrc2];
        GPR[`rdst] = mul_res[15:0];
        SGPR = mul_res[31:16];
      end

      `and: begin
        if (`imm_mode)
          GPR[`rdst] = GPR[`rsrc1] & `isrc;
        else
          GPR[`rdst] = GPR[`rsrc1] & GPR[`rsrc2];
      end

      `or: begin
        if (`imm_mode)
          GPR[`rdst] = GPR[`rsrc1] | `isrc;
        else
          GPR[`rdst] = GPR[`rsrc1] | GPR[`rsrc2];
      end

      `xor: begin
        if (`imm_mode)
          GPR[`rdst] = GPR[`rsrc1] ^ `isrc;
        else
          GPR[`rdst] = GPR[`rsrc1] ^ GPR[`rsrc2];
      end

      `load: begin
        if (`imm_mode)
          GPR[`rdst] = memory[GPR[`rsrc1] + `isrc];
        else
          GPR[`rdst] = memory[GPR[`rsrc1] + GPR[`rsrc2]];
      end

      `store: begin
        if (`imm_mode)
          memory[GPR[`rsrc1] + `isrc] = GPR[`rdst];
        else
          memory[GPR[`rsrc1] + GPR[`rsrc2]] = GPR[`rdst];
      end

    endcase
  end

endmodule
