// sim_tree
`timescale 1ns / 1ps

module sim_tree;
  logic clk;
  logic reset;
localparam priorities = 4;
localparam priority_width = $clog2(priorities);
localparam type IntPrio = logic [priorities-1:0];

localparam int_amount = 8;
localparam int_id_width = $clog2(int_amount);
localparam type IntId = logic [int_id_width-1:0];


 IntPrio valarr[int_amount];
 IntId out;
 assign valarr = '{0,0,3,0,2,1,0,0};
  tree #(
    .TreeVal(IntPrio),
    .TreeIdx(IntId)
    ) tree_instance (
    .values(valarr),
    .out(out)
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
    $dumpfile("sim_tree.fst");
    $dumpvars;
    #100000;
    $finish;
  end

endmodule
