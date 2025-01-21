// test_nclic
`timescale 1ns / 1ps

module sim_tree;
  logic clk;
  logic reset;
localparam priorities = 4;
localparam priority_width = $clog2(priorities);
localparam type IntPriority = logic [priority_width-1:0];

localparam int_amount = 8;
localparam int_id_width = $clog2(int_amount);
localparam type IntIndex = logic [int_id_width-1:0];


 IntPrio priorities[int_amount];
 wire pendings[int_amount];
 wire enables[int_amount];
 IntId idx;
 IntPriority prio;
 wire interrupt;
 assign priorities = '{0,0,3,0,2,1,0,0};
 assign pendings = '{0,1,1,0,1,0,1,1};
 assign enables = '{1,0,0,1,1,1,1};
  n_clic #(
    .IntIndex(IntIndex),
    .IntPriority(IntPriority)
  ) clic (
    .i_priorities(priorities),
    .i_pendings(pendings),
    .i_enables(enables),
    .i_global_ie(1),
    .o_int(interrupt),
    .o_idx(idx),
    .o_prio(prio)
    );

  // clock and reset
  initial begin
    $display($time, " << Starting the Simulation >>");

    reset = 1;
    clk   = 0;
    #15 reset = 0;
  end

  always #10 begin
    clk = ~clk;
    if (clk) $display(">>>>>>>>>>>>> clk posedge", $time);
  end

  initial begin
    $dumpfile("sim_nclic.fst");
    $dumpvars;
    #100000;
    $finish;
  end

endmodule
