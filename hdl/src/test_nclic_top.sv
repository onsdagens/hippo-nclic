module test_nclic_top;
  import types_pkg::*;
  logic clk;
  logic reset;


  logic csr_enable;
  CsrAddrT csr_addr;
  csr_op_t csr_op;
  r rs1_zimm;
  word rs1_data;

  int_config_t entry;

  nclic_top #(
      .NoInterrupts(8),
      .CfgAddrBot  (0)
  ) n_clic (
      .clk  (clk),
      .reset(reset),

      // general CSR interface
      .csr_enable(csr_enable),
      .i_csr_addr(csr_addr),
      .csr_op(csr_op),
      .rs1_zimm(rs1_zimm),
      .rs1_data(rs1_data)

  );

  // clock and reset
  initial begin
    $display($time, " << Starting the Simulation >>");

    reset = 1;
    clk = 0;
    csr_enable = 0;
    csr_addr = 0;
    csr_op = CSRRW;
    rs1_zimm = 0;
    rs1_data = 'h0;
    entry = '{0,0,0};
    #15 reset = 0;
  end

  always #10 begin
    clk = ~clk;
    if (clk) $display(">>>>>>>>>>>>> clk posedge", $time);
  end

  initial begin
    #20;
    //csr_enable = 1;
    #20;
    csr_addr = 1;
    //rs1_data = rs1_data + 1;
    #20;
    csr_addr = 2;
    //rs1_data = rs1_data + 1;

    #20;
    csr_addr = 3;
    csr_enable = 1;
    //rs1_data = rs1_data + 1;
    entry = '{3, 1, 1};
    rs1_data = entry;

    #20;
    csr_enable = 0;
    csr_addr   = 4;
    rs1_data   = rs1_data + 1;

    #20;
    csr_addr = 5;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 6;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 7;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 8;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 9;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 10;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 11;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 12;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 13;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 14;
    rs1_data = rs1_data + 1;

    #20;
    csr_addr = 15;
    rs1_data = rs1_data + 1;

    #490;
    #100000;
    $finish;
  end

endmodule
