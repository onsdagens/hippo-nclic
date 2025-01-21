`timescale 1ns / 1ps
package pkg_n_clic;
  //localparam priorities = 4;
  //localparam priority_width = $clog2(priorities);
  //localparam type IntPriority = logic [priority_width-1:0];
  
  //localparam int_amount = 8;
  //localparam int_idx_width = $clog2(int_amount);
  //localparam type IntIndex = logic [int_idx_width-1:0];
endpackage

module n_clic
  import pkg_n_clic::*;
  #(
    parameter type IntIndex,
    parameter type IntPriority,
    parameter int_amount
    )
(
  input IntPriority i_priorities[int_amount], 
  input wire i_pendings[int_amount], 
  input wire i_enables[int_amount],

  input logic i_global_ie,

  output wire o_int,
  output IntIndex o_idx,
  output IntPriority o_prio
);

IntPriority filtered_priorities[int_amount];

genvar i;
generate
  for (i=0; i<int_amount; i++) begin
    assign filtered_priorities[i] = '{i_priorities[i] && i_pendings[i] && i_enables[i]};
  end 

endgenerate

  tree #(
    .TreeVal(IntPriority),
    .TreeIdx(IntIndex)
    ) arbitration_tree (
    .values(filtered_priorities),
    .out(out_priority)
  );


endmodule
