`timescale 1ns / 1ps

module nclic_top
  import types_pkg::*;
#(
    parameter integer  NoInterrupts,
    parameter CsrAddrT CfgAddrBot
) (
    input logic clk,
    input logic reset,

    // general CSR interface
    input logic csr_enable,
    input CsrAddrT i_csr_addr,
    input csr_op_t csr_op,
    input r rs1_zimm,
    input word rs1_data

);

  /// Cfg CSR table
  int_config_t config_direct;
  logic config_direct_write_enable;
  IntIdx config_write_idx;

  int_config_t cfg_direct_out_table[NoInterrupts];
  int_config_t cfg_out_table[NoInterrupts];

  csr_table #(
      .CsrDataT(int_config_t),
      .BottomRange(CfgAddrBot),
      .TableSize(NoInterrupts)
  ) config_table (
      .clk  (clk),
      .reset(reset),

      .csr_enable(csr_enable),
      .i_csr_addr(i_csr_addr),
      .csr_op(csr_op),
      .rs1_zimm(rs1_zimm),
      .rs1_data(rs1_data),

      .ext_data(config_direct),
      .ext_write_enable(config_direct_write_enable),
      .ext_idx(config_write_idx),

      .direct_out_table(cfg_out_table),
      .out_table(cfg_out_table)
  );


  /// Vector CSR table
  // This is related to the instruction memory address width, definitely less
  // than 32 bits in reality.
  typedef logic [31:0] i_mem_addr_t;

  i_mem_addr_t vector_out_table[NoInterrupts];

  // throwaway signals for direct interface
  i_mem_addr_t vector_direct_write;
  logic vector_direct_write_enable;
  i_mem_addr_t vector_direct_out[NoInterrupts];
  IntIdx vector_write_idx;

  assign vector_direct_write = 0;
  assign vector_direct_write_enable = 0;
  assign vector_write_idx = 0;


  csr_table #(
      .CsrDataT(i_mem_addr_t),
      .BottomRange(CfgAddrBot + NoInterrupts),
      .TableSize(NoInterrupts)
  ) vector_table (
      .clk  (clk),
      .reset(reset),

      .csr_enable(csr_enable),
      .i_csr_addr(i_csr_addr),
      .csr_op(csr_op),
      .rs1_zimm(rs1_zimm),
      .rs1_data(rs1_data),
      // not interested in side effects for vector CSRs
      .ext_data(vector_direct_write),
      .ext_write_enable(vector_direct_write_enable),
      .ext_idx(vector_write_idx),

      .direct_out_table(vector_direct_out),
      .out_table(vector_out_table)
  );

  /// Arbitration

  logic clic_int;
  IntIdx clic_idx;
  IntPrio clic_prio;

  IntPrio priorities[IntAmount];
  logic pendings[IntAmount];
  logic enables[IntAmount];

  genvar i;
  generate
    for (i = 0; i < IntAmount; i++) begin : gen_fields
      assign priorities[i] = cfg_out_table[i].prio;
      assign pendings[i] = cfg_out_table[i].pending;
      assign enables[i] = cfg_out_table[i].enabled;
    end
  endgenerate
  nclic #(
      .IntIndex(IntIdx),
      .IntPriority(IntPrio),
      .IntAmount(IntAmount)
  ) arbiter (
      .clk  (clk),
      .reset(reset),

      .i_priorities(priorities),
      .i_pendings(pendings),
      .i_enables(enables),

      .i_global_ie(1),
      .mret(0),

      .o_int (clic_int),
      .o_idx (clic_idx),
      // this should be enough to index into some rf no?
      // when tail chaining there is potentially some leakage is that fine?
      .o_prio(clic_prio)
  );

endmodule
