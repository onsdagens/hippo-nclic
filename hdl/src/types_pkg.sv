`timescale 1ns / 1ps

package types_pkg;

  localparam integer Priorities = 8;
  localparam integer PrioWidth = $clog2(Priorities);
  typedef logic [PrioWidth-1:0] IntPrio;

  localparam integer IntAmount = 8;
  localparam integer IntIdxWidth = $clog2(IntAmount);
  typedef logic [IntIdxWidth-1:0] IntIdx;

  // CSR Related
  typedef logic [11:0] CsrAddrT;

  typedef enum logic [2:0] {
    ECALL  = 3'b000,
    // EBREAK = 3'b000,
    CSRRW  = 3'b001,
    CSRRS  = 3'b010,
    CSRRC  = 3'b011,
    CSRRWI = 3'b101,
    CSRRSI = 3'b110,
    CSRRCI = 3'b111
  } csr_op_t;

  typedef logic [4:0] r;
  typedef logic [31:0] word;


  typedef struct packed {
    IntPrio prio;
    logic   enabled;
    logic   pending;
  } int_config_t;
endpackage
