`default_nettype none

module data_reg(
  input  wire clk,

  input  wire [2:0]  read_addr1,
  output wire [31:0] read_data1,
  input  wire [2:0]  read_addr2,
  output wire [31:0] read_data2,

  input  wire [2:0]  write_addr,
  input  wire        write_en,
  input  wire [31:0] write_data
);

  logic [191:0] data;

  generate
    for(genvar i = 0; i < 6; i++) begin : g
      dff_en #(.WIDTH(32)) flop(
        .q(data[i*32 +: 32]),
        .clk,
        .d(write_data),
        .de(i == write_addr && write_en)
      );
    end
  endgenerate

  assign read_data1 = read_addr1 < 6 ? data[{read_addr1, 5'b0} +: 32] : 32'b0;
  assign read_data2 = read_addr2 < 6 ? data[{read_addr2, 5'b0} +: 32] : 32'b0;
endmodule
