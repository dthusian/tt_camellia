`default_nettype none

module data_reg(
  input  wire clk,

  input  wire [31:0] key_result,
  input  wire [31:0] sigma_result,

  input  wire [2:0]  read_addr1, // r0-r5, r4-r5
  output wire [31:0] read_data1,
  input  wire [1:0]  read_addr2, // r4-r5, key, sigma
  output wire [31:0] read_data2,

  input  wire [1:0]  fwd,

  input  wire        write_addr, // r4-r5
  input  wire        write_en,
  input  wire [3:0]  write_bs,
  input  wire [31:0] write_data
);
  // Data reg is composed of 6x 32-bit words: 2 flops and 4 latches
  // We also perform the routing for the key and sigma results

  logic [31:0] data [3:0];
  logic [31:0] scratch [1:0];

  generate
    for(genvar i = 0; i < 4; i++) begin : g
      latch #(.WIDTH(32)) latches (
        .q(data[i]),
        .en(fwd[i[1]]),
        .d(scratch[i[0]])
      );
    end
    for(genvar i = 0; i < 2; i++) begin : h
      dff_en #(.WIDTH(8)) flop0 (
        .q(scratch[i][0 +: 8]),
        .clk,
        .d(write_data[0 +: 8]),
        .de(i == write_addr && write_en && write_bs[0])
      );
      dff_en #(.WIDTH(8)) flop1 (
        .q(scratch[i][8 +: 8]),
        .clk,
        .d(write_data[8 +: 8]),
        .de(i == write_addr && write_en && write_bs[1])
      );
      dff_en #(.WIDTH(8)) flop2 (
        .q(scratch[i][16 +: 8]),
        .clk,
        .d(write_data[16 +: 8]),
        .de(i == write_addr && write_en && write_bs[2])
      );
      dff_en #(.WIDTH(8)) flop3 (
        .q(scratch[i][24 +: 8]),
        .clk,
        .d(write_data[24 +: 8]),
        .de(i == write_addr && write_en && write_bs[3])
      );
    end
  endgenerate
  
  // read port 1
  logic [31:0] rdmux1_tmp;
  mux4 #(.WIDTH(32)) rdmux1 (
    .x(rdmux1_tmp),
    .a0(data[0]),
    .a1(data[1]),
    .a2(data[2]),
    .a3(data[3]),
    .s0(read_addr1[0]),
    .s1(read_addr1[1])
  );
  mux4 #(.WIDTH(32)) rdmux2 (
    .x(read_data1),
    .a0(rdmux1_tmp),
    .a1(rdmux1_tmp),
    .a2(scratch[0]),
    .a3(scratch[1]),
    .s0(read_addr1[0]),
    .s1(read_addr1[2])
  );

  // read port 2
  mux4 #(.WIDTH(32)) rdmux3 (
    .x(read_data2),
    .a0(scratch[0]),
    .a1(scratch[1]),
    .a2(key_result),
    .a3(sigma_result),
    .s0(read_addr2[0]),
    .s1(read_addr2[1])
  );
endmodule
