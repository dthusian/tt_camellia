`default_nettype none

/*
# Microcode summary

- key: save register into key_reg
- call: call subroutine
- xor: XOR
- sb1: S-box: 4 1 2 3
- sb2: S-box: 1 2 3 4
- fla: FL part A
- flb: FL part B
- xs1: A XOR (B <<< 8)
- xs2: A XOR (B <<< 16)
- xs3: A XOR (B <<< 24)
- nop: no-op, used for fwd timing
- fwd01: r0, r1 <- r4, r5
- fwd23: r2, r3 <- r4, r5

Fwd takes 2 cycles, everything else is 1 cycle
Calls are zero overhead

subproc reference:
0: keyhelper_a
1: keyhelper_b
2: fa
3: fb
4: fl
5: addkey
6: swaphalves
7: in128

data: (procid 0)
  call in128

key: (procid 1)
  call in128
  call keyhelper1
  call fa
  call fb
  call addkey
  call fa
  call fb
  call keyhelper1
  call keyhelper2

encrypt/decrypt: (procid 2/3)
  call addkey
  call fa
  call fb
  call fa
  call fb
  call fa
  call fb
  call fl
  call fa
  call fb
  call fa
  call fb
  call fa
  call fb
  call fl
  call fa
  call fb
  call fa
  call fb
  call fa
  call fb
  call swaphalves
  call addkey

keyhelper_a:
  key r0
  key r1
  key r2
  key r3

keyhelper_b:
  r4 <- xor r4 r4
  r5 <- xor r5 r5
  nop
  fwd01; fwd23 // TODO?

fa:
  r4 <- sb1 r1 kr
  r5 <- sb2 r0 kr
  r4 <- xs1 r4 r5
  r5 <- xs2 r5 r4
  r4 <- xs3 r4 r5
  r5 <- xs3 r5 r4
  r4 <- xor r2 r4
  r5 <- xor r3 r5
  nop
  fwd23

fb:
  r4 <- sb1 r3 kr
  r5 <- sb2 r2 kr
  r4 <- xs1 r4 r5
  r5 <- xs2 r5 r4
  r4 <- xs3 r4 r5
  r5 <- xs3 r5 r4
  r4 <- xor r2 r4
  r5 <- xor r3 r5
  nop
  fwd01

fl:
  r4 <- fla r3 kr
  r4 <- xor r2 r4
  r5 <- flb r4 kr
  r5 <- xor r3 r5
  nop
  fwd23
  r5 <- flb r0 kr
  r5 <- xor r1 r5
  r4 <- fla r5 kr
  r4 <- xor r0 r4
  nop
  fwd01

addkey:
  r4 <- xor r0 kr
  r5 <- xor r1 kr
  nop
  fwd01
  r4 <- xor r2 kr
  r5 <- xor r3 kr
  nop
  fwd23

swaphalves:
  r4 <- xor r4 r4
  r5 <- xor r5 r5
  r4 <- xor r0 r4
  r5 <- xor r1 r5
  r4 <- xor r2 r4
  r5 <- xor r3 r5
  nop
  fwd01
  r4 <- xor r0 r4
  r5 <- xor r1 r5
  nop
  fwd23
  r4 <- xor r2 r4
  r5 <- xor r3 r5
  r4 <- xor r4 kr
  r5 <- xor r5 kr
  nop
  fwd01
  r4 <- xor r2 kr
  r5 <- xor r3 kr
  nop
  fwd23

in128:
  r4[0] <- input; output <- r2[0]
  r4[1] <- input; output <- r2[1]
  ...
  r5[3] <- input; output <- r3[3]
  nop
  fwd23
  r4[0] <- input; output <- r0[0]
  r4[1] <- input; output <- r0[1]
  ...
  r5[3] <- input; output <- r1[3]
  nop
  fwd01
*/

`define P_DATA 0
`define P_KEY 1
`define P_ENCRYPT 2
`define P_DECRYPT 3

`define SP_KEYHELPER_A 0
`define SP_KEYHELPER_B 1
`define SP_FA 2
`define SP_FB 3
`define SP_FL 4
`define SP_ADDKEY 5
`define SP_SWAPHALVES 6
`define SP_IN128 7

module control(
  input  wire clk,
  input  wire rst,
  input  wire test_mode,
  input  wire cmd_key,
  input  wire cmd_data,
  input  wire cmd_encrypt,
  input  wire cmd_decrypt,
  
  output wire       ready,
  output wire       input_mux,
  output wire [2:0] data_read_addr1,
  output wire [1:0] data_read_addr2,
  output wire [3:0] data_fwd,
  output wire       data_write_addr,
  output wire       data_write_en,
  output wire [3:0] data_write_bs,
  output wire [7:0] key_latch_en,
  output wire       key_key_idx,
  output wire [1:0] key_word_idx,
  output wire [2:0] key_shift_idx,
  output wire [2:0] sigma_read_addr,
  output wire [1:0] op_subcycle,
  output wire [2:0] op_opcode,
  output wire [1:0] output_mux
);
  typedef enum logic[1:0] {
    IDLE, RUN, TEST
  } state_t;
  state_t state;
  logic[1:0] proc_id;
  logic[4:0] proc_pc;
  logic[4:0] subproc_pc;

  // transition signals
  state_t next_state;
  logic[1:0] next_proc_id;
  logic[4:0] next_proc_pc;
  logic[4:0] next_subproc_pc;

  function [2:0] calls(input[2:0] _proc_id, input[4:0] _proc_pc); begin
    calls = 15; // undefined
    case(_proc_id)
      // data
      0: case(_proc_pc)
        0: calls = SP_IN128;
      endcase
      // key
      1: case(_proc_pc)
        0: calls = SP_IN128;
        1: calls = SP_KEYHELPER_A;
        2: calls = SP_FA;
        3: calls = SP_FB;
        4: calls = SP_FL;
        5: calls = SP_FA;
        6: calls = SP_FB;
        7: calls = SP_KEYHELPER_A;
        8: calls = SP_KEYHELPER_B;
      endcase
      // encrypt/decrypt
      2, 3: case(_proc_pc)
        0: calls = SP_ADDKEY;

        1: calls = SP_FA;
        2: calls = SP_FB;
        3: calls = SP_FA;
        4: calls = SP_FB;
        5: calls = SP_FA;
        6: calls = SP_FB;

        7: calls = SP_FL;

        8: calls = SP_FA;
        9: calls = SP_FB;
        10: calls = SP_FA;
        11: calls = SP_FB;
        12: calls = SP_FA;
        13: calls = SP_FB;

        14: calls = SP_FL;

        15: calls = SP_FA;
        16: calls = SP_FB;
        17: calls = SP_FA;
        18: calls = SP_FB;
        19: calls = SP_FA;
        20: calls = SP_FB;

        21: calls = SP_SWAPHALVES;
        22: calls = SP_ADDKEY;
      endcase
    endcase
  end endfunction

  function returns(input[2:0] _subproc_id, input[4:0] _subproc_pc); begin
    case(_subproc_id)
      SP_KEYHELPER_A: returns = _subproc_pc == 3;
      SP_KEYHELPER_B: returns = _subproc_pc == 3;
      SP_FA: returns = _subproc_pc == 9;
      SP_FB: returns = _subproc_pc == 9;
      SP_FL: returns = _subproc_pc == 11;
      SP_ADDKEY: returns = _subproc_pc == 7;
      SP_SWAPHALVES: returns = _subproc_pc == 21;
      SP_IN128: returns = _subproc_pc == 19;
      default: returns = 1;
    endcase
  end endfunction

  function exits(input[1:0] _proc_id, input[4:0] _proc_pc); begin
    case(_proc_id)
      P_DATA: exits = _proc_pc == 0;
      P_KEY: exits = _proc_pc == 8;
      P_ENCRYPT: exits = _proc_pc == 22;
      P_DECRYPT: exits = _proc_pc == 22;
      default: exits = 1;
    endcase
  end endfunction

  always_comb begin
    if(state == IDLE || rst) begin
      next_state = IDLE;
      next_proc_id = 0;
      next_proc_pc = 0;
      next_subproc_pc = 0;
    end else if(state == RUN) begin
      if(returns(calls(proc_id), subproc_pc)) begin
        if(exits(proc_id, proc_pc)) begin
          next_state = IDLE;
          next_proc_id = 0;
          next_proc_pc = 0;
          next_subproc_pc = 0;
        end else begin
          next_state = RUN;
          next_proc_id = proc_id;
          next_proc_pc = proc_pc + 1;
          next_subproc_pc = 0;
        end
      end else begin
        next_state = RUN;
        next_proc_id = proc_id;
        next_proc_pc = proc_pc;
        next_subproc_pc = subproc_pc + 1;
      end
    end
  end
endmodule
