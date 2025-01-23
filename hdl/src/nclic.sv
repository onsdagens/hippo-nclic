`timescale 1ns / 1ps

module nclic #(
    parameter type IntIndex,
    parameter type IntPriority,
    parameter integer IntAmount
) (
    input wire clk,
    input wire reset,

    input IntPriority i_priorities[IntAmount],
    input wire i_pendings[IntAmount],
    input wire i_enables[IntAmount],

    input logic i_global_ie,
    input logic mret,

    output wire o_int,
    output IntIndex o_idx,
    // this should be enough to index into some rf no?
    // when tail chaining there is potentially some leakage is that fine?
    output IntPriority o_prio


);

  IntPriority filtered_priorities[IntAmount];
  IntIndex out_id;

  // mask all of the configured priorities with their pending and enabled bits
  // this results in all priorities that are not currently pending and enabled being zeroed
  // e.g. they can never be dispatched.
  genvar i;
  generate
    for (i = 0; i < IntAmount; i++) begin : gen_filter
      // these signed casts are to sign extend the single bits into full masks
      assign filtered_priorities[i] = i_priorities[i] &
                                      IntPriority'(signed'(i_pendings[i])) &
                                      IntPriority'(signed'(i_enables[i]));
    end

  endgenerate

  // find the id of the maximum (masked with enabled and pending bits of respective interrupt) priority
  tree #(
      .TreeVal(IntPriority),
      .TreeIdx(IntIndex),
      .TreeWidth(IntAmount)
  ) arbitration_tree (
      .values(filtered_priorities),
      .out(out_id)
  );


  // wire interrupt_out;
  IntPriority running_priority;
  IntIndex running_id;
  // if the running priority is smaller than the max pending + enabled interrupt, and interrupts are enabled globally,
  // dispatch interrupt
  // this should actually check i_prio[tree out] against mintthresh...
  assign o_int = (filtered_priorities[out_id] > i_priorities[running_id]) & i_global_ie;
  assign running_priority = i_priorities[running_id];

  // control the state stack
  IntPriority running_depth;


  always_ff @(posedge clk) begin
    if (reset) begin
      running_id <= 0;
      running_depth <= 0;
    end else if (filtered_priorities[out_id] > running_priority && i_global_ie) begin
      running_id <= out_id;
    end
    if (o_int && !mret) begin
      // if we are dispatching interrupt, go up the stack
      running_depth <= running_depth + 1;
    end else if (!o_int && mret) begin
      // if we are not dispatching interrupt and returning, go back down the stack.
      running_depth <= running_depth - 1;
    end
    // else we are tail chaining, in this case actually do nothing....
  end

endmodule
