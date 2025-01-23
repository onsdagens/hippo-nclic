`timescale 1ns / 1ps

module csr
  import types_pkg::*;
#(
    //parameter integer unsigned CsrWidth = 32,  // default to word
    parameter type CsrDataT,  // this should really be provided by the parent to allow meaningfully
    // structured data (register fields)
    localparam integer unsigned CsrWidth = $bits(CsrDataT),
    parameter CsrDataT ResetValue = CsrDataT'(0),
    parameter CsrAddrT Addr = CsrAddrT'(0),
    parameter logic Read = 1,
    parameter logic Write = 1
) (
    input logic clk,
    input logic reset,
    input logic csr_enable,
    input CsrAddrT csr_addr,
    input csr_op_t csr_op,
    input r rs1_zimm,
    input word rs1_data,

    // external access for side effects
    input CsrDataT ext_data,
    input logic ext_write_enable,
    output word direct_out,  // to use for pend and other immediate side effects
    output word out  // to use for read/write operations, returns old value
);
  CsrDataT tmp;
  CsrDataT data;
  always_comb begin
    tmp = data;
    if (csr_enable && (csr_addr == Addr) && Write) begin
      //$display("@ %h", csr_addr);
      case (csr_op)
        CSRRW: begin
          // side effect on read/write here
          //$display("CSR CSRRW %h", rs1_data);
          tmp = CsrDataT'(rs1_data);
        end
        CSRRS: begin  // set only if rs1 != x0
          if (rs1_zimm != 0) begin
            // side effect here
            //$display("CSR CSRRS %h", rs1_data);
            tmp = data | CsrDataT'(rs1_data);
          end
        end
        CSRRC: begin  // clear only if rs1 != x0
          if (rs1_zimm != 0) begin
            // write side effect here
            //$display("CSR CSRRC %h", rs1_data);
            tmp = data & ~(CsrDataT'(rs1_data));
          end
        end
        CSRRWI: begin
          // use rs1_zimm as immediate
          // write side effect here
          //$display("CSR CSRRWI %h", rs1_zimm);
          tmp = CsrDataT'($unsigned(rs1_zimm));
        end
        CSRRSI: begin
          // use rs1_zimm as immediate
          if (rs1_zimm != 0) begin
            // write side effect here
            //$display("CSR CSRRSI %h", rs1_zimm);
            tmp = data | CsrDataT'($unsigned(rs1_zimm));
          end
        end
        CSRRCI: begin
          // use rs1_zimm as immediate
          if (rs1_zimm != 0) begin
            // write side effect here
            //$display("CSR CSRRCI %h", rs1_zimm);
            tmp = data & (~CsrDataT'($unsigned(rs1_zimm)));
          end
        end
        default: ;
      endcase
    end
  end

  assign direct_out = 32'($unsigned(tmp));
  assign out = (Read) ? 32'($unsigned(data)) : 0;

  always_ff @(posedge clk) begin
    if (reset) begin
      data <= ResetValue;
    end else if (Write) begin
      if (ext_write_enable) begin
        // here we do side effect write
        $display("--- ext data ---");
        data <= ext_data;
      end else data <= tmp;
    end
  end
endmodule
