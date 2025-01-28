`timescale 1ns / 1ps

module csr_table
  import types_pkg::*;
#(
    parameter type CsrDataT,
    parameter CsrAddrT BottomRange,
    parameter integer TableSize,
    localparam integer TableSizeBits = $clog2(TableSize)
) (
    input logic clk,
    input logic reset,
    input logic csr_enable,
    input CsrAddrT i_csr_addr,
    input csr_op_t csr_op,
    input r rs1_zimm,
    input word rs1_data,

    input CsrDataT ext_data,
    input logic ext_write_enable,
    input logic [TableSizeBits-1:0] ext_idx,

    output CsrDataT direct_out_table[TableSize],
    output CsrDataT out_table[TableSize]
);

  genvar i;
  logic [TableSizeBits-1:0] csr_ext_write_enable;

  generate
    for (i = 0; i < TableSize; i++) begin : gen_table
      csr #(
          .CsrDataT(CsrDataT),
          .Addr(BottomRange + i)
      ) csr (
          .clk(clk),
          .reset(reset),
          .csr_enable(csr_enable),
          .csr_addr(i_csr_addr),
          .csr_op(csr_op),
          .rs1_zimm(rs1_zimm),
          .rs1_data(rs1_data),

          .ext_data(ext_data),
          .ext_write_enable(csr_ext_write_enable[i]),

          .direct_out(direct_out_table[i]),
          .out(out_table[i])
      );
    end
  endgenerate

  always_comb begin
    csr_ext_write_enable = '0;
    csr_ext_write_enable[ext_idx] = ext_write_enable;
  end
endmodule
