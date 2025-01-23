// sim_tree
`timescale 1ns / 1ps

module test_tree;
  logic clk;
  logic reset;
  localparam integer Priorities = 4;
  localparam integer PriorityWidth = $clog2(priorities);
  localparam type IntPrio = logic [priorities-1:0];

  localparam integer IntAmount = 8;
  localparam integer IntIdWidth = $clog2(int_amount);
  localparam type IntId = logic [IntIdWidth-1:0];


  IntPrio prio_arr[int_amount];
  logic   pendings[int_amount];
  logic   enableds[int_amount];
  IntId   out;

  assign prio_arr = '{3, 3, 2, 1, 3, 0, 2, 3};
  assign enableds = '{1, 0, 0, 1, 1, 0, 1, 0};
  assign pendings = '{0, 1, 1, 0, 1, 0, 1, 0};

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
