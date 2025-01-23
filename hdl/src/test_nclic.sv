// sim_tree
`timescale 1ns / 1ps

module test_nclic;
  logic clk;
  logic reset;
  localparam integer Priorities = 4;
  localparam integer PriorityWidth = $clog2(Priorities);
  localparam type IntPrio = logic [Priorities-1:0];

  localparam integer IntAmount = 8;
  localparam integer IntIdWidth = $clog2(IntAmount);
  localparam type IntId = logic [IntIdWidth-1:0];


  IntPrio prio_arr[IntAmount];
  logic   pendings[IntAmount];
  logic   enableds[IntAmount];

  assign prio_arr = '{0, 3, 2, 1, 3, 0, 2, 3};
  assign enableds = '{1, 0, 0, 1, 1, 0, 1, 0};
  assign pendings = '{0, 1, 1, 0, 0, 0, 1, 0};

  IntPrio prio_out;
  IntId idx_out;

  wire int_out;

  nclic #(
      .IntIndex(IntId),
      .IntPriority(IntPrio),
      .IntAmount(IntAmount)
  ) n_clic_instance (
      .clk  (clk),
      .reset(reset),

      .i_priorities(prio_arr),
      .i_pendings(pendings),
      .i_enables(enableds),

      .i_global_ie(1),
      .mret(0),

      .o_int(int_out),
      .o_idx(idx_out),

      .o_prio(prio_out)

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
    #490;
    assign pendings = '{0, 1, 1, 0, 1, 0, 1, 0};
    #100000;
    $finish;
  end

endmodule
